//
//  BookmarksReactor.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import RxSwift
import RxCocoa
import ReactorKit

class BookmarksReactor: Reactor {
    enum Action {
        case initUsers
        case search(String?)
        case nextPage
        case cancel
    }
    
    enum Mutation {
        case setPrevInit
        case setAfterInit([BookmarkSection])
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
                    .map { Mutation.setAfterInit($0) }
            ])
        case let .search(query):
            guard query != nil else { return .empty() }
            
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
                    .map { .setSearchResult(query!, $0) }
            ])
        case .nextPage:
            guard !currentState.isLoadingNextPage else { return .empty() }
            
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
                
                functionComponent
                    .flatMap(convertToCellConfigs)
                    .flatMap(bookmarkSections)
                    .catchAndReturn([])
                    .asObservable()
                    .map { .setAfterInit($0) }
            ])
        case .cancel:
            return .just(.setCanceled)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        
        switch mutation {
        case .setPrevInit:
            newState.currPage = 1
            
        case let .setLoading(isLoading):
            newState.isLoadingNextPage = isLoading
            
        case let .setAfterInit(sections):
            newState.currPage += 1
            newState.isLoadingNextPage = false
            newState.sections = sections
            
        case let .setSearchResult(query, sections):
            newState.query = query
            newState.sections = sections
            newState.isLoadingNextPage = false
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
    
    private func bookmarkSections(with configsDict: [String: [CellConfigProtocol]])
    -> Single<[BookmarkSection]> {
        return Single.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
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
    -> Single<[String: [CellConfigProtocol]]> {
        return Single.create { [weak self] observer in
            guard let `self` = self else { return Disposables.create() }
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                observer(.failure(error))
            case .success(let items):
                if items.count <= 0 {
                    observer(.success([:]))
                }
                var configsDict: [String: [CellConfigProtocol]] = [:]
                
                items.forEach { [weak self] item in
                    guard let `self` = self else { return }
                    
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
