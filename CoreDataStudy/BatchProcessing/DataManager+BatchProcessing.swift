//
//  DataManager+BatchProcessing.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/04/02.
//  Copyright © 2020 kjm. All rights reserved.
//

import Foundation
import CoreData

extension DataManager{
    /*
        Batch Processing
     1. batch update와 delete 메서드 구현
     --> 새로운 entity를 추가하고 해당 컬럼 추가하기. 여기선 이름을 Task로 정함.
     --> Optional은 다 체크 해제 해줌     
     */
    
    // Batch Update 구현 (1)
    func batchUpdate(){
        let update = NSBatchUpdateRequest(entityName: "Task")
        // Batch Update에서 제일 중요한 부분임. 업데이트할 데이터를 딕셔너리 형식으로 전달해야함.
        update.propertiesToUpdate = [#keyPath(TaskEntity.done) : true]
        update.predicate = NSPredicate(format: "%K == NO", #keyPath(TaskEntity.done))
        update.resultType = .updatedObjectsCountResultType  // 3개의 resultType 중 Update된 카운트를 리턴해주는 거 사용
        
        do{
            if let result = try mainContext.execute(update) as? NSBatchUpdateResult, let cnt = result.result as? Int{
                print("Updated : \(cnt)")
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    // Batch Delete 구현 (1)
    func batchDelete(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        request.predicate = NSPredicate(format: "%K == YES", #keyPath(TaskEntity.done))
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        delete.resultType = .resultTypeCount
        
        do{
            if let result = try mainContext.execute(delete) as? NSBatchDeleteResult, let cnt = result.result as? Int{
                print("Deleted : \(cnt)")
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    // 만 개의 랜덤데이터 batch
    func batchInsert(){
        mainContext.perform {
            for index in 0 ..< 10_000{
                let newTask = TaskEntity(context : self.mainContext)
                newTask.task = "Task \(index + 1)"
                newTask.date = Date().addingTimeInterval(TimeInterval(3600 * 24 * Int.random(in: -365 ... 365)))
                
                if index % 1_000 == 0{
                    do{
                        try self.mainContext.save()
                    }catch{
                        print(error.localizedDescription)
                    }
                }
            }
            
            do{
                try self.mainContext.save()
                print("Inserted")
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
}
