//
//  PrefetchingTableViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/04/07.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class PrefetchingTableViewController: UITableViewController {

    /*
       Performance and Debugging
    1. 가져올 컬럼을 미리 읽어서 성능 향상 (prefetching 사용)
    */
    
    lazy var resultController : NSFetchedResultsController<NSManagedObject> = {
       [weak self] in
        let request = NSFetchRequest<NSManagedObject>(entityName: "Employee")
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortByName]
        request.predicate = NSPredicate(format: "department != nil")
        // 부서이름 prefetching (1)
        request.relationshipKeyPathsForPrefetching = ["department.name"]
        
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: DataManager.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            try resultController.performFetch()
        }catch{
            print(error.localizedDescription)
        }
    }
}

extension PrefetchingTableViewController{
    override func numberOfSections(in tableView: UITableView) -> Int {
        return resultController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = resultController.sections else {return 0}
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let target = resultController.object(at: indexPath)
        cell.textLabel?.text = target.value(forKey: "name") as? String
        cell.detailTextLabel?.text = target.value(forKeyPath: "department.name") as? String
        
        return cell
    }
}

extension PrefetchingTableViewController : NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
