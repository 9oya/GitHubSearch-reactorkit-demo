//
//  SceneDelegate.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import UIKit
import ReactorKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = rootViewController()
        window?.makeKeyAndVisible()
    }

}

extension SceneDelegate {
    
    private func rootViewController() -> UIViewController {
        let provider = ServiceProvider.resolve()
        let searchVC = SearchViewController()
        let searchNC = UINavigationController(rootViewController: searchVC)
        searchNC.tabBarItem.image = {
            let config = UIImage
                .SymbolConfiguration(pointSize: 15.0,
                                     weight: .regular,
                                     scale: .large)
            return UIImage(systemName: "magnifyingglass",
                           withConfiguration: config)
        }()
        searchVC.reactor = SearchReactor(title: "Search",
                                         placeHolder: "Name...",
                                         provider: provider)
        
//        let bookmarksVM = BookmarksViewModel(title: "Bookmarks",
//                                             placeHolder: "Name...",
//                                             provider: provider)
//        let bookmarksVC = BookmarksViewController()
//        bookmarksVC.viewModel = bookmarksVM
//
//        let bookmarksNC = UINavigationController(rootViewController: bookmarksVC)
//        bookmarksNC.tabBarItem.image = {
//            let config = UIImage
//                .SymbolConfiguration(pointSize: 15.0,
//                                     weight: .regular,
//                                     scale: .large)
//            return UIImage(systemName: "bookmark",
//                           withConfiguration: config)
//        }()
        
        let tc = MainTabbarController()
//        tc.viewControllers = [searchNC, bookmarksNC]
        tc.viewControllers = [searchNC]
        return tc
    }
}
