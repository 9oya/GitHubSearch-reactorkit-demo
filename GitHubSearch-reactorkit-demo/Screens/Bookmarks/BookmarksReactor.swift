//
//  BookmarksReactor.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import RxSwift
import RxCocoa
import ReactorKit
import RxFlow

class BookmarksReactor: Reactor, Stepper {
    
    let steps: PublishRelay<Step> = PublishRelay<Step>()
    
    enum Action {
        case initUsers
        case search(String?)
        case nextPage
        case cancel
        case selectRow(Int, Int)
    }
    
    enum Mutation {
        case setPrevInit
        case setNextPage([BookmarkSection])
        case setSearchResult(String, [BookmarkSection])
        case setLoading(Bool)
        case setCanceled
    }
    
    struct State {
        var title: String
        var placeHolder: String
        var query: String?
        var currPage: Int
        var isLoadingNextPage: Bool
        var sections: [BookmarkSection]
    }
    
    var initialState: State
    let provider: ServiceProviderProtocol
    var cachedConfigDict: [String: [CellConfigType]] = [:]
    
    init(title: String,
         placeHolder: String,
         provider: ServiceProviderProtocol) {
        self.initialState = State(title: title,
                                  placeHolder: placeHolder,
                                  currPage: 1,
                                  isLoadingNextPage: false,
                                  sections: [])
        self.provider = provider
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .initUsers:
            var functionComponent: PrimitiveSequence<SingleTrait, Result<[UserItem], Error>>
            if currentState.query != nil {
                functionComponent = provider.coreDataService
                    .search(with: currentState.query!,
                            for: currentState.currPage)
            } else {
                functionComponent = provider.coreDataService
                    .fetch(page: currentState.currPage)
            }
            
            return .concat([
                .just(.setLoading(true)),
                
                .just(.setPrevInit),
                
                functionComponent
                    .flatMap(convertToCellConfigs)
                    .flatMap(bookmarkSections)
                    .filter { $0.count > 0 }
                    .catchAndReturn([])
                    .asObservable()
                    .map { Mutation.setNextPage($0) }
            ])
        case let .search(query):
            guard query != nil else { return .empty() }
            cachedConfigDict = [:]
            
            return .concat([
                .just(.setLoading(false)),
                
                provider
                    .coreDataService
                    .search(with: query!,
                            for: 1)
                    .flatMap(convertToCellConfigs)
                    .flatMap(bookmarkSections)
                    .catchAndReturn([])
                    .asObservable()
                    .map { .setSearchResult(query!, $0) },
                
                .just(.setLoading(false))
            ])
        case .nextPage:
            guard !currentState.isLoadingNextPage else { return .empty() }
            
            var functionComponent: PrimitiveSequence<SingleTrait, Result<[UserItem], Error>>
            if currentState.query != nil {
                functionComponent = provider.coreDataService
                    .search(with: currentState.query!,
                            for: currentState.currPage + 1)
            } else {
                functionComponent = provider.coreDataService
                    .fetch(page: currentState.currPage + 1)
            }
            
            return .concat([
                .just(.setLoading(true)),
                
                functionComponent
                    .flatMap(convertToCellConfigs)
                    .flatMap(bookmarkSections)
                    .catchAndReturn([])
                    .asObservable()
                    .map { .setNextPage($0) },
                
                .just(.setLoading(false))
            ])
        case .cancel:
            cachedConfigDict = [:]
            
            return .concat([
                .just(.setCanceled),
                
                provider.coreDataService
                    .fetch(page: 1)
                    .flatMap(convertToCellConfigs)
                    .flatMap(bookmarkSections)
                    .filter { $0.count > 0 }
                    .catchAndReturn([])
                    .asObservable()
                    .map { Mutation.setNextPage($0) }
            ])
            
        case let .selectRow(section, row):
            if let rowConfig = currentState.sections[section].items[row] as? UserListTbCellReactor {
                steps.accept(AppSteps.detailIsRequired(
                    rowConfig.currentState.userItemModel.login,
                    rowConfig.currentState.userItemModel.avatarUrl
                ))
            }
            
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        
        switch mutation {
        case .setPrevInit:
            newState.currPage = 1
            
        case let .setLoading(isLoading):
            newState.isLoadingNextPage = isLoading
            
        case let .setNextPage(sections):
            newState.currPage += 1
            newState.sections = sections
            
        case let .setSearchResult(query, sections):
            newState.query = query
            newState.sections = sections
            newState.currPage = 1
            
        case .setCanceled:
            newState.isLoadingNextPage = true
            newState.query = nil
            newState.currPage = 1
        }
        
        return newState
    }
}

extension BookmarksReactor {
    // MARK: Function components
    
    private func bookmarkSections(with configsDict: [String: [CellConfigType]])
    -> Single<[BookmarkSection]> {
        return Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            self.cachedConfigDict = configsDict
            var sections: [BookmarkSection] = []
            
            let sortedConfigs = configsDict.sorted { lhs, rhs in
                lhs.key < rhs.key
            }
            
            sortedConfigs.forEach { key, val in
                sections.append(
                    BookmarkSection(header: key,
                                    items: val)
                )
            }
            
            single(.success(sections))
            
            return Disposables.create()
        }
    }
    
    private func convertToCellConfigs(with result: Result<[UserItem], Error>)
    -> Single<[String: [CellConfigType]]> {
        return Single.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                observer(.failure(error))
            case .success(let items):
                if items.count <= 0 {
                    observer(.success([:]))
                }
                var configsDict: [String: [CellConfigType]] = self.cachedConfigDict
                
                items.forEach { [weak self] item in
                    guard let self = self else { return }
                    
                    let model = UserItemModel(login: item.login!,
                                              id: Int(item.id),
                                              avatarUrl: item.avatarUrl!)
                    let config = UserListTbCellReactor(userItemModel: model,
                                                       provider: self.provider,
                                                       cellHeight: 110)
                    
                    let headerTxt = (item.name ?? item.login!).firstLetter() ?? ""
                    if let _ = configsDict[headerTxt] {
                        configsDict[headerTxt]?.append(config)
                    } else {
                        configsDict[headerTxt] = [config]
                    }
                }
                
                observer(.success(configsDict))
            }
            return Disposables.create()
        }
    }
}
