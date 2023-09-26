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
import Factory

extension Container {
    
    // MARK: Services
    
    var networkService: Factory<NetworkServiceProtocol> {
        self { NetworkService(manager: Session.default, 
                              decoder: self.decoder()) }
    }
    var imageService: Factory<ImageServiceProtocol> {
        self { ImageService(manager: self.cachManager()) }
    }
    var coreDataService: Factory<CoreDataServiceProtocol> {
        self { CoreDataService(managedContext: self.managedContext()) }
    }
    
}
