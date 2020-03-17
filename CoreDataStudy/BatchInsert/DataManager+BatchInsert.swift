//
//  DataManager+BatchInsert.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/17.
//  Copyright © 2020 kjm. All rights reserved.
//

import Foundation
import CoreData

extension DataManager{
    func insertDepartment(from data: DepartmentJSON, in context: NSManagedObjectContext) -> DepartmentEntity?{
        var entity : DepartmentEntity?
        context.performAndWait {
            entity = DepartmentEntity(context: context)
            entity?.name = data.name
        }
        return entity
    }
    
    func insertEmployee(from data: EmployeeJSON, in context : NSManagedObjectContext) -> EmployeeEntity?{
        var entity : EmployeeEntity?
        context.performAndWait {
            entity = EmployeeEntity(context: context)
            entity?.name = data.name
            entity?.age = Int16(data.age)
            entity?.address = data.address
            entity?.salary = NSDecimalNumber(integerLiteral: data.salary)
        }
        
        return entity
    }
}
