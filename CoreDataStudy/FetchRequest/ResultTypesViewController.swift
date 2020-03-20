//
//  ResultTypesViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/20.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class ResultTypesViewController: UIViewController {

    /*
        Fetch Request #1
    1. fetch 시 리턴 타입을 정할 수 있음
        
    */
    
    let context = DataManager.shared.mainContext
    
    // Managed Object Return (1)
    @IBAction func fetchManagedObject(_ sender: Any) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Employee")
        
        request.resultType = .managedObjectResultType
        
        do{
            let list = try context.fetch(request)
            if let first = list.first{
                print(type(of: first))
                print(first)
            }
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    // Count Return (1)
    @IBAction func fetchCount(_ sender: Any) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Employee")
        request.resultType = .countResultType
        
        do{
            let list = try context.fetch(request)
            if let first = list.first{
                print(type(of: first))
                print(first)
            }
            
            // 카운트만 필요하다면 아래처럼 사용하는게 좋음
            let cnt = try context.count(for: request)
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    // Dictionary Return (1)
    @IBAction func fetchDictionary(_ sender: Any) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Emplyee")
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = ["name", "address"]
        
        do{
            let list = try context.fetch(request)
            if let first = list.first{
                print(type(of: first))
                print(first)
            }
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    // Managed Object Id Return (1)
    @IBAction func fetchManagedObjectId(_ sender: Any) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Employee")
        request.resultType = .managedObjectIDResultType
        
        do{
            let list = try context.fetch(request)
            if let first = list.first{
                print(type(of: first))
                print(first)
            }
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
