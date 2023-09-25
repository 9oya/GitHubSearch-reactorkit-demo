//
//  AppSteps.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/25/23.
//

import RxFlow

enum AppSteps: Step {
    // Global
    case homeIsRequired
    
    // Search
    case searchScreenIsRequired
    
    // Bookmarks
    case bookmarksScreenIsRequired
    
    // Detail
    case detailIsRequired(String, String)
}
