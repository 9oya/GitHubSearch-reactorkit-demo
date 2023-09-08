//
//  ManagerProvider.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import UIKit
import Kingfisher
import Alamofire
import CoreData

protocol ManagerProviderProtocol {
    
    var managedContext: ManagedContextProtocol { get }
    var cacheManager: CacheManagerProtocol { get }
    
}

struct ManagerProvider: ManagerProviderProtocol {
    
    var managedContext: ManagedContextProtocol
    var cacheManager: CacheManagerProtocol
    
    static func resolve() -> ManagerProviderProtocol {
        
        let cacheManager: KingfisherManager = KingfisherManager.shared
        let storeContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "GitHubSearch-reactorkit-demo")
            container.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    print("Unresolved error \(error), \(error.userInfo)")
                }
            }
            return container
        }()
        let managedContext: ManagedContextProtocol = storeContainer.viewContext
        
        return ManagerProvider(
            managedContext: managedContext,
            cacheManager: cacheManager
        )
    }
    
}
