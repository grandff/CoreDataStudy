//
//  ValidationViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/04/01.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class ValidationViewController: UIViewController {

    /*
        Validation and Error Handling
     1. Optional 체크가 가장 간단한 Validation 방법임
     --> Data model에서 Optional 체크
     2. Validation을 더 정확하게 하려면 Data model에서 Validation 입력
     --> 여기선 person entity에 age 컬럼을 20 ~ 50 between을 주고 optional 해제 및 default value를 없앴음
     3. 기본적으로 제공되어지는 Validation을 사용해서 값을 검증할 수 있음
     4. Validation을 통해 코어데이터 작업을 하려면 UndoManager를 선언해야함
     5. Validation을 직접 커스텀해서 사용할 수 있음
     --> Employee 객체를 Manual/None으로 수정 후 managedobject subclass 생성
     --> EmployeeEntity 객체에 custom validation 생성
     6. 생성한 커스텀 Validation 호출
     */
    
    let departmentList = DataManager.shared.fetchDepartment()
    var selectedDepartment : DepartmentEntity?
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var ageSlider: UISlider!
    @IBOutlet weak var ageValueLabel: UILabel!
    
    @IBOutlet weak var departmentButton: UIButton!
            
    override func viewDidLoad() {
        super.viewDidLoad()
        // UndoManager 할당 (4)
        // 취소를 하거나 rollback등 여러 기능 구현이 가능해짐
        DataManager.shared.mainContext.undoManager = UndoManager()
    }
    
    deinit {
        DataManager.shared.mainContext.undoManager = nil
    }
    
    // Validation을 통해 데이터 검증 (3)
    @IBAction func validate(_ sender: Any) {
        guard let name = nameField.text else {return}
        let age = Int16(ageSlider.value)
        let context = DataManager.shared.mainContext
        
        // validate
        let newEmployee = EmployeeEntity(context: context)
        newEmployee.name = name
        newEmployee.age = age
        newEmployee.department = selectedDepartment
        
        do{
            // 저장 가능한 객체인지 확인
            try newEmployee.validateForInsert()
        }catch let error as NSError{
            // 오류가 났을 경우 해당 오류에 대한 분기 처리
            switch error.code {
            case NSValidationStringTooShortError, NSValidationStringTooLongError:
                // 두 개 이상의 경우 userInfo를 통해 어떻게 알려줄지 확인해야함
                if let attr = error.userInfo[NSValidationKeyErrorKey] as? String, attr == "name"{
                    showAlert(message: "Please enter a name between 2 and 30 characters.")
                }else{
                    showAlert(message: "Please enter a valid value.")
                }
            case NSValidationNumberTooLargeError, NSValidationNumberTooSmallError :
                if let msg = error.userInfo[NSLocalizedDescriptionKey] as? String{
                    showAlert(message: msg)
                }else{
                    showAlert(message: "Please enter a valid value.")
                }
            // custom validation (6)
            case NSValidationInvalidAgeAndDepartment:
                if let msg = error.userInfo[NSLocalizedDescriptionKey] as? String{
                    showAlert(message: msg)
                }else{
                    showAlert(message: "Please enter a valid value.")
                }
            default:
                break
            }
        }
        
        // 만약 validate에서 에러가 났다면 rollback을 시킬 수 있음
        context.rollback()
    }

    @IBAction func sliderChanged(_ sender: UISlider) {
        ageValueLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func selectedDepartment(_ sender: Any) {
        showDepartmentList()
    }
}

extension ValidationViewController{
    func showDepartmentList(){
        let alert = UIAlertController(title: nil, message: "Select Department", preferredStyle: .alert)
        
        for dept in departmentList{
            let departmentAction = UIAlertAction(title: dept.name, style: .default) { (action) in
                self.selectedDepartment = dept
                self.departmentButton.setTitle(dept.name, for: .normal)
            }
            alert.addAction(departmentAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.selectedDepartment = nil
            self.departmentButton.setTitle("None", for: .normal)
        }
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(message : String){
        let alert = UIAlertController(title: "Validation", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
        }
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
}
