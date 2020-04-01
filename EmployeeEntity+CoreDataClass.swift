//
//  EmployeeEntity+CoreDataClass.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/04/01.
//  Copyright © 2020 kjm. All rights reserved.
//
//

import Foundation
import CoreData

@objc(EmployeeEntity)
public class EmployeeEntity: PersonEntity {
    /*
       Validation and Error Handling
    1. Custom Validation 구현
    --> Pointer를 사용해서 구현함
    --> 개별 속성 검증 시 양식에 맞춰서 코딩해야함
    2. 별도의 에러코드를 만들 수 있음
    --> 기존의 에러코드와 안겹치도록 주의
    */
    
    // 개별 속성을 검증하려면 아래의 메서드처럼 사용해야함 (1)
    // Age Attribute 검증
    @objc func validateAge(_ value : AutoreleasingUnsafeMutablePointer<AnyObject>?) throws{
        // pointer 사용 (1)
        guard let ageValue = value!.pointee as? Int else {return}
        if ageValue < 20 || ageValue > 50{
            let msg = "Age value must be between 20 and 50."
            let code = ageValue < 20 ? NSValidationNumberTooSmallError : NSValidationNumberTooLargeError
            let error = NSError(domain: NSCocoaErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : msg])
            
            throw error
        }
    }
    
    // 개별 부서의 경우 30세 미만만 들어가도록 설정
    func validationAgeWithDepartment() throws{
        guard let deptName = department?.name, deptName == "Development" else{
            return
        }
        
        guard age < 30 else{
            return
        }
        
        let msg = "The Development department cannot have employees under 30 years of age."
        let code = NSValidationInvalidAgeAndDepartment
        let error = NSError(domain: NSCocoaErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : msg])
        throw error
    }
    
    // 생성한 예외처리 호출
    public override func validateForInsert() throws {
        try super.validateForInsert()
        try validationAgeWithDepartment()
    }
    
    public override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validationAgeWithDepartment()
    }
}

// 직접 오류코드 생성 (2)
public let NSValidationInvalidAgeAndDepartment = Int.max - 100
