//
//  PartialFaultingTableViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/04/07.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class PartialFaultingTableViewController: UITableViewController {

    /*
       Performance and Debugging
    1. 메모리 절약을 위해 Partial Faulting 추가
    -> 프로파일을 통해 메모리 성능 향상을 확인할 수 있음
    -> 프로파일의 Allocation을 추가해 확인 가능
    */
    
    lazy var resultController : NSFetchedResultsController<NSManagedObject> = {
       [weak self] in
        let request = NSFetchRequest<NSManagedObject>(entityName: "Employee")
        
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortByName]
        // partial faulting 추가
        request.propertiesToFetch = ["name"]
        
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

extension PartialFaultingTableViewController{
    override func numberOfSections(in tableView: UITableView) -> Int {
        return resultController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = resultController.sections else {
            return 0
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let target = resultController.object(at: indexPath)
        cell.textLabel?.text = target.value(forKey: "name") as? String
        
        return cell
    }
}

extension PartialFaultingTableViewController : NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
