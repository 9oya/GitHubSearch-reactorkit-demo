//
//  Container+Managers.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import UIKit
import Kingfisher
import Alamofire
import CoreData
import Factory

extension Container {
    
    // MARK: Managers
    
    var decoder: Factory<JSONDecoderProtocol> {
        self { JSONDecoder() }
            .scope(.shared)
    }
    var persistentContainer: Factory<PersistentContainerProtocol> {
        self {
            let container = NSPersistentContainer(name: "GitHubSearch-reactorkit-demo")
            container.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    print("Unresolved error \(error), \(error.userInfo)")
                }
            }
            return container
        }
        .scope(.shared)
    }
    var managedContext: Factory<ManagedContextProtocol> {
        self { self.persistentContainer().viewContext }
            .scope(.shared)
    }
    var cachManager: Factory<CacheManagerProtocol> {
        self { KingfisherManager.shared }
    }
    
}
