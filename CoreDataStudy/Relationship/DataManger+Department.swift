//
//  DataManger+Department.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/04/01.
//  Copyright © 2020 kjm. All rights reserved.
//

import Foundation
import CoreData

extension DataManager{
    func fetchDepartment() -> [DepartmentEntity]{
        var list = [DepartmentEntity]()
        
        mainContext.performAndWait {
            let request : NSFetchRequest<DepartmentEntity> = DepartmentEntity.fetchRequest()
            
            let sortByName = NSSortDescriptor(key: #keyPath(DepartmentEntity.name), ascending: true)
            request.sortDescriptors = [sortByName]
            
            do{
                list = try mainContext.fetch(request)
            }catch{
                fatalError(error.localizedDescription)
            }
        }
        
        return list
    }
}
