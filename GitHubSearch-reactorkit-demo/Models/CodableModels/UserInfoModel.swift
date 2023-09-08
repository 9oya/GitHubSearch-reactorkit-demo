//
//  UserInfoModel.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import Foundation

struct UserInfoModel: Codable {
    let name: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
