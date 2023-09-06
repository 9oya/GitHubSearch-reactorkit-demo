//
//  UserListTbCellReactor.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

class UserListTbCellReactor: Reactor, CellConfigProtocol {
    
    enum Action {
        case initUserInfo
        case initImage
        case valateBookmark
        case bookmarkAction
    }
    
    enum Mutation {
        case setUserInfo(Result<UserInfoModel, any Error>)
        case setImage(UIImage)
        case setBookmark(Result<UserItem?, any Error>)
        case setBookmarkForAction(Result<UserItem, any Error>)
    }
    
    struct State {
        var userItemModel: UserItemModel
        var image: UIImage?
        var infoModel: UserInfoModel?
        var hasMarked: Bool
    }
    
    let initialState: State
    let provider: ServiceProviderProtocol
    
    init(userItemModel: UserItemModel,
         provider: ServiceProviderProtocol,
         cellIdentifier: String,
         cellHeight: CGFloat) {
        self.provider = provider
        self.cellIdentifier = cellIdentifier
        self.cellIdentifier = cellIdentifier
        self.cellHeight = cellHeight
        self.initialState = State(userItemModel: userItemModel,
                                  hasMarked: false)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .initUserInfo:
            return provider
                .networkService
                .detail(id: currentState.userItemModel.login)
                .asObservable()
                .map { .setUserInfo($0) }
        case .initImage:
            return provider
                .imageService
                .downloadImage(with: currentState.userItemModel.avatarUrl)
                .flatMap(provider.imageService.validateImage(_:))
                .asObservable()
                .map { .setImage($0) }
        case .valateBookmark:
            return provider
                .coreDataService
                .match(id: currentState.userItemModel.id)
                .asObservable()
                .map { .setBookmark($0) }
        case .bookmarkAction:
            return validateUserInfoModelState(state: currentState)
                .flatMap(provider.coreDataService.store)
                .asObservable()
                .map { .setBookmarkForAction($0) }
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setUserInfo(result):
            switch result {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(userInfoModel):
                newState.infoModel = userInfoModel
            }
        case let .setImage(image):
            newState.image = image
        case .setBookmark(let result):
            switch result {
            case let .failure(error):
                print(error.localizedDescription)
            case let .success(userItem):
                newState.hasMarked = userItem != nil ? true : false
            }
        case .setBookmarkForAction(let result):
            switch result {
            case let .failure(error):
                print(error.localizedDescription)
            case .success(_):
                newState.hasMarked = true
            }
        }
        return newState
    }
    
    // MARK: CellConfigProtocol
    
    var cellIdentifier: String
    var cellHeight: CGFloat
    
    func configure(cell: UITableViewCell, with indexPath: IndexPath) -> UITableViewCell {
        if let cell = cell as? UserListTbCell {
            cell.reactor = self
            return cell
        }
        return UITableViewCell()
    }
    
    func distinctIdentifier() -> String {
        """
        \(currentState.hasMarked)
        \(currentState.userItemModel.avatarUrl)
        \(currentState.userItemModel.login)
        \(currentState.userItemModel.id)
        """
    }
}

extension UserListTbCellReactor {
    
    func validateUserInfoModelState(state: State) -> PrimitiveSequence<SingleTrait, (UserItemModel, UserInfoModel)> {
        return Single.create { [weak self] single -> Disposable in
            guard let `self` = self else { return Disposables.create() }
        
            if state.infoModel == nil {
                single(.failure(CustomError(title: "No value",
                                            description: "There is no state value of the UserInfoModel",
                                            code: 0)))
            } else {
                single(.success((self.currentState.userItemModel, self.currentState.infoModel!)))
            }
            
            return Disposables.create()
        }
    }
}