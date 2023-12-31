//
//  UserListTbCell.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

class UserListTbCell: UITableViewCell, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var imgView: UIImageView!
    var nameLabel: UILabel!
    var button: AnimatableButton!
    
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
        nameLabel.text = nil
        imgView.image = nil
        button.setImage(nil, for: .normal)
    }
    
    func bind(reactor: UserListTbCellReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    func bindAction(_ reactor: UserListTbCellReactor) {
        reactor.action.onNext(.initUserInfo)
        reactor.action.onNext(.initImage)
        reactor.action.onNext(.valateBookmark)
        
        button.rx
            .tap
            .map { [weak self] _ in self?.button.isSelected ?? false }
            .bind { hasMarked in
                hasMarked ? reactor.action.onNext(.unselectBookmark) : reactor.action.onNext(.selectBookmark)
            }
            .disposed(by: disposeBag)
    }
    
    func bindState(_ reactor: UserListTbCellReactor) {
        reactor.state
            .map { $0.image }
            .bind(to: imgView.rx.image)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.infoModel }
            .compactMap { $0?.name }
            .bind(to: nameLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.hasMarked }
            .bind { [weak self] hasMarked in
                guard let `self` = self else  { return }
                let config = UIImage
                    .SymbolConfiguration(pointSize: 23.0,
                                         weight: .regular,
                                         scale: .large)
                var image = UIImage(systemName: "bookmark",
                                    withConfiguration: config)
                if hasMarked {
                    image = UIImage(systemName: "bookmark.fill",
                                    withConfiguration: config)
                }
                self.button.isSelected = hasMarked
                self.button.setImage(image, for: .normal)
            }
            .disposed(by: disposeBag)
    }
    
    func setupView() {
        imgView = {
            let imgView = UIImageView()
            imgView.contentMode = .scaleAspectFit
            return imgView
        }()
        nameLabel = {
            let label = UILabel()
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 4
            return label
        }()
        button = {
            let btn = AnimatableButton()
            btn.feedbackImpact = .style(.medium)
            return btn
        }()
        
        contentView.addSubview(imgView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(button)
        
        imgView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().inset(10)
            $0.width.equalTo(90)
            $0.height.equalTo(contentView.snp.height)
        }
        nameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(imgView.snp.right).offset(15)
            $0.right.equalTo(button.snp.left).offset(-15)
        }
        button.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(20)
            $0.width.height.equalTo(50)
        }
    }
}
