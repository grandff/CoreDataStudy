//
//  BlobTableViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/31.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class BlobTableViewController: UITableViewController {

    /*
        BLOB
     1. 이미지 처럼 큰 파일을 저장할땐 별도의 처리를 해줘야함
     2. CORE DATA에 저장할 수도 있으나 성능저하가 발생할 수 있음
     3. 가장 이상적인 방법은 파일은 별도로 저장하고 CORE DATA에는 파일 경로만 저장하는게 좋음
     4. Data model에서 사진을 저장할 컬럼을 추가하고 Allows External Storage 옵션을 체크해줌
     --> 성능에 영향을 미칠만한 데이터인 경우 별도로 저장하게끔 해줌
     --> Faulting을 사용해 데이터가 불러와지는 시점을 제어할 수 있음
     5. 아래 코드는 샘플 코드를 그대로 사용한 거고 Migration 단계에서 더 상세히 다룸
     
     */
    
    lazy var resultController : NSFetchedResultsController<NSManagedObject> = {
        [weak self] in
        let request = NSFetchRequest<NSManagedObject>(entityName: "Employee")
        
        request.predicate = NSPredicate(format: "%K == %@", "department.name", "Development")
        
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortByName]
        request.fetchLimit = 50
        
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: DataManager.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self
        return controller
    }()
    
    // 사진 데이터 저장
    @IBAction func insertPhotoData(_ sender: Any) {
        if let list = resultController.fetchedObjects{
            for (index, data) in list.enumerated(){
                let name = "avatar\(index + 1)"
                guard let img = UIImage(named: name) else{
                    fatalError()
                }
                
                data.setValue(img.pngData(), forKey: "photo")
            }
        }
        
        DataManager.shared.saveMainContext()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            try resultController.performFetch()
        }catch{
            print(error.localizedDescription)
        }
    }
    
    deinit {
        resultController.delegate = nil
    }
}

extension BlobTableViewController{
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

extension BlobTableViewController : NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
