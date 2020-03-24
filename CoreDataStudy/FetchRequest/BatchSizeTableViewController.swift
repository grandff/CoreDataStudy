//
//  BatchSizeTableViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/23.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class BatchSizeTableViewController: UITableViewController {

    /*
     Fetch Request #2
     1. 데이터 fetch시 batch size를 직접 지정할 수 있음
     2. 성능을 확인하려면 xcode product 메뉴에서 profile을 선택해서 시간 차이를 알 수 있음.
     
     */
    
    let context = DataManager.shared.mainContext
    var list = [NSManagedObject]()
    
    @IBAction func showType(_ sender: Any) {
        showTypeMenu()
    }
    
    // batch size 지정 후 데이터 fetch (1)
    func fetchWithBatchSize(){
        let request = NSFetchRequest<NSManagedObject>(entityName: "Employee")
        
        // batchsize 설정
        request.fetchBatchSize = 30     // 전체 중 30개 먼저
        
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortByName]
        
        do{
            list = try context.fetch(request)
            tableView.reloadData()
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    func fetchWithoutBatchSize(){
        let request = NSFetchRequest<NSManagedObject>(entityName: "Employee")
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortByName]
        
        do{
            list = try context.fetch(request)
            tableView.reloadData()
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension BatchSizeTableViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = list[indexPath.row].value(forKey: "name") as? String
        
        return cell
    }
}

extension BatchSizeTableViewController{
    func showTypeMenu(){
        let alert = UIAlertController(title: "Batch Size", message: "Select request type", preferredStyle: .alert)
        
        let menu1 = UIAlertAction(title: "Without Batch Size", style: .default) { (action) in
            self.fetchWithoutBatchSize()
        }
        alert.addAction(menu1)
        
        let menu2 = UIAlertAction(title: "With Batch Size", style: .default) { (action) in
            self.fetchWithBatchSize()
        }
        alert.addAction(menu2)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
}
