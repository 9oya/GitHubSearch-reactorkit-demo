//
//  SearchViewController.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

class SearchViewController: UIViewController, UITableViewDelegate, View {
    
    var sc: UISearchController!
    var tv: UITableView!
    
    var disposeBag: DisposeBag = DisposeBag()
    var rowConfigs: [CellConfigType] = []
    
    func bind(reactor: SearchReactor) {
        setupViews()
        bindAction(reactor)
        bindState(reactor)
    }
    
    func bindAction(_ reactor: SearchReactor) {
        sc.searchBar.rx
            .textDidEndEditing
            .compactMap { $0 }
            .throttle(.seconds(1),
                      scheduler: MainScheduler.instance)
            .map { [weak self] _ -> String? in
                self?.sc?.searchBar.text
            }
            .do { [weak self] _ in
                if self?.tv.visibleCells.count ?? 0 > 0 {
                    self?.tv.scrollToRow(at: IndexPath(row: 0, section: 0),
                                         at: .top,
                                         animated: false)
                }
            }
            .compactMap { $0 }
            .map { Reactor.Action.search($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        sc.searchBar.rx
            .cancelButtonClicked
            .map { Reactor.Action.cancel }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tv.rx.contentOffset
            .filter { [weak self] offset in
                guard let self = self else { return false }
                guard self.tv.frame.height > 0 else { return false }
                return offset.y + self.tv.frame.height >= self.tv.contentSize.height - 200
            }
            .map { _ in Reactor.Action.nextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tv.rx.itemSelected
            .do(onNext: { [weak self] idxPath in
                self?.tv.deselectRow(at: idxPath, animated: true)
            })
            .bind { [weak self] idxPath in
                guard let self = self else { return }
                if let cell: UserListTbCell = self.tv.cellForRow(at: idxPath) as? UserListTbCell,
                    let login = cell.reactor?.currentState.userItemModel.login,
                   let avatarUrl = cell.reactor?.currentState.userItemModel.avatarUrl {
                    let vc = DetailViewController()
                    vc.reactor = DetailReactor(provider: reactor.provider,
                                               login: login,
                                               avatarUrl: avatarUrl)
                    self.navigationController?
                        .pushViewController(vc,
                                            animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func bindState(_ reactor: SearchReactor) {
        reactor.state
            .map { $0.title }
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.placeHolder }
            .bind(to: sc.searchBar.rx.placeholder)
            .disposed(by: disposeBag)
        
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
        guard let nc = navigationController else { return }
        nc.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .white
        
        sc = {
            let sc = UISearchController(searchResultsController: nil)
            sc.obscuresBackgroundDuringPresentation = false
            sc.searchBar.autocapitalizationType = .none
            return sc
        }()
        navigationItem.searchController = sc
        
        tv = {
            let tv = UITableView()
            return tv
        }()
        tv.registerCells([
            UserListTbCell.self,
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
