//
//  ChildContextTableViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/04/03.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class ChildContextTableViewController: UITableViewController {

    /*
        Concurrency
     1. parent context와 연결 시 별도의 Notification 전달 없이 reload 가능
     2. parent와 직접 연결한 경우 parent에서 저장을 해줘야함
     --> batch method에서 수정
     */
    
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
    
    // Parent context와 연결 (1)
    @IBAction func insertData(_ sender: Any) {
        // 생성자를 통해 background context 생성
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        // child와 parent context 연결
        context.parent = DataManager.shared.mainContext
        DataManager.shared.batchInsertConcurrency(in: context)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
           try resultController.performFetch()
        } catch {
           print(error.localizedDescription)
        }
    }

    deinit {
       resultController.delegate = nil
    }
}

extension ChildContextTableViewController {
   override func numberOfSections(in tableView: UITableView) -> Int {
      return resultController.sections?.count ?? 0
   }
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      guard let sections = resultController.sections else { return 0 }
      let sectionInfo = sections[section]
      return sectionInfo.numberOfObjects
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
      
      let target = resultController.object(at: indexPath)
      cell.textLabel?.text = target.value(forKey: "name") as? String
      cell.detailTextLabel?.text = target.value(forKey: "address") as? String
      
      if let data = target.value(forKey: "photo") as? Data {
         cell.imageView?.image = UIImage(data: data)
      }
      
      return cell
   }
}


extension ChildContextTableViewController: NSFetchedResultsControllerDelegate {
   func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      tableView.reloadData()
   }
}
