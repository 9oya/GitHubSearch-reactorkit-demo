//
//  Container+Reactors.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/27/23.
//

import Factory

extension Container {
    
    // MARK: Reactors
    
    var bookmarsReactor: ParameterFactory<SearchEntity, BookmarksReactor> {
        self {
            BookmarksReactor(title: $0.title,
                             placeHolder: $0.placeHolder)
        }
        .scope(.unique)
    }
    var searchReactor: ParameterFactory<SearchEntity, SearchReactor> {
        self {
            SearchReactor(title: $0.title,
                          placeHolder: $0.placeHolder)
        }
        .scope(.unique)
    }
    var detailReactor: ParameterFactory<DetailEntity, DetailReactor> {
        self {
            DetailReactor(login: $0.login,
                          avatarUrl: $0.avatarUrl)
        }
        .scope(.unique)
    }
    
}
