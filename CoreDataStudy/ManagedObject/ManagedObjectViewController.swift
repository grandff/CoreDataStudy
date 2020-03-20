//
//  ManagedObjectViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/15.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit

class ManagedObjectViewController: UIViewController {

    /*
        Create, Read, Update, Delete
     1. 목록화면에서 core data를 받을 list 생성
     --> 기본적인 table view delegate와 datasource는 만들어놓음
     2. 목록화면 진입 혹은 CRUD시 Notification을 통해 목록을 업데이트
     --> Compose VC에 Observer를 추가해줘야함
     3. 셀 선택 시 편집이 가능하도록 구현
     */
    
    var token : NSObjectProtocol!
    @IBOutlet weak var listTableView: UITableView!
    // 데이터 받을 list (1)
    var list = [PersonEntity]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // list reload (2)
        list = DataManager.shared.fetchPerson()
        listTableView.reloadData()
        
        token = NotificationCenter.default.addObserver(forName: PersonComposeViewController.newPersonDidInsert, object: nil, queue: .main, using: { [weak self] (noti) in
            self?.list = DataManager.shared.fetchPerson()
            self?.listTableView.reloadData()
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(token)
    }    
}

extension ManagedObjectViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let person = list[indexPath.row]
        cell.textLabel?.text = person.name
        cell.detailTextLabel?.text = "\(person.age)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let person = list.remove(at: indexPath.row)
            DataManager.shared.delete(entity: person)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            break
        }
    }
}

extension ManagedObjectViewController : UITableViewDelegate{
    // 셀 선택 시 편집 기능 (3)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = list[indexPath.row]
        if let nav = storyboard?.instantiateViewController(withIdentifier: "ComposeNav") as? UINavigationController, let composeVC = nav.viewControllers.first as? PersonComposeViewController{
            composeVC.target = person
            present(nav, animated: true, completion: nil)
        }
    }
}
