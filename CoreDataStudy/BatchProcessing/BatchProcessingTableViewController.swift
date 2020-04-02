//
//  BatchProcessingTableViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/04/02.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class BatchProcessingTableViewController: UITableViewController {
    /*
       Batch Processing
    1. extension으로 생성한 배치 메서드 호출
    2. Batch Update와 delete는 Context에 바로 접근해서 처리하기 때문에 데이터 리로드를 별도로 구현해줘야함
    */
    
    lazy var formatter : DateFormatter = {
       let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        f.locale = Locale(identifier: "en_US")
        return f
    }()
    
    lazy var resultController : NSFetchedResultsController<NSManagedObject> = {
        [weak self] in
        let request = NSFetchRequest<NSManagedObject>(entityName: "Task")
        let sortByName = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortByName]
        request.fetchBatchSize = 30
        
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: DataManager.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    @IBAction func showMenu(_ sender: Any) {
        showMenu()
    }
    
    // 만 개의 랜덤 데이터 생성
    func batchInsert(){
        DataManager.shared.batchInsert()
    }
    
    // Batch Update 메서드 호출 (1)
    func batchUpdate(){
        DataManager.shared.batchUpdate()
        // 데이터 리로드 (2)
        do{
            try self.resultController.performFetch()
            
            if let list = tableView.indexPathsForVisibleRows{
                tableView.reloadRows(at: list, with: .automatic)
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    // Batch Delete 메서드 호출 (1)
    func batchDelete(){
        DataManager.shared.batchDelete()
        // 데이터 리로드 (2)
        do{
            try self.resultController.performFetch()
            tableView.reloadData()
        }catch{
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            try resultController.performFetch()
        }catch{
            print(error.localizedDescription)
        }
    }
}

extension BatchProcessingTableViewController{
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
        cell.textLabel?.text = target.value(forKey: "task") as? String
        cell.detailTextLabel?.text = formatter.string(for: target.value(forKey: "date") as? Date)
        
        if let done = target.value(forKey: "done") as? Bool{
            cell.accessoryType = done ? .checkmark : .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let target = resultController.object(at: indexPath)
        if let done = target.value(forKey: "done") as? Bool{
            target.setValue(!done, forKey: "done")
        }
    }
}

extension BatchProcessingTableViewController : NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

extension BatchProcessingTableViewController{
    func showMenu(){
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let insertAction = UIAlertAction(title: "Batch Insert", style: .default) { (action) in
            self.batchInsert()
        }
        menu.addAction(insertAction)
        
        let updateAction = UIAlertAction(title: "Batch Update", style: .default) { (action) in
            self.batchUpdate()
        }
        menu.addAction(updateAction)
        
        let deleteAction = UIAlertAction(title: "Batch Delete", style: .destructive) { (action) in
            self.batchDelete()
        }
        menu.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        menu.addAction(cancelAction)
        
        if let pc = menu.popoverPresentationController, let btn = navigationItem.rightBarButtonItem{
            pc.barButtonItem = btn
            pc.sourceView = view
        }
        
        present(menu, animated: true, completion: nil)
    }
}
