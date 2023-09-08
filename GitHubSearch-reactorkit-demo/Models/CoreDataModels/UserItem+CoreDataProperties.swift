//
//  UserItem+CoreDataProperties.swift
//  
//
//  Created by 9oya on 9/6/23.
//
//

import Foundation
import CoreData


extension UserItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserItem> {
        return NSFetchRequest<UserItem>(entityName: "UserItem")
    }

    @NSManaged public var avatarUrl: String?
    @NSManaged public var createdAt: String?
    @NSManaged public var id: Int32
    @NSManaged public var login: String?
    @NSManaged public var name: String?
    @NSManaged public var updatedAt: String?

}
