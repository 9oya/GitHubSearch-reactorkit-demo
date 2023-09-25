//
//  DetailViewController.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/25/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources
import RxFlow

class DetailViewController: UIViewController, UITableViewDelegate, View {
    
    var tv: UITableView!
    
    var disposeBag: DisposeBag = DisposeBag()
    var rowConfigs: [CellConfigType] = []
    
    func bind(reactor: DetailReactor) {
        setupViews()
        bindAction(reactor)
        bindState(reactor)
    }
    
    func bindAction(_ reactor: DetailReactor) {
        rx.viewWillAppear
            .map { _ in Reactor.Action.initInfo }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tv.rx.itemSelected
            .bind { [weak self] indexPath in
                self?.tv.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func bindState(_ reactor: DetailReactor) {
        reactor.state
            .map { $0.rowConfigs }
            .do { [weak self] cellConfigs in
                self?.rowConfigs = cellConfigs
            }
            .bind(to: tv.rx.items) { tv, idx, item -> UITableViewCell in
                let cell = tv.dequeueReusableCell(
                    withIdentifier: item.cellIdentifier,
                    for: IndexPath(row: idx,
                                   section: 0)
                )
                return item.configure(cell: cell,
                                      with: IndexPath(row: idx,
                                                      section: 0))
            }
            .disposed(by: disposeBag)
    }
    
    func setupViews() {
        view.backgroundColor = .white
        
        tv = {
            let tv = UITableView()
            return tv
        }()
        tv.registerCells([
            TitleTbCell.self,
            ImageTbCell.self
        ])
        tv.rx.setDelegate(self).disposed(by: disposeBag)
            
        view.addSubview(tv)
        
        tv.snp.makeConstraints {
            $0.top.bottom.equalTo(view)
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard rowConfigs.count > 0 else { return 0 }
        return self.rowConfigs[indexPath.row].cellHeight
    }
}
