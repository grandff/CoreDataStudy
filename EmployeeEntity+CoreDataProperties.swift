//
//  EmployeeEntity+CoreDataProperties.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/04/01.
//  Copyright © 2020 kjm. All rights reserved.
//
//

import Foundation
import CoreData


extension EmployeeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EmployeeEntity> {
        return NSFetchRequest<EmployeeEntity>(entityName: "Employee")
    }

    @NSManaged public var photo: Data?
    @NSManaged public var salary: NSDecimalNumber?
    @NSManaged public var department: DepartmentEntity?

}
