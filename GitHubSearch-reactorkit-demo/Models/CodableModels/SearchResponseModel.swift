//
//  SearchResponseModel.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import Foundation

struct SearchResponseModel: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [UserItemModel]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items = "items"
    }
}
