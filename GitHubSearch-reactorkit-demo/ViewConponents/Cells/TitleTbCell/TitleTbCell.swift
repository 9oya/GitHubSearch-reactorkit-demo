//
//  TitleTbCell.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/25/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

class TitleTbCell: UITableViewCell, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var titleLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        titleLabel.text = nil
    }
    
    func bind(reactor: TitleTbCellReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    func bindAction(_ reactor: TitleTbCellReactor) {
        reactor.action.onNext(.initTitle)
    }
    
    func bindState(_ reactor: TitleTbCellReactor) {
        reactor.state
            .map { $0.title }
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func setupView() {
        titleLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16, weight: .regular)
            return label
        }()
        
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
    }
}

