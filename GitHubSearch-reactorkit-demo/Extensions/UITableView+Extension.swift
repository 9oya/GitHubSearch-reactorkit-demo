//
//  UITableView+Extension.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import UIKit

extension UITableView {
    func registerCells(_ cellTypes: [UITableViewCell.Type]) {
        cellTypes.forEach { cellType in
            let id = String.className(cellType)
            self.register(cellType.self, forCellReuseIdentifier: id)
        }
    }
}
