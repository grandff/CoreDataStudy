//
//  DataManager+Person.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/15.
//  Copyright © 2020 kjm. All rights reserved.
//

import Foundation
import CoreData

extension DataManager{
    /*
        Create, Read, Update, Delete
     1. Core Data 기본 메서드를 생성해야함
     --> 파일이름은 보통 Entity 이름과 맞추는 편임
     2. 등록 Entity 메서드 추가
     --> saveContext가 정상적으로 됐는지 확인하기 위해 completion을 추가함
     --> Model에서 age는 optional value 이므로 optional 처리를 해줌
     3. 저장된 Entity를 불러오는 fetch 메서드 추가
     4. 수정 Entity 메서드 추가
     5. 삭제 Entity 메서드 추가
     */
    
    // 새로운 Entity 추가 메서드 (2)
    func createPerson(name : String, age : Int? = nil, completion : (() -> ())? = nil){
        mainContext.perform {
            let newPerson = PersonEntity(context: self.mainContext)
            newPerson.name = name
            if let age = age{
                newPerson.age = Int16(age)
            }
            
            self.saveMainContext()
            completion?()       // 정상적으로 등록된 후 completion 호출
        }
    }
    
    // 저장된 값을 가져오는 Fetch 메서드 (3)
    func fetchPerson() -> [PersonEntity]{
        var list = [PersonEntity]()
        
        // fetch는 동일한 스레드에서 처리해줘야함
        mainContext.performAndWait {
            let request : NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
            let sortByName = NSSortDescriptor(key: #keyPath(PersonEntity.name), ascending: true)
            request.sortDescriptors = [sortByName]
            
            do{
                list = try mainContext.fetch(request)
            }catch{
                print(error)
            }
        }
        
        return list
    }
    
    // Entity 수정 메서드 (4)
    func updatePerson(entity : PersonEntity, name : String, age : Int? = nil, completion : (() -> ())? = nil){
        mainContext.perform {
            entity.name = name
            if let age = age{
                entity.age = Int16(age)
            }
            
            self.saveMainContext()
            completion?()
        }
    }
    
    // Entity 삭제 메서드 (5)
    func delete(entity : PersonEntity){
        mainContext.perform {
            self.mainContext.delete(entity)
            self.saveMainContext()
        }
    }
    
}
