//
//  FaultingTableViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/30.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class FaultingTableViewController: UITableViewController {
    
    /*
        Faulting and Uniquing
     1. 메모리 효율을 증가 시키기 위해 Faulting 옵션을 체크할 수 있음
     --> Profile을 통해 확인할 수 있음
     --> 이 내용 어려우니까 강의 다시 한번 들어보기...
     2. Unique는 하나의 객체에 중복해서 데이터 저장을 방지한다는 것만 알아두면 됨
     --> iOS 자체적으로 처리해줌
     
     */
    
    var list = [NSManagedObject]()
    
    // Fault 확인 (1)
    @IBAction func fire(_ sender: Any) {
        list.forEach{
            // 필요없는 객체를 삭제하기 위해선 false를 리턴해줌
            DataManager.shared.mainContext.refresh($0, mergeChanges: false)
        }
    }
    
    // fetch 시 Faults object return을 막아서 메모리 효율 증대 (1)
    func fetchAllEmployee() -> [NSManagedObject]{
        let context = DataManager.shared.mainContext
        var list = [NSManagedObject]()
        
        context.performAndWait {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Employee")
            let sortByName = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sortByName]
            request.fetchLimit = 100
            
            // fault 속성 사용
            request.returnsObjectsAsFaults = false
            
            do{
                list = try context.fetch(request)
            }catch{
                fatalError(error.localizedDescription)
            }
        }
        
        return list
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        list = fetchAllEmployee()
        tableView.reloadData()
    }
}

extension FaultingTableViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let target = list[indexPath.row]
        cell.textLabel?.text = target.value(forKey: "name") as? String
        cell.detailTextLabel?.text = target.value(forKeyPath: "department.name") as? String
        
        return cell
    }
}
