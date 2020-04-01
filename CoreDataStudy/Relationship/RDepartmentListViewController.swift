//
//  RDepartmentListViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/04/01.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class RDepartmentListViewController: UIViewController {

    @IBOutlet weak var listTableview: UITableView!
    var list = [DepartmentEntity]()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell, let indexPath = listTableview.indexPath(for: cell){
            if let vc = segue.destination as? REmployeeListViewController{
                vc.department = list[indexPath.row]
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        list = DataManager.shared.fetchDepartment()
        listTableview.reloadData()
    }
}

extension RDepartmentListViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let dept = list[indexPath.row]
        cell.textLabel?.text = dept.name
        cell.detailTextLabel?.text = "\(dept.employees?.count ?? 0)"
        
        return cell
    }
}
