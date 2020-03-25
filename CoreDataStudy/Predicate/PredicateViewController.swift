//
//  PredicateViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/25.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class PredicateViewController: UIViewController {

    /*
        Predicate
     1. 데이터 fetch시 조건을 정해서 데이터를 가져올 수 있음
     2. 각 컬럼 별로 검색 조건 구현
     */
    
    var list = [NSManagedObject]()
        
    @IBOutlet weak var listTableView: UITableView!
    
    // 이름으로 검색 (2)
    func searchByName(_ keyword : String?){
        guard let keyword = keyword else{return}
        // predicate
        // %@이 keyword로 대체됨
        // [c]를 추가하면 대소문자 구분을 안함
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", keyword)
        fetch(predicate: predicate)
    }
    
    // 나이 범위 검색 (2)
    func searchByMinimumAge(_ keyword : String?){
        guard let keyword = keyword, let age = Int(keyword) else {return}
        
        // 오타를 방지하기 위해 이름 검색과는 다르게 구현함
        let predicate = NSPredicate(format: "%K >= %d", #keyPath(EmployeeEntity.age), age)
        fetch(predicate: predicate)
    }
    
    // 연봉 범위 검색 (2)
    // 30000-70000 형태로 입력 받음
    func searchBySalaryRange(_ keyword : String?){
        guard let keyword = keyword else {return}
        let comps = keyword.components(separatedBy: "-")
        guard comps.count == 2, let min = Int(comps[0]), let max = Int(comps[1]) else {return}
        // 배열을 통해 최소, 최댓값을 전달
        let predicate = NSPredicate(format: "%K BETWEEN {%d, %d}", #keyPath(EmployeeEntity.salary), min, max)
        fetch(predicate: predicate)
    }
    
    // 부서 이름으로 검색 (2)
    func searchByDeptName(_ keyword : String?){
        guard let keyword = keyword else {return}
        // relationship으로 연결했기 때문에 employee에서 department를 검색할 수 있음
        let predicate = NSPredicate(format: "%K BEGINSWITH[c] %@", #keyPath(EmployeeEntity.department.name), keyword)
        fetch(predicate: predicate)
    }
    
    // fetch시 predicate 조건을 통해 데이터 가져옴 (1)
    func fetch(predicate : NSPredicate? = nil){
        let request = NSFetchRequest<NSManagedObject>(entityName: "Employee")
        
        // predicate
        request.predicate = predicate
        
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortByName]
        
        do{
            list = try DataManager.shared.mainContext.fetch(request)
            listTableView.reloadData()
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetch()
    }
}

extension PredicateViewController : UISearchBarDelegate{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        fetch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        switch searchBar.selectedScopeButtonIndex{
        case 0:
            searchByName(searchBar.text)
        case 1:
            searchByMinimumAge(searchBar.text)
        case 2:
            searchBySalaryRange(searchBar.text)
        case 3:
            searchByDeptName(searchBar.text)
        default :
            fatalError()
        }
        
    }
}

extension PredicateViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let target = list[indexPath.row]
        if let name = target.value(forKey: "name") as? String, let age = target.value(forKey: "age") as? Int, let departmentName = target.value(forKeyPath: "department.name") as? String{
            cell.textLabel?.text = "\(name)(\(age))\n\(departmentName)"
        }
        
        if let salary = target.value(forKey: "salary") as? Int{
            cell.detailTextLabel?.text = "$ \(salary)"
        }
        
        return cell
    }
    
    
}
