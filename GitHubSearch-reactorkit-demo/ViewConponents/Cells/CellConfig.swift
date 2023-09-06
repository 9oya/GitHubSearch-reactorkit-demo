//
//  CellConfig.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import UIKit

typealias CellHandler = ((IndexPath)->Void)?

protocol CellConfigProtocol {
    var cellIdentifier: String { get }
    var cellHeight: CGFloat { get }
    
    func configure(cell: UITableViewCell,
                   with indexPath: IndexPath)
    -> UITableViewCell
    
    func distinctIdentifier()
    -> String
}
