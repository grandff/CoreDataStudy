//
//  BatchInsertViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/17.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class BatchInsertViewController: UIViewController {

    /*
        Entity Hierarchy and RelationShip
     1. Sample 모델 파일에서 기본적인 작업 먼저
     --> 기존에 만든 Person은 Abstract Entity로 변경
     --> Department와 Employee Entity 생성 후 Attributes 에는 각각 name(string, not optional), salary(decimal, notoptional) 추가. Employee의 Parent Entity는 Person으로
     --> Department와 employee를 각각 relationships에 추가(employee는 to many로)
     --> 둘 다 추가했으면 inverse를 통해 서로 연결해줌
     2. 이미 추가되어있는 json 데이터를 파싱해서 저장하는 메서드 생성
     */
    
    
    @IBOutlet weak var countLabel: UILabel!
    var importCount = 0
    
    // batch insert (2)
    @IBAction func batchInsert(_ sender: UIButton) {
        sender.isEnabled = false
        importCount = 0
        
        // global을 사용하는 이유가 이해 안되면 concurrency 참조하기
        DispatchQueue.global().async {
            let start = Date().timeIntervalSinceReferenceDate
            
            // 파싱 데이터 저장
            let departmentList = DepartmentJSON.parsed()
            let employeeList = EmployeeJSON.parsed()
            
            // main context 저장
            let context = DataManager.shared.mainContext
            
            // data import
            context.performAndWait {
                for dept in departmentList{
                    // 새로운 department 추가
                    // department entity에 제약조건을 하나 추가했음 어떤 에러가 나는지..
                    guard let newDeptEntity = DataManager.shared.insertDepartment(from: dept, in: context) else {fatalError()}
                    
                    // 현재 department에 속한 데이터만 필터링해서 저장
                    let employeesInDept = employeeList.filter{$0.department == dept.id}
                    
                    for emp in employeesInDept{
                        guard let newEmployeeEntity = DataManager.shared.insertEmployee(from: emp, in: context) else{
                            fatalError()
                        }
                        
                        // entity 연결
                        newDeptEntity.addToEmployees(newEmployeeEntity)
                        newEmployeeEntity.department = newDeptEntity
                        
                        // label에 출력
                        self.importCount += 1
                        
                        DispatchQueue.main.async {
                            self.countLabel.text = "\(self.importCount)"
                        }
                    }
                    
                    // context 저장
                    do{
                        try context.save()
                    }catch{
                        print("fucking error 1 :: \(error.localizedDescription)")
                    }
                }
                
                // department에 속하지 않은 데이터 필터링해서 저장
                let otherEmployees = employeeList.filter{
                    $0.department == 0
                }
                
                for emp in otherEmployees{
                    // 해당 데이터는 부서에 속하지 않은 사람이므로 다른 entity에 연결할 필요가 없음
                    _ = DataManager.shared.insertEmployee(from: emp, in: context)
                    
                    self.importCount += 1
                    
                    DispatchQueue.main.async {
                        self.countLabel.text = "\(self.importCount)"
                    }
                }
                
                // context 저장
                do{
                    try context.save()
                }catch{
                    print(error.localizedDescription)
                }
            }
            
            // batch 작업 완료 시
            DispatchQueue.main.async {
                sender.isEnabled = true
                self.countLabel.text = "Done"
                
                let end = Date().timeIntervalSinceReferenceDate
                print(end - start)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
