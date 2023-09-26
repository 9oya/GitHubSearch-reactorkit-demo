//
//  PersistentContainerProtocol.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/26/23.
//

import CoreData

protocol PersistentContainerProtocol {
    static func defaultDirectoryURL() -> URL
    
    var name: String { get }

    var viewContext: NSManagedObjectContext { get }

    var managedObjectModel: NSManagedObjectModel { get }

    var persistentStoreCoordinator: NSPersistentStoreCoordinator { get }

    var persistentStoreDescriptions: [NSPersistentStoreDescription] { get }

    
    // Creates a container using the model named `name` in the main bundle
    init(name: String)

    
    init(name: String, managedObjectModel model: NSManagedObjectModel)

    
    // Load stores from the storeDescriptions property that have not already been successfully added to the container. The completion handler is called once for each store that succeeds or fails.
    func loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void)

    
    func newBackgroundContext() -> NSManagedObjectContext

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void)
}

extension NSPersistentContainer: PersistentContainerProtocol {}
