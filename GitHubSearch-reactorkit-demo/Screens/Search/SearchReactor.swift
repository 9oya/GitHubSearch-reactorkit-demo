//
//  SearchReactor.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import RxSwift
import RxCocoa
import ReactorKit

class SearchReactor: Reactor {
    enum Action {
        case search(String)
        case nextPage
        case cancel
    }
    
    enum Mutation {
        case setUsers([CellConfigProtocol])
        case setLoadingNextPage(Bool)
        case setCanceled
    }
    
    struct State {
        var title: String
        var placeHolder: String
        var query: String?
        var cellConfigs: [CellConfigProtocol]
        var currentPage: Int
        var isLoadingNextPage: Bool
        var isCanceled: Bool
    }
    
    var initialState: State
    let provider: ServiceProviderProtocol
    
    init(title: String, 
         placeHolder: String,
         provider: ServiceProviderProtocol) {
        self.initialState = State(title: title,
                                  placeHolder: placeHolder
                                  cellConfigs: [],
                                  currentPage: 0,
                                  isLoadingNextPage: false,
                                  isCanceled: false)
        self.provider = provider
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .search(keyword):
            return Observable.concat([
                Observable.just(.setLoadingNextPage(false)),
                
                provider
                    .networkService
                    .search(with: keyword, for: 1)
                    .flatMap(convertToCellConfigs)
                    .filter { $0.count > 0 }
                    .catchAndReturn([])
                    .asObservable()
                    .map { Mutation.setUsers($0)}
            ])
        case .nextPage:
            guard !currentState.isLoadingNextPage,
                    !currentState.isCanceled,
                    let query = currentState.query else { return .empty() }
            
            return Observable.concat([
                Observable.just(.setLoadingNextPage(true)),
                
                provider
                    .networkService
                    .search(with: query,
                            for: currentState.currentPage+1)
                    .flatMap(convertToCellConfigs)
                    .catchAndReturn([])
                    .asObservable()
                    .map { [weak self] cellConfigs in
                        guard let self = self else { return .setUsers([]) }
                        return Mutation.setUsers(self.currentState.cellConfigs + cellConfigs)
                    }
            ])
        case .cancel:
            return .just(.setCanceled)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newSate = state
        
        switch mutation {
        case let .setUsers(cellConfigs):
            newSate = state
            newSate.currentPage = 1
            newSate.isLoadingNextPage = false
            newSate.cellConfigs = cellConfigs
            
        case let .setLoadingNextPage(isLoading):
            newSate = state
            newSate.isLoadingNextPage = isLoading
            
        case .setCanceled:
            newSate = state
            newSate.isCanceled = true
            newSate.cellConfigs = []
        }
        
        return newSate
    }
}

extension SearchReactor {
    // MARK: Function components
    
    private func convertToCellConfigs(with result: Result<SearchResponseModel, Error>)
    -> Single<[CellConfigProtocol]> {
        return Single.create { observer in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                observer(.failure(error))
            case .success(let model):
                var configs: [CellConfigProtocol] = []
                
                model.items.forEach {
                    configs.append(
                        UserListTbCellReactor(userItemModel: $0,
                                              provider: self.provider,
                                              cellHeight: 110)
                    )
                }
                
                observer(.success(configs))
            }
            return Disposables.create()
        }
    }
}
