//
//  FetchLimitTableViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/04/07.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class FetchLimitTableViewController: UITableViewController {

    /*
       Performance and Debugging
    1. 데이터를 열개씩 보여주고 싶을 경우 list에 담아서 처리하는 거 보다 fetchlimit을 설정해서 가져오는게 좋음
    */
    
    lazy var formatter : NumberFormatter = {
       let f = NumberFormatter()
        f.locale = Locale(identifier: "en_US")
        f.numberStyle = .currency
        return f
    }()
    
    var list = [NSManagedObject]()
    
    func fetchTop10SalaryInNewYork(){
        let request = NSFetchRequest<NSManagedObject>(entityName: "Employee")
        let sortBySalary = NSSortDescriptor(key: "salary", ascending: false)
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortBySalary, sortByName]
        request.predicate = NSPredicate(format: "address CONTAINS 'NY'")
        
        // fetch limit 설정 (1)
        request.fetchLimit = 10
        
        do{
            // fetch를 통해 데이터를 가져오기 때문에 별도의 설정 없이 그대로 받으면 됨
            list = try DataManager.shared.mainContext.fetch(request)
            tableView.reloadData()
            
            // 원본 소스
            // let result = try DataManger.shared.mainContext.fetch(request)
            // list = Array(result[0..<10])
        }catch{
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTop10SalaryInNewYork()
    }
}

extension FetchLimitTableViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let target = list[indexPath.row]
        if let name = target.value(forKey: "name") as? String, let salary = target.value(forKey: "salary") as? Double, let str = formatter.string(for: salary){
            cell.textLabel?.text = "\(name) (\(str)"
        }
        
        cell.detailTextLabel?.text = target.value(forKey: "address") as? String
        
        return cell
    }
}
