//
//  SearchFlow.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/25/23.
//

import UIKit
import RxSwift
import RxFlow
import RxCocoa

class SearchFlow: Flow {
    var root: RxFlow.Presentable {
        return rootVC
    }
    
    private let rootVC = UINavigationController()
    
    init() {}
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        guard let step = step as? AppSteps else { return .none }
        
        switch step {
        case .searchScreenIsRequired:
            return .none
        case let .userIsPicked(login, avatarUrl):
            return navigationToDetailScreen(login: login,
                                            avatarUrl: avatarUrl)
        default:
            return .none
        }
    }
    
    private func navigationToDetailScreen(login: String,
                                          avatarUrl: String)
    -> FlowContributors {
        let vc = DetailViewController()
        vc.reactor = DetailReactor(login: login,
                                   avatarUrl: avatarUrl)
        rootVC.pushViewController(vc, animated: true)
        return .none
    }
}
