//
//  HomeTabbarController.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/7/23.
//

import UIKit

class HomeTabbarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
}
