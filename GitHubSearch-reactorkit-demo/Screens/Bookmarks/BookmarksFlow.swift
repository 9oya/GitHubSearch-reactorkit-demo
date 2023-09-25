//
//  BookmarksFlow.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/25/23.
//

import UIKit
import RxSwift
import RxFlow
import RxCocoa

class BookmarksFlow: Flow {
    var root: RxFlow.Presentable {
        return rootVC
    }
    
    private let rootVC = UINavigationController()
    private let serviceProvider: ServiceProviderProtocol
    
    init(serviceProvider: ServiceProviderProtocol) {
        self.serviceProvider = serviceProvider
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        guard let step = step as? AppSteps else { return .none }
        
        switch step {
        case .bookmarksScreenIsRequired:
            return .none
        case let .detailIsRequired(login, avatarUrl):
            return navigationToDetailScreen(serviceProvider: serviceProvider,
                                            login: login,
                                            avatarUrl: avatarUrl)
        default:
            return .none
        }
    }
    
    private func navigationToDetailScreen(serviceProvider: ServiceProviderProtocol, 
                                          login: String,
                                          avatarUrl: String)
    -> FlowContributors {
        let vc = DetailViewController()
        vc.reactor = DetailReactor(provider: serviceProvider,
                                   login: login,
                                   avatarUrl: avatarUrl)
        rootVC.pushViewController(vc, animated: true)
        return .none
    }
}
