//
//  PersonEntity+CoreDataClass.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/15.
//  Copyright © 2020 kjm. All rights reserved.
//
//

import Foundation
import CoreData

@objc(PersonEntity)
public class PersonEntity: NSManagedObject {
    /*
     Create, Read, Update, Delete
     1. codegen에 따라 필요한파일이 다 다름
     --> manual - subclass를 통해 직접 다 해줘야함
     --> class - 동일한 이름의 class를 가진게 있으면 에러가 남
     --> category - class는 생성하되 attribute는 자동으로 업데이트 됨(core data class만 남기고 지우면 됨)
     --> 여기선 category로 설정하고 진행함
    
    */
}
