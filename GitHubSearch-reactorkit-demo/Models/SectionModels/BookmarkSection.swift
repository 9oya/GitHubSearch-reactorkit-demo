//
//  BookmarkSection.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import RxSwift
import RxDataSources
import Differentiator

struct BookmarkSection {
    var header: String
    var items: [Item]
}

extension BookmarkSection: SectionModelType {
    typealias Item = CellConfigProtocol
    
    init(original: BookmarkSection, items: [Item]) {
        self = original
        self.items = items
    }
}
