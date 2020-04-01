//
//  RDepartmentComposerTableViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/04/01.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class RDepartmentComposerTableViewController: UITableViewController {
    
    /*
       Entity Hierarchy and RelationShip
    1. 부서가 할당되어 있지 않는 직원을 relation ship을 활용해 해당 부서로 저장하는 메서드 생성
    */
    
    var department : DepartmentEntity?
    var list = [EmployeeEntity]()
        
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
        
    // 선택된 직원들 해당 부서로 저장 (1)
    @IBAction func save(_ sender: Any) {
        guard let targetDept = department else {
            fatalError()
        }
        
        // 선택된 employee를 department에 추가
        guard let selectedIndexPaths = tableView.indexPathsForSelectedRows else {
            fatalError()
        }
        
        // 선택된 데이터 필터링
        let selectedEmployees = selectedIndexPaths.map {list[$0.row]}
        
        for employee in selectedEmployees{
            targetDept.addToEmployees(employee)
            employee.department = targetDept
        }
        
        DataManager.shared.saveMainContext()
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        list = DataManager.shared.fetchNotAssignedEmployee()
        tableView.reloadData()
    }
}

extension RDepartmentComposerTableViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = list[indexPath.row].value(forKey: "name") as? String
        cell.detailTextLabel?.text = list[indexPath.row].value(forKey: "address") as? String
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
}
