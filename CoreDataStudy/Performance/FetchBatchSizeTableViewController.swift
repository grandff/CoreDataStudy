//
//  FetchBatchSizeTableViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/04/07.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class FetchBatchSizeTableViewController: UITableViewController {

    /*
       Performance and Debugging
    1. batch size를 결정해서 core data 성능 향상
    -> iOS에서 가져올 데이터를 알아서 지정하므로 별도의 페이징 처리는 필요 없음
    */
    
    lazy var resultController : NSFetchedResultsController<NSManagedObject> = {
       [weak self] in
        let request = NSFetchRequest<NSManagedObject>(entityName: "Employee")
        
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortByName]
        
        // batch size 설정 (1)
        request.fetchBatchSize = 30
        
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

extension FetchBatchSizeTableViewController{
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
        
        return cell
    }
}

extension FetchBatchSizeTableViewController : NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
