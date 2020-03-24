//
//  AsyncFetchingTableViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/24.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class AsyncFetchingTableViewController: UITableViewController {

    /*
    Fetch Request #2
    1. 비동기로 데이터 fetch 가능
    */
    
    var list = [NSManagedObject]()
        
    // 비동기로 데이터 fetch (1)
    @IBAction func fetch(_ sender: Any?) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Employee")
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortByName]
        
        // async fetch request
        let asyncRequest = NSAsynchronousFetchRequest<NSManagedObject>(fetchRequest: request) { (result) in
            guard let list = result.finalResult else {return}
            self.list = list
            self.tableView.reloadData()
        }
        
        do{
            try DataManager.shared.mainContext.execute(asyncRequest)
            tableView.reloadData()
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetch(nil)
        tableView.reloadData()
    }
}

extension AsyncFetchingTableViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = list[indexPath.row].value(forKey: "name") as? String
        return cell
    }
}
