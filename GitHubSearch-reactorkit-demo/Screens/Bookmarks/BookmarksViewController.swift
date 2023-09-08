//
//  BookmarksViewController.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

class BookmarksViewController: UIViewController, UITableViewDelegate, View {
    
    var sc: UISearchController!
    var tv: UITableView!
    var dataSource: RxTableViewSectionedReloadDataSource<BookmarkSection>!
    
    var disposeBag: DisposeBag = DisposeBag()
    var sections: [BookmarkSection] = []
    
    func bind(reactor: BookmarksReactor) {
        setupViews(reactor)
        bindAction(reactor)
        bindState(reactor)
    }
    
    func bindAction(_ reactor: BookmarksReactor) {
        rx.viewWillAppear
            .map { _ in Reactor.Action.initUsers }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
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
            .bind { [weak self] indexPath in
                self?.tv.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func bindState(_ reactor: BookmarksReactor) {
        reactor.state
            .map { $0.sections }
            .do(onNext: { [weak self] sections in
                self?.sections = sections
            })
            .distinctUntilChanged { lhs, rhs in
                if lhs.count == rhs.count {
                    for i in 0..<lhs.count {
                        if lhs[i].items.count != rhs[i].items.count {
                            return false
                        } else {
                            for j in 0..<lhs[i].items.count {
                                if lhs[i].items[j].distinctIdentifier() != rhs[i].items[j].distinctIdentifier() {
                                    return false
                                }
                            }
                        }
                    }
                    return true
                }
                return false
            }
            .bind(to: tv.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    func setupViews(_ reactor: BookmarksReactor) {
        guard let nc = navigationController else { return }
        nc.navigationBar.prefersLargeTitles = true
        navigationItem.title = reactor.currentState.title
        view.backgroundColor = .white
        
        sc = {
            let sc = UISearchController(searchResultsController: nil)
            sc.obscuresBackgroundDuringPresentation = false
            sc.searchBar.placeholder = reactor.currentState.placeHolder
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
        
        dataSource = RxTableViewSectionedReloadDataSource<BookmarkSection>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView
                    .dequeueReusableCell(withIdentifier: item.cellIdentifier,
                                         for: indexPath)
                return item.configure(cell: cell,
                                      with: indexPath)
            }, titleForHeaderInSection: { dataSource, index in
                return dataSource.sectionModels[index].header
            }, canEditRowAtIndexPath: { _, _ in
                return true
            })
            
        view.addSubview(tv)
        
        tv.snp.makeConstraints {
            $0.top.bottom.equalTo(view)
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard sections.count > 0 else { return 0 }
        return sections[indexPath.section].items[indexPath.row].cellHeight
    }
}
