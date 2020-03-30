//
//  FetchedResultsControllerTableViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/29.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class FetchedResultsControllerTableViewController: UITableViewController {

    /*
        Fetched Results Controller
     1. Fetched Results Controller를 사용해서 data fetch
     --> Fetch를 할때 Sort가 필수로 들어가야함
     2. 정렬 방식을 직접 변경할 수도 있음
     --> 이 경우 만약 캐시를 이미 사용했으면 Fetch 전에 캐시를 삭제해주는게 좋음(크래시 방지)
     3. Delegate 프로토클을 사용해 개별 컬럼의 CRUD 제어를 할 수 있음
     --> 참조 사이클 문제가 발생할 수 있으므로 deinit을 처음에 해줌
     */
    
    // Fetched results controller를 위한 fetch request 생성 (1)
    lazy var fetchRequest : NSFetchRequest<EmployeeEntity> = {
        let request = NSFetchRequest<EmployeeEntity>(entityName: "Employee")
        
        request.predicate = NSPredicate(format: "department != NIL")
        // fetched results의 경우 sort가 필수로 들어가야함
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        // seciont 정렬도 추가
        let sortByDeptName = NSSortDescriptor(key: "department.name", ascending: false)
        request.sortDescriptors = [sortByDeptName, sortByName]
        // 메모리 절약을 위해 fetch size 지정
        request.fetchBatchSize = 30
        
        return request
    }()
    
    // Fetched Results Controller 생성 (1)
    lazy var resultController : NSFetchedResultsController<EmployeeEntity> = {
        [weak self] in
        // 데이터를 특정 섹션별로 나누기 위해선 sectionNameKeyPath에서 지정해주면 됨. nil로 전달할 경우 그냥 fetch만 해줌
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataManager.shared.mainContext, sectionNameKeyPath: #keyPath(EmployeeEntity.department.name), cacheName: "CacheByDeptName")
        controller.delegate = self
        return controller
    }()
    
    @IBAction func showMenu(_ sender: Any) {
        showMenu()
    }
    
    // Fetched Results Controller Change Sort Order (2)
    func changeSortOrder(){
        // 크래시 방지를 위한 캐시 삭제
        NSFetchedResultsController<EmployeeEntity>.deleteCache(withName: resultController.cacheName)
        
        let sortByDeptName = NSSortDescriptor(key: "department.name", ascending: false)
        let sortBySalary = NSSortDescriptor(key: "salary", ascending: true)
        resultController.fetchRequest.sortDescriptors = [sortByDeptName, sortBySalary]
        
        do{
            try resultController.performFetch()
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
    
    // 참조 사이클 방지 (3)
    deinit {
        resultController.delegate = nil
    }
}

extension FetchedResultsControllerTableViewController{
    override func numberOfSections(in tableView: UITableView) -> Int {
        return resultController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = resultController.sections else {return 0}
        let sectionInfo = sections[section]
        // 해당 섹션의 rows를 알려면 numberOfObjects를 확인하면 됨
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let target = resultController.object(at: indexPath)
        cell.textLabel?.text = target.name
        cell.detailTextLabel?.text = target.department?.name
        
        return cell
    }
    
    // 섹션 구분을 위한 헤더 추가
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return resultController.sections?[section].name
    }
    
    // 섹션을 쉽게 구분하기 위해 인덱스 추가
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return resultController.sectionIndexTitles
    }
}

extension FetchedResultsControllerTableViewController{
    func showMenu(){
        let alert = UIAlertController(title: "Fetched Results Controller", message: nil, preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add Employee", style: .default) { (action) in
            let context = DataManager.shared.mainContext
            
            let newEmployee = NSEntityDescription.insertNewObject(forEntityName: "Employee", into: context)
            newEmployee.setValue("Aaden Smith", forKey: "name")
            newEmployee.setValue(50, forKey: "age")
            
            DataManager.shared.saveMainContext()
        }
        alert.addAction(addAction)
        
        let deleteAction = UIAlertAction(title: "Delete Employee", style: .destructive) { (action) in
            let context = DataManager.shared.mainContext
            
            let request = NSFetchRequest<NSManagedObject>(entityName: "Employee")
            request.fetchLimit = 1
            
            let filterByName = NSPredicate(format: "name == %@", "Aaden Smith")
            request.predicate = filterByName
            
            let sortByName = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sortByName]
            
            do{
                if let first = try context.fetch(request).first {
                    context.delete(first)
                    DataManager.shared.saveMainContext()
                }
            }catch{
                print(error.localizedDescription)
            }
        }
        alert.addAction(deleteAction)
        
        let changeSortOrderAction = UIAlertAction(title: "Change Sort Order", style: .default) { (action) in
            self.changeSortOrder()
        }
        alert.addAction(changeSortOrderAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

// Delegate 프로토콜을 사용해 개별 셀 업데이트 제어 (3)
extension FetchedResultsControllerTableViewController : NSFetchedResultsControllerDelegate{
    
    // 효율을 높이기 위해 batch 사이즈만큼만 리턴(업데이트 될 경우에만 호출됨)
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    // 개별 업데이트가 발생될때마다 호출
    // 업데이트 된 셀만 개별적으로 처리해줌
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // type에 따라 업데이트
        switch type {
        case .insert:
            if let insertIndexPath = newIndexPath{
                tableView.insertRows(at: [insertIndexPath], with: .automatic)
            }
        case .delete:
            if let deleteIndexPath = indexPath{
                tableView.deleteRows(at: [deleteIndexPath], with: .fade)
            }
        case .update:
            if let updateIndexPath = indexPath{
                tableView.reloadRows(at: [updateIndexPath], with: .fade)
            }
        case .move:
            if let originalIndexPath = indexPath, let targetIndexPath = newIndexPath{
                tableView.moveRow(at: originalIndexPath, to: targetIndexPath)
            }
        default:
            break
        }
    }
    
    // 섹션이 업데이트 될때마다 호출
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    // 데이터가 변경됐을 때 호출
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
