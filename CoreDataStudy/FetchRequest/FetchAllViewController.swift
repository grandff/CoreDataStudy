//
//  FetchAllViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/20.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class FetchAllViewController: UITableViewController {
    /*
        Fetch Request #1
     1. Fetch로 데이터 받는 방법엔 총 4가지가 있음
     --> #1에선 3번까지만 공부해봄.
     --> 1) entity 인스턴스를 직접 만들어서 호출
     let request = NSFetchRequest<NSManagedObject>()
     let entity = NSEntityDescription.entity(forEntityName : "Employee", in : context)
     request.entity = entity
     --> 2) 생성자로 entity 이름 전달
     let request = NSFetchRequest<NSManagedObject>(entityName : "Employee")
     --> 여기선 3번 방법을 사용함
     
     */
    
    var list = [NSManagedObject]()
    
    // fetch request (1)
    @IBAction func fetch(_ sender: Any?) {
        let context = DataManager.shared.mainContext
        let request : NSFetchRequest<EmployeeEntity> = EmployeeEntity.fetchRequest()
        
        do{
            list = try context.fetch(request)       // try 필수
            tableView.reloadData()
            print("ang")
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ang???")
        fetch(nil)
    }
}

extension FetchAllViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = list[indexPath.row].value(forKey: "name") as? String
        
        return cell
    }
}
