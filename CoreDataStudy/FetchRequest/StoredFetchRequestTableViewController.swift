//
//  StoredFetchRequestTableViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/24.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class StoredFetchRequestTableViewController: UITableViewController {

    /*
     Fetch Request #3
    1. Core data modal에서 fetch request를 직접 생성해서 호출 할 수 있음
    --> Data Modal에서 Add Entity를 길게 누르면 나오는 서브메뉴에서 Fetch Request 신규 생성
    --> Entity는 Employee를 선택하고 salary is greather than or equal to 80000, Custom Predicate는 department.name BEGINSWITH $deptName 입력
    --> Custom predicate는 문법이 잘못되면 팝업창이 나옴
    2. Core data modal에서 fetch limit과 Batch size도 설정 가능
    --> 여기선 fetch limit을 100으로 설정해서 해당되는 조건의 최대 100개까지만 가져옴
    3. 설정한 fetch request 호출
    */
    
    var list = [NSManagedObject]()
    
    // Data modal로 설정한 fetch request 호출
    func fetch(){
        guard let model = DataManager.shared.container?.managedObjectModel else {
            fatalError("invalid model")
        }
        
        // 데이터 정렬을 하려면 아래의 메서드를 사용해야함
        guard let request = model.fetchRequestFromTemplate(withName: "highSalary", substitutionVariables: ["deptName" : "Dev"]) as? NSFetchRequest<NSManagedObject> else {
            fatalError("not found")
        }
        
        let sortBySalary = NSSortDescriptor(key: #keyPath(EmployeeEntity.salary), ascending: false)
        request.sortDescriptors = [sortBySalary]
        
        do{
            list = try DataManager.shared.mainContext.fetch(request)
            tableView.reloadData()
        }catch{
            print(error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetch()
    }
}

extension StoredFetchRequestTableViewController{
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
