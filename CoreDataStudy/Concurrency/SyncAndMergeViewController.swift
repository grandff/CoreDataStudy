//
//  SyncAndMergeViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/04/06.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class SyncAndMergeViewController: UIViewController {
    
    /*
        Context Synchronization
     1. Main Context와 Background Context에서 저장된 데이터를 가져와서 확인 가능
     2. 각 Context의 데이터 변경 후 저장
     --> 이 때 merge 정책 설정을 해서 overwrite로 변경해줘야함
     3. Notification을 통해 새로 등록된, 삭제된 데이터를 확인할 수 있음
     4. Notification을 통해 Main Context의 데이터를 Background Context와 자동으로 동기화 하도록 설정
     5. refresh 메서드를 활용해 Main Context의 데이터를 Background Context merge 처리
     */
    
    lazy var formatter : NumberFormatter = {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "en_US")
        f.numberStyle = .currency
        return f
    }()
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mainContextSalaryLabel: UILabel!
    @IBOutlet weak var backgroundContextSalaryLabel: UILabel!
    
    var employeeInMainContext : EmployeeEntity?
    var employeeInBackgroundContext : EmployeeEntity?
    
    let mainContext = DataManager.shared.mainContext
    let backgroundContext = DataManager.shared.backgroundContext
        
    // Main Context의 데이터 확인 (1)
    @IBAction func fetchIntoMainContext(_ sender: Any) {
        mainContext.perform {
            self.employeeInMainContext = DataManager.shared.fetchEmployeeConcurrency(in: self.mainContext)
            
            // 메인 스레드에서 처리를 하기 때문에 블록 내부에 직접 접근해도 문제 없음
            self.nameLabel.text = self.employeeInMainContext?.name
            self.mainContextSalaryLabel.text = self.formatter.string(for: self.employeeInMainContext?.salary)
        }
    }
    
    // Background Context의 데이터 확인 (1)
    @IBAction func fetchIntoBackgroundContext(_ sender: Any) {
        backgroundContext.perform {
            self.employeeInBackgroundContext = DataManager.shared.fetchEmployeeConcurrency(in: self.backgroundContext)
            
            // 필요한 값을 따로 저장 후 메인 스레드로 전달(오류 방지를 위함)
            let salary = self.employeeInBackgroundContext?.salary?.decimalValue
            
            DispatchQueue.main.async {
                self.backgroundContextSalaryLabel.text = self.formatter.string(for: salary)
            }
        }
    }
    
    // 임의의 데이터로 Salary 설정 (2)
    @IBAction func updateInMainContext(_ sender: Any) {
        mainContext.perform {
            let newSalary = NSDecimalNumber(integerLiteral: Int.random(in: 30...90) * 1000)
            self.employeeInMainContext?.salary = newSalary
            self.mainContextSalaryLabel.text = self.formatter.string(for: newSalary)
        }
    }
    
    // 임의의 데이터로 Salary 설정 (2)
    @IBAction func updateInBackgroundContext(_ sender: Any) {
        backgroundContext.perform {
            let newSalary = NSDecimalNumber(integerLiteral: Int.random(in: 30...90) * 1000)
            self.employeeInBackgroundContext?.salary = newSalary
            
            DispatchQueue.main.async {
                self.backgroundContextSalaryLabel.text = self.formatter.string(for: newSalary)
            }
        }
    }
        
    @IBAction func saveInMainContext(_ sender: Any) {
        mainContext.perform {
            do{
                try self.mainContext.save()
            }catch{
                print(error)
            }
        }
    }
    
    @IBAction func saveInBackgroundContext(_ sender: Any) {
        backgroundContext.perform {
            do{
                try self.backgroundContext.save()
            }catch{
                print(error)
            }
        }
    }
    
    // Main Context 객체 refresh (5)
    @IBAction func refreshInMainContext(_ sender: Any) {
        mainContext.perform {
            // mergeChangeds 옵션에 true를 전달해서 최신 값으로 업데이트 해줌
            self.mainContext.refresh(self.employeeInMainContext!, mergeChanges: true)
            self.mainContextSalaryLabel.text = self.formatter.string(for: self.employeeInMainContext?.salary)
        }
    }
    
    // Background Context 객체 refresh (5)
    @IBAction func refreshInBackgroundContext(_ sender: Any) {
        backgroundContext.perform {
            self.backgroundContext.refresh(self.employeeInBackgroundContext!, mergeChanges: true)
            
            let salary = self.employeeInBackgroundContext?.salary?.decimalValue
            
            DispatchQueue.main.async {
                self.backgroundContextSalaryLabel.text = self.formatter.string(for: salary)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Merge 정책을 Overwrite로 설정해서 Update된 값을 자동으로 저장하도록 설정 (2)
        mainContext.mergePolicy = NSOverwriteMergePolicy
        backgroundContext.mergePolicy = NSOverwriteMergePolicy
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil, queue: OperationQueue.main) { (noti) in
            guard let userInfo = noti.userInfo else {return}
            guard let changedContext = noti.object as? NSManagedObjectContext else{return}
            
            print("==========")
            
            // 등록된 데이터 확인 (3)
            if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
                
            }
            
            // 삭제된 데이터 확인 (3)
            if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0{
                
            }
            
            // 백그라운드 컨텍스트와 메인 컨텍스트 동기화 (4)
            if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0{
                // 아래 코드는 무한루프를 방지하기 위한 코드
                // 아래 코드를 안적으면 for 문이 업데이트된 객체를 계속 호출해서 무한루프가 발생함
                guard changedContext != self.backgroundContext else {
                    return
                }
                
                // for in 반복으로 데이터 확인 후 merge 처리
                for update in updates{
                    self.backgroundContext.perform {
                        for (key, value) in update.changedValues(){
                            self.employeeInBackgroundContext?.setValue(value, forKey: key)
                        }
                        
                        let salary = self.employeeInBackgroundContext?.salary?.decimalValue
                        DispatchQueue.main.async {
                            self.backgroundContextSalaryLabel.text = self.formatter.string(for: salary)
                        }
                    }
                }
            }
        }
    }
}
