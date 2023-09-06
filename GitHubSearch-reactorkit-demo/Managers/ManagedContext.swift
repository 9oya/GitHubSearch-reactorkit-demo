//
//  ManagedContext.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import CoreData

protocol ManagedContextProtocol {
    
    func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T : NSFetchRequestResult
    
    func performAndWait(_ block: () -> Void)
    
    func save() throws
    
    func delete(_ object: NSManagedObject)
    
}

extension NSManagedObjectContext: ManagedContextProtocol {
}
