//
//  BackgroundContextTableViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/04/03.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class BackgroundContextTableViewController: UITableViewController {

    /*
        Concurrency
     1. Background Context에 접근해서 batch insert를 할 수 있음
     --> 이 경우 메인 스레드에서 실행햐애하므로, perform, performandwait를 사용해야함
     --> 마찬가지로 Notification을 통해 reload
     
     */
    
    var token : NSObjectProtocol!
    
    lazy var resultController : NSFetchedResultsController<NSManagedObject> = {
        [weak self] in
        let request = NSFetchRequest<NSManagedObject>(entityName: "Employee")
        
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortByName]
        request.fetchBatchSize = 30
        
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: DataManager.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    // Background Context 접근 후 Batch (1)
    @IBAction func insertData(_ sender: Any) {
        let context = DataManager.shared.backgroundContext
        DataManager.shared.batchInsertConcurrency(in: context)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            try resultController.performFetch()
        }catch{
            print(error.localizedDescription)
        }
        
        token = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave, object: nil, queue: OperationQueue.main, using: { (noti) in
            DataManager.shared.mainContext.mergeChanges(fromContextDidSave: noti)
        })
    }
    
    deinit {
        if let token = token{
            NotificationCenter.default.removeObserver(token)
        }
        
        resultController.delegate = nil
    }
}

extension BackgroundContextTableViewController{
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
        cell.detailTextLabel?.text = target.value(forKey: "address") as? String
        
        if let data = target.value(forKey: "photo") as? Data{
            cell.imageView?.image = UIImage(data: data)
        }
        
        return cell
    }
}

extension BackgroundContextTableViewController : NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
