//
//  CoreDataService.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import Foundation
import CoreData
import RxSwift

enum CoreDataError: Error, CustomStringConvertible {
    case fetch
    case store
    case remove
    
    var description: String {
        switch self {
        case .fetch:
            return "CoreDataError: fetch"
        case .store:
            return "CoreDataError: store"
        case .remove:
            return "CoreDataError: remove"
        }
    }
}

protocol CoreDataServiceProtocol {
    
    func match(id: Int)
    -> PrimitiveSequence<SingleTrait, Result<UserItem?, Error>>
    
    func search(with query: String, for page: Int)
    -> PrimitiveSequence<SingleTrait, Result<[UserItem], Error>>
    
    func fetch(page: Int)
    -> PrimitiveSequence<SingleTrait, Result<[UserItem], Error>>
    
    func store(model: (UserItemModel, UserInfoModel))
    -> PrimitiveSequence<SingleTrait, Result<UserItem, Error>>
    
    func remove(object: UserItem)
    -> PrimitiveSequence<SingleTrait, Result<Bool, Error>>
    
}

class CoreDataService: CoreDataServiceProtocol {
    
    private let managedContext: ManagedContextProtocol
    
    init(managedContext: ManagedContextProtocol) {
        self.managedContext = managedContext
    }
    
    func match(id: Int)
    -> PrimitiveSequence<SingleTrait, Result<UserItem?, Error>> {
        return Single.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            
            let fetchRequest: NSFetchRequest<UserItem> = UserItem.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(UserItem.id), Int32(id)])
            
            do {
                let users = try self.managedContext.fetch(fetchRequest)
                single(.success(.success(users.first)))
            } catch let error {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    func search(with query: String, for page: Int)
    -> PrimitiveSequence<SingleTrait, Result<[UserItem], Error>> {
        return Single.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            
            let fetchRequest: NSFetchRequest<UserItem> = UserItem.fetchRequest()
            
            // sort
            let sort = NSSortDescriptor(key: #keyPath(UserItem.name), ascending: false)
            fetchRequest.sortDescriptors = [sort]
            
            // condition
            fetchRequest.predicate = NSPredicate(format: "%K CONTAINS[cd] %@", argumentArray: [#keyPath(UserItem.name), query])
            
            // page limit
            fetchRequest.fetchLimit = 10
            fetchRequest.fetchOffset = 10 * (page-1)
            
            do {
                let users = try self.managedContext.fetch(fetchRequest)
                single(.success(.success(users)))
            } catch let error {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    func fetch(page: Int)
    -> PrimitiveSequence<SingleTrait, Result<[UserItem], Error>> {
        return Single.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            
            let fetchRequest: NSFetchRequest<UserItem> = UserItem.fetchRequest()
            let sort = NSSortDescriptor(key: #keyPath(UserItem.name), ascending: true)
            fetchRequest.sortDescriptors = [sort]
            
            fetchRequest.fetchLimit = 10
            fetchRequest.fetchOffset = 10 * (page-1)
            
            do {
                let users = try self.managedContext.fetch(fetchRequest)
                single(.success(.success(users)))
            } catch let error {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    func store(model: (UserItemModel, UserInfoModel))
    -> PrimitiveSequence<SingleTrait, Result<UserItem, Error>> {
        return Single.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            
            let userItem = UserItem(context: self.managedContext as! NSManagedObjectContext)
            userItem.login = model.0.login
            userItem.id = Int32(model.0.id)
            userItem.avatarUrl = model.0.avatarUrl
            userItem.name = model.1.name
            userItem.createdAt = model.1.createdAt
            userItem.updatedAt = model.1.updatedAt
            
            self.managedContext.performAndWait {
                do {
                    try self.managedContext.save()
                    single(.success(.success(userItem)))
                } catch let error {
                    single(.failure(error))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func remove(object: UserItem)
    -> PrimitiveSequence<SingleTrait, Result<Bool, Error>> {
        return Single.create { single -> Disposable in
            
            self.managedContext.delete(object)
            
            self.managedContext.performAndWait {
                do {
                    try self.managedContext.save()
                    single(.success(.success(true)))
                } catch let error {
                    single(.failure(error))
                }
            }
            
            return Disposables.create()
        }
    }
    
}
