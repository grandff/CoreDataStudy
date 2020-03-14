//
//  Person+CoreDataProperties.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/14.
//  Copyright © 2020 kjm. All rights reserved.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var name: String?
    @NSManaged public var age: Int16

}
