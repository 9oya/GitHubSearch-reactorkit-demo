//
//  CellConfig.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import UIKit

typealias CellHandler = ((IndexPath)->Void)?

protocol CellConfigProtocol {
    
    var tag: Int { get }
    var identifier: String { get }
    var cellIdentifier: String { get }
    func cellConfigurator(cell: UITableViewCell,
                          indexPath: IndexPath)
    -> UITableViewCell
    var handleCellWith: CellHandler { get }
}
