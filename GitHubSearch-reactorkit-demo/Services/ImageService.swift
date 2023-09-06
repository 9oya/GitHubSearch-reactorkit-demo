//
//  ImageService.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa

enum DownloadError: Error, CustomStringConvertible {
    case invalidUrlStr
    case invalidData
    
    var description: String {
        switch self {
        case .invalidUrlStr:
            return "DownloadError: invalidUrlStr"
        case .invalidData:
            return "DownloadError: invalidData"
        }
    }
}

protocol ImageServiceProtocol {
    
    func downloadImage(with urlStr: String)
    -> PrimitiveSequence<SingleTrait, Result<UIImage, Error>>
    
    func validateImage(_ result: Result<UIImage, Error>)
    -> PrimitiveSequence<SingleTrait, UIImage>
    
}

class ImageService: ImageServiceProtocol {
    
    private let manager: CacheManagerProtocol
    
    init(manager: CacheManagerProtocol) {
        self.manager = manager
    }
    
    func downloadImage(with urlStr: String)
    -> PrimitiveSequence<SingleTrait, Result<UIImage, Error>> {
        return Single.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            guard let encodedString = urlStr
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: encodedString) else {
                single(.failure(DownloadError.invalidUrlStr))
                return Disposables.create()
            }
            let resource = KF.ImageResource(downloadURL: url)
            _ = self.manager
                .retrieveImage(with: resource,
                               options: nil,
                               progressBlock: nil,
                               downloadTaskUpdated: nil)
            { result in
                switch result {
                case .success(let value):
                    single(.success(.success(value.image)))
                case .failure(let error):
                    single(.failure(error))
                    print("Error: \(error)")
                }
            }
            return Disposables.create()
        }
    }
    
    func validateImage(_ result: Result<UIImage, Error>)
    -> PrimitiveSequence<SingleTrait, UIImage> {
        return Single.create { single in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let image):
                single(.success(image))
            }
            return Disposables.create()
        }
    }
    
}
