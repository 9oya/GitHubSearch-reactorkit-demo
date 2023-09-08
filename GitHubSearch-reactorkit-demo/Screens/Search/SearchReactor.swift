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
        case setSearchResult(String, [CellConfigType])
        case setNextPage([CellConfigType])
        case setLoadingNextPage(Bool)
        case setCanceled(Bool)
    }
    
    struct State {
        var title: String
        var placeHolder: String
        var query: String?
        var rowConfigs: [CellConfigType]
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
                                  placeHolder: placeHolder,
                                  rowConfigs: [],
                                  currentPage: 0,
                                  isLoadingNextPage: false,
                                  isCanceled: false)
        self.provider = provider
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .search(query):
            guard !query.isEmpty,
                  !currentState.isLoadingNextPage else {
                return .empty()
            }
            
            return .concat([
                .just(.setLoadingNextPage(true)),
                .just(.setCanceled(false)),
                
                provider
                    .networkService
                    .search(with: query, for: 1)
                    .flatMap(convertTorowConfigs)
                    .filter { $0.count > 0 }
                    .catchAndReturn([])
                    .asObservable()
                    .map { .setSearchResult(query, $0)}
            ])
        case .nextPage:
            guard !currentState.isLoadingNextPage,
                    !currentState.isCanceled,
                  let query = currentState.query else {
                return .empty()
            }
            
            return .concat([
                .just(.setLoadingNextPage(true)),
                
                provider
                    .networkService
                    .search(with: query,
                            for: currentState.currentPage+1)
                    .flatMap(convertTorowConfigs)
                    .catchAndReturn([])
                    .asObservable()
                    .map { [weak self] rowConfigs in
                        guard let self = self else { return .setNextPage([]) }
                        return .setNextPage(self.currentState.rowConfigs + rowConfigs)
                    }
            ])
        case .cancel:
            return .just(.setCanceled(true))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newSate: State = state
        
        switch mutation {
        case let .setSearchResult(query, rowConfigs):
            newSate.query = query
            newSate.currentPage = 1
            newSate.isLoadingNextPage = false
            newSate.rowConfigs = rowConfigs
            
        case let .setNextPage(rowConfigs):
            newSate.currentPage += 1
            newSate.isLoadingNextPage = false
            newSate.rowConfigs = rowConfigs
            
        case let .setLoadingNextPage(isLoading):
            newSate.isLoadingNextPage = isLoading
            
        case let .setCanceled(isCanceled):
            newSate.isCanceled = isCanceled
            if isCanceled {
                newSate.rowConfigs = []
            }
        }
        
        return newSate
    }
}

extension SearchReactor {
    // MARK: Function components
    
    private func convertTorowConfigs(with result: Result<SearchResponseModel, Error>)
    -> Single<[CellConfigType]> {
        return Single.create { observer in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                observer(.failure(error))
            case .success(let model):
                var configs: [CellConfigType] = []
                
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
