//
//  BackgroundTaskTableViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/04/03.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class BackgroundTaskTableViewController: UITableViewController {
    
    /*
        Concurrency
     1. Background에서 batch insert 실행
     2. Background에서 처리 시 다른 컨텍스트에서 처리하므로 data reload는 직접 구현해줘야함
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

    // background task (1)
    @IBAction func insertData(_ sender: Any) {
        DataManager.shared.container?.performBackgroundTask({ (context) in
            DataManager.shared.batchInsertConcurrency(in: context)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            try resultController.performFetch()
        }catch{
            print(error.localizedDescription)
        }
        
        // Batch 완료 시 테이블 데이터 리로드를 위한 Notification 생성 (2)
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

extension BackgroundTaskTableViewController{
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

extension BackgroundTaskTableViewController : NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
