//
//  ImageTbCell.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/25/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

class ImageTbCell: UITableViewCell, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var imgView: UIImageView!
    
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
        imgView.image = nil
    }
    
    func bind(reactor: ImageTbCellReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    func bindAction(_ reactor: ImageTbCellReactor) {
        reactor.action.onNext(.initImage)
    }
    
    func bindState(_ reactor: ImageTbCellReactor) {
        reactor.state
            .map { $0.image }
            .bind(to: imgView.rx.image)
            .disposed(by: disposeBag)
    }
    
    func setupView() {
        imgView = {
            let imgView = UIImageView()
            imgView.contentMode = .scaleAspectFit
            return imgView
        }()
        
        contentView.addSubview(imgView)
        
        imgView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
    }
}
