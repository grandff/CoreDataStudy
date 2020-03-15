//
//  PersonComposeViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/15.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class PersonComposeViewController: UIViewController {

    /*
        Create, Read, Update, Delete
     1. 등록과 수정에 따른 제목 및 UI 설정
     2. 등록과 수정에 따른 Core Data Action 처리
     */
    
    static let newPersonDidInsert = Notification.Name(rawValue: "newPersonDidInsert")
    var target : NSManagedObject?
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    
    @IBAction func cancelCompose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        guard let name = nameField.text else {return}
        
        var age : Int?
        if let ageStr = ageField.text, let ageVal = Int(ageStr){
            age = ageVal
        }
        
        // 수정과 등록 시 분기처리 (2)
        if let target = target as? PersonEntity{
            DataManager.shared.updatePerson(entity: target, name: name, age: age) {
                NotificationCenter.default.post(name: PersonComposeViewController.newPersonDidInsert, object: nil)
                self.dismiss(animated: true, completion: nil)
            }
        }else{
            DataManager.shared.createPerson(name: name, age: age) {
                NotificationCenter.default.post(name: PersonComposeViewController.newPersonDidInsert, object: nil)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 편집모드에 따른 텍스트필드 변경 (1)
        if let target = target as? PersonEntity{
            navigationItem.title = "Edit"
            nameField.text = target.name
            ageField.text = "\(target.age)"
        }else{
            navigationItem.title = "Add"
        }
    }
}
