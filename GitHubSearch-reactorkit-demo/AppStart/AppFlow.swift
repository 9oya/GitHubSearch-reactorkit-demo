//
//  AppFlow.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/25/23.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxFlow

class AppFlow: Flow {
    var root: Presentable {
        return rootVC
    }
    
    private lazy var rootVC: UITabBarController = {
        let tc = HomeTabbarController()
        return tc
    }()
    
    private let serviceProvider: ServiceProviderProtocol
    
    init(serviceProvider: ServiceProviderProtocol) {
        self.serviceProvider = serviceProvider
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    func navigate(to step: RxFlow.Step) -> FlowContributors {
        guard let step = step as? AppSteps else { return .none }
        
        switch step {
        case .homeIsRequired:
            return navigationToHomeScreen(serviceProvider)
        default:
            return .none
        }
    }
    
    private func navigationToHomeScreen(_ serviceProvider: ServiceProviderProtocol) -> FlowContributors {
        let searchFlow = SearchFlow(serviceProvider: serviceProvider)
        let bookmarksFlow = BookmarksFlow(serviceProvider: serviceProvider)
        
        let searchVC = SearchViewController()
        let bookmarksVC = BookmarksViewController()
        
        Flows.use([searchFlow, bookmarksFlow], when: .created) { [weak self] roots in
            
            guard let self = self,
                    let searchNC = roots[0] as? UINavigationController,
                    let bookmarksNC = roots[1] as? UINavigationController else { return }
            
            searchNC.setViewControllers([searchVC], animated: false)
            searchNC.tabBarItem.image = {
                let config = UIImage
                    .SymbolConfiguration(pointSize: 15.0,
                                         weight: .regular,
                                         scale: .large)
                return UIImage(systemName: "magnifyingglass",
                               withConfiguration: config)
            }()
            searchVC.reactor = SearchReactor(title: "Search",
                                             placeHolder: "Type name...",
                                             provider: serviceProvider)
            
            bookmarksNC.setViewControllers([bookmarksVC], animated: false)
            bookmarksNC.tabBarItem.image = {
                let config = UIImage
                    .SymbolConfiguration(pointSize: 15.0,
                                         weight: .regular,
                                         scale: .large)
                return UIImage(systemName: "bookmark",
                               withConfiguration: config)
            }()
            bookmarksVC.reactor = BookmarksReactor(title: "Bookmarks",
                                                   placeHolder: "User name...",
                                                   provider: serviceProvider)
            
            self.rootVC.viewControllers = [searchNC, bookmarksNC]
        }
        
        return FlowContributors.multiple(flowContributors: [
            .contribute(withNextPresentable: searchFlow,
                        withNextStepper: CompositeStepper(steppers: [searchVC.reactor!])),
            .contribute(withNextPresentable: bookmarksFlow,
                        withNextStepper: CompositeStepper(steppers: [bookmarksVC.reactor!]))
        ])
    }
}
