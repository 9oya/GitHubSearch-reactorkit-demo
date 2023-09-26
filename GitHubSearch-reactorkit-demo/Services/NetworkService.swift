//
//  NetworkService.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import UIKit
import RxSwift
import Alamofire

protocol NetworkServiceProtocol {
    
    func search(with query: String, for page: Int)
    -> PrimitiveSequence<SingleTrait, Result<SearchResponseModel, Error>>
    
    func detail(id name: String)
    -> PrimitiveSequence<SingleTrait, Result<UserInfoModel, Error>>
    
}

class NetworkService: NetworkServiceProtocol {
    
    private let manager: Session
    private let decoder: JSONDecoderProtocol
    
    init(manager: Session,
         decoder: JSONDecoderProtocol) {
        self.manager = manager
        self.decoder = decoder
    }
    
    func search(with query: String, for page: Int)
    -> PrimitiveSequence<SingleTrait, Result<SearchResponseModel, Error>> {
        return Single.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            let url = APIRouter.searchUsers(query: query,
                                            sort: .bestMatch,
                                            order: .desc,
                                            page: page,
                                            perPage: 10)
            print("Request url: \(String(describing: url.queryItems))")
            self.manager.request(url)
                .responseData { response in
                    if let error = response.error {
                        single(.failure(error))
                    } else if let data = response.value {
                        do {
                            // let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            // print(json ?? "")
                            let decoded = try self.decoder
                                .decode(SearchResponseModel.self,
                                        from: data)
                            single(.success(.success(decoded)))
                        } catch let error {
                            single(.failure(error))
                        }
                    }
                }
            return Disposables.create()
        }
    }
    
    func detail(id login: String)
    -> PrimitiveSequence<SingleTrait, Result<UserInfoModel, Error>> {
        return Single.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            let url = APIRouter.userInfo(login: login)
            self.manager.request(url)
                .responseData { response in
                    if let error = response.error {
                        single(.failure(error))
                    } else if let data = response.value {
                        do {
                            // let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            // print(json ?? "")
                            let decoded = try self.decoder
                                .decode(UserInfoModel.self,
                                        from: data)
                            single(.success(.success(decoded)))
                        } catch let error {
                            single(.failure(error))
                        }
                    }
                }
            return Disposables.create()
        }
    }
    
}
