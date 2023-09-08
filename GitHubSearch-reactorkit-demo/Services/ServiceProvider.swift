//
//  ServiceProvider.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import Alamofire
import Kingfisher
import CoreData
import RxSwift

protocol ServiceProviderProtocol {
    
    var networkService: NetworkServiceProtocol { get }
    var imageService: ImageServiceProtocol { get }
    var coreDataService: CoreDataServiceProtocol { get }
    
}

struct ServiceProvider: ServiceProviderProtocol {
    
    var networkService: NetworkServiceProtocol
    var imageService: ImageServiceProtocol
    var coreDataService: CoreDataServiceProtocol
    
    static let shared: ServiceProviderProtocol = resolve()
    
    static func resolve() -> ServiceProviderProtocol {
        
        let provider = ManagerProvider.resolve()
        let sessionManager: Session = Session.default
        let decoder: JSONDecoder = JSONDecoder()
        
        return ServiceProvider(
            networkService: NetworkService(manager: sessionManager,
                                           decoder: decoder),
            imageService: ImageService(manager: provider.cacheManager),
            coreDataService: CoreDataService(managedContext: provider.managedContext)
        )
    }
    
}
