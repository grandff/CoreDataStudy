//
//  FetchedPropertyTableViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/24.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class FetchedPropertyTableViewController: UITableViewController {

    /*
     Fetch Request #3
    1. Core data model에서 Fetched Properties설정을 통해 데이터 fetch 조건 설정
    --> 해당 부서의 3만 이하만 보이도록 Department entity에서 Fetched Properties 추가
    --> Predicate는 salary <= 30000, 해당 property의 destination은 employee로 설정
    2. fetch 메서드 구현
    --> class definition으로 설정을 해도 relationship을 자동으로 연결해주지 않으므로 직접 연결해줘야함
    */
    
    var list = [NSManagedObject]()
    
    // data fetch (2)
    func fetch(){
        let request = NSFetchRequest<NSManagedObject>(entityName: "Department")
        request.fetchLimit = 1
        
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortByName]
        
        if let model = DataManager.shared.container?.managedObjectModel, let entity = model.entitiesByName["Department"], let property = entity.propertiesByName["lowSalary"] as? NSFetchedPropertyDescription, let fetchRequest = property.fetchRequest{
            let sortBySalary = NSSortDescriptor(key: #keyPath(EmployeeEntity.salary), ascending: true)
            fetchRequest.sortDescriptors = [sortBySalary]
        }
        
        do{
            if let first = try DataManager.shared.mainContext.fetch(request).first as? DepartmentEntity{
                navigationItem.title = first.name
                list = first.value(forKey: "lowSalary") as! [NSManagedObject]
            }
            tableView.reloadData()
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetch()
    }
}

extension FetchedPropertyTableViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let target = list[indexPath.row]
        if let name = target.value(forKey: "name") as? String, let deptName = target.value(forKeyPath: "department.name") as? String{
            cell.textLabel?.text = "\(name)\n\(deptName)"
        }
        
        cell.detailTextLabel?.text = "$\((target.value(forKey: "salary") as? Int) ?? 0)"
        
        return cell
    }
}
