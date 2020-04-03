//
//  ConcurrencyTopicListTableViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/04/03.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class ConcurrencyTopicListTableViewController: UITableViewController {
    
    // 저장된 데이터 삭제
    @IBAction func reset(_ sender: Any) {
        let context = DataManager.shared.mainContext
        let entityNames = ["Task", "Employee", "Department"]
        for name in entityNames{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
            
            let delete = NSBatchDeleteRequest(fetchRequest: request)
            delete.resultType = .resultTypeCount
            
            do{
                if let result = try context.execute(delete) as? NSBatchDeleteResult, let cnt = result.result as? Int{
                    print("Deleted : \(name), \(cnt)")
                }
            }catch{
                print(error)
            }
        }
    }
}
