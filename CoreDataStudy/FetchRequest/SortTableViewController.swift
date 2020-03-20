//
//  SortTableViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/20.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class SortTableViewController: UITableViewController {

    /*
           Fetch Request #1
    1. fetch 시 데이터 정렬을 해서 받을 수 있음
     --> sortdescriptors의 경우 무조건 배열로 받음
     --> 데이터가 없을 경우 에러가 날 수 있으므로 keypath를 사용하는게 좋음
        
    */
    var list = [NSManagedObject]()
    
    @IBAction func showMenu(_ sender: Any) {
        showSortMenu()
    }
    
    // 이름 오름차순 정렬 (1)
    func sortByNameASC(){
        let sortByNameASC = NSSortDescriptor(key: "name", ascending: true)
        fetch(sortDescriptors: [sortByNameASC])
    }
    
    // 이름 내림차순 정렬 (1)
    func sortByNameDESC(){
        let sortByNameDESC = NSSortDescriptor(key: #keyPath(EmployeeEntity.name), ascending: false)
        fetch(sortDescriptors: [sortByNameDESC])
    }
    
    // 나이 오름차순, 연봉 내림차순 (1)
    func sortByAgeThenBySalary(){
        let sortByAge = NSSortDescriptor(key: #keyPath(EmployeeEntity.age), ascending: true)
        let sortBySalary = NSSortDescriptor(key: #keyPath(EmployeeEntity.salary), ascending: false)
        
        fetch(sortDescriptors: [sortByAge, sortBySalary])
    }
    
    func fetch(sortDescriptors : [NSSortDescriptor]? = nil){
        let request = NSFetchRequest<NSManagedObject>(entityName: "Employee")
        request.sortDescriptors = sortDescriptors
        
        do{
            list = try DataManager.shared.mainContext.fetch(request)
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

extension SortTableViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let target = list[indexPath.row]
        if let name = target.value(forKey: "name") as? String, let salary = target.value(forKey: "salary") as? Int{
            cell.textLabel?.text = "[$\(salary)] \(name)"
        }
        
        if let age = target.value(forKey: "age") as? Int{
            cell.detailTextLabel?.text = "\(age)"
        }
        
        return cell
    }
}

extension SortTableViewController{
    func showSortMenu(){
        let alert = UIAlertController(title: "Sort", message: "Select sort type", preferredStyle: .alert)
        
        let nameASC = UIAlertAction(title: "name ASC", style: .default) { (action) in
            self.sortByNameASC()
        }
        alert.addAction(nameASC)
        
        let nameDESC = UIAlertAction(title: "name DESC", style: .default) { (action) in
            self.sortByNameDESC()
        }
        alert.addAction(nameDESC)
        
        let ageAndSalary = UIAlertAction(title: "age ASC salary DESC", style: .default) { (action) in
            self.sortByAgeThenBySalary()
        }
        alert.addAction(ageAndSalary)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
}
