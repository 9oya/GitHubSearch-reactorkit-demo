//
//  TitleTbCellReactor.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/25/23.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

class TitleTbCellReactor: Reactor, CellConfigType {
    
    enum Action {
        case initTitle
    }
    
    enum Mutation {
        case setTitle(String)
    }
    
    struct State {
        var title: String
    }
    
    let initialState: State
    
    init(cellHeight: CGFloat,
         title: String) {
        self.initialState = State(title: title)
        self.cellHeight = cellHeight
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .initTitle:
            return .just(.setTitle(currentState.title))
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setTitle(title):
            newState.title = title
        }
        return newState
    }
    
    // MARK: CellConfigProtocol
    
    var cellIdentifier: String = String(describing: TitleTbCell.self)
    var cellHeight: CGFloat
    
    func configure(cell: UITableViewCell, with indexPath: IndexPath) -> UITableViewCell {
        if let cell = cell as? TitleTbCell {
            cell.reactor = self
            return cell
        }
        return UITableViewCell()
    }
    
    func distinctIdentifier() -> String {
        """
        \(currentState.title)
        """
    }
}
