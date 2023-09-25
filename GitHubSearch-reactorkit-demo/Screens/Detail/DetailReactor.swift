//
//  DetailReactor.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/25/23.
//

import RxSwift
import RxCocoa
import ReactorKit

class DetailReactor: Reactor {
    enum Action {
        case initInfo
    }
    
    enum Mutation {
        case setRowConfigs([CellConfigType])
        case setLoading(Bool)
    }
    
    struct State {
        var login: String
        var avatarUrl: String
        var userInfo: UserInfoModel?
        var isLoading: Bool
        var rowConfigs: [CellConfigType]
    }
    
    var initialState: State
    let provider: ServiceProviderProtocol
    
    init(provider: ServiceProviderProtocol, 
         login: String,
         avatarUrl: String) {
        self.initialState = State(login: login,
                                  avatarUrl: avatarUrl,
                                  isLoading: true,
                                  rowConfigs: [])
        self.provider = provider
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .initInfo:
            return provider
                .networkService
                .detail(id: currentState.login)
                .flatMap(convertTorowConfigs)
                .catchAndReturn([])
                .asObservable()
                .map { .setRowConfigs($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newSate: State = state
        
        switch mutation {
        case let .setRowConfigs(rowConfigs):
            newSate.rowConfigs = rowConfigs
            
        case let .setLoading(isLoading):
            newSate.isLoading = isLoading
            
        }
        
        return newSate
    }
}

extension DetailReactor {
    // MARK: Function components
    
    private func convertTorowConfigs(with result: Result<UserInfoModel, Error>)
    -> Single<[CellConfigType]> {
        return Single.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                observer(.failure(error))
            case .success(let model):
                var configs: [CellConfigType] = []
                
                configs.append(
                    TitleTbCellReactor(cellHeight: 50,
                                       title: model.name ?? "Unkown")
                )
                configs.append(
                    ImageTbCellReactor(provider: provider, 
                                       cellHeight: 100,
                                       avatarUrl: self.currentState.avatarUrl)
                )
                configs.append(
                    TitleTbCellReactor(cellHeight: 50,
                                       title: model.createdAt ?? "Unkown")
                )
                configs.append(
                    TitleTbCellReactor(cellHeight: 50,
                                       title: model.updatedAt ?? "Unkown")
                )
                
                observer(.success(configs))
            }
            return Disposables.create()
        }
    }
}
