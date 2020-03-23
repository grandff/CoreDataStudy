//
//  PagingViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/23.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class PagingViewController: UIViewController {

    /*
     Fetch Request #2
     1. 일반 게시판처럼 페이징 기능 구현
     
     */
    
    let context = DataManager.shared.mainContext
    var offset = 0
    
    var list = [NSManagedObject]()
    
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var pageLabel: UILabel!
    
    @IBAction func prev(_ sender: Any) {
        offset = max(offset, -1, 0)
        fetch()
    }
        
    @IBAction func next(_ sender: Any) {
        offset = offset + 1
        fetch()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetch()
    }
    
    // paging 기능 구현 (1)
    func fetch(){
        let request = NSFetchRequest<NSManagedObject>(entityName: "Employee")
        
        // paging 구현
        request.fetchLimit = 10
        request.fetchOffset = offset
        
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortByName]
        
        do{
            list = try context.fetch(request)
            listTableView.reloadData()
            pageLabel.text = "\(offset+1)"
        }catch{
            fatalError(error.localizedDescription)
        }
        
    }
}

extension PagingViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = list[indexPath.row].value(forKey: "name") as? String
        
        return cell
    }
}
