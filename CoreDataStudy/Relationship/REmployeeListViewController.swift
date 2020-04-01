//
//  REmployeeListViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/04/01.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class REmployeeListViewController: UIViewController {
    
    /*
        Entity Hierarchy and RelationShip
     1. Relationship을 사용해서 부서에 할당되지 않은 직원들 추가하기
     --> 부모 뷰에서 부서이름을 가져온 후 해당 부서이름으로 직원 조회
     2. Relationship을 통해 삭제 기능도 구현
     */
    
    var department : DepartmentEntity?
    var list = [EmployeeEntity]()
    
    @IBOutlet weak var listTableView: UITableView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController, let vc = nav.viewControllers.first as? RDepartmentComposerTableViewController{
            vc.department = department
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 해당 부서의 직원 목록 확인 (1)
        guard let employeeList = department?.employees?.allObjects as? [EmployeeEntity] else {return}
        
        // 이름순으로 배열 정렬 후 reload
        list = employeeList.sorted{$0.name! < $1.name!}
        listTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 해당 부서의 직원 목록 확인 (1)
        guard let employeeList = department?.employees?.allObjects as? [EmployeeEntity] else {return}
        
        // 이름순으로 배열 정렬 후 reload
        list = employeeList.sorted{$0.name! < $1.name!}
        listTableView.reloadData()
    }
}

extension REmployeeListViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let employee = list[indexPath.row]
        cell.textLabel?.text = employee.name
        cell.detailTextLabel?.text = employee.address
        
        return cell
    }
    
    // 등록된 직원 삭제 처리 (2)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            // 데이터 제거
            guard let dept = department else {fatalError()}
            let employee = list[indexPath.row]
            
            // relation ship이 걸려 있으면 양쪽 다 삭제해줘야함
            // department에서 employee 제거
            dept.removeFromEmployees(employee)
            // employee에서 department 제거
            employee.department = nil
            
            DataManager.shared.saveMainContext()
            
            // list, cell 삭제
            list.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            break
        }
    }
}
