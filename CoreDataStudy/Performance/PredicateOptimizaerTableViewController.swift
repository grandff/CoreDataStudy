//
//  PredicateOptimizaerTableViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/04/07.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class PredicateOptimizaerTableViewController: UITableViewController {

    /*
        Performance and Debugging
     1. Core Data Debugging을 위해 스키마 설정
     -> 왼쪽 상단의 앱 이름을 클릭 해서 Edit Scheme 접속
     -> arguments에는
     -com.apple.CoreData.SQLDebug 1
     -com.apple.CoreData.ConcurrencyDebug 1
     환경변수에는
     SQLITE_ENALBE_THREAD_ASSERTIONS (1)
     SQLITE_ENABLE_FILE_ASSERTIONS (1)
     -> 대부분의 앱은 sqldebug로도 디버깅하는데 문제 없음
     -> 뒤의 숫자는 높을수록 디버깅이 상세하게 출력됨
     2. 성능 향상을 위해 Predicate 수정
     -> LIKE, * 같은 구문들은 굉장히 높은 자원을 요구하므로 자제하는게 좋음
     */
    
    lazy var resultController : NSFetchedResultsController<NSManagedObject> = {
       [weak self] in
        let request = NSFetchRequest<NSManagedObject>(entityName: "Employee")
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortByName]
        // 성능 향상을 위한 Predicate (2)
        request.predicate = NSPredicate(format: "salary >= 50000 AND name BEGINSWITH 'A' AND address CONTAINS 'NY'")
        // 기존 Predicate 확인
        // address LIKE '*NY*' AND name LIKE 'A*' AND salary >= 50000
        
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: DataManager.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    @IBAction func fetch(_ sender: Any) {
        DataManager.shared.mainContext.reset()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            try resultController.performFetch()
            tableView.reloadData()
        }catch{
            print(error.localizedDescription)
        }
    }
}

extension PredicateOptimizaerTableViewController{
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
        
        return cell
    }
}

extension PredicateOptimizaerTableViewController : NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
