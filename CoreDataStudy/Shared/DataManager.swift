//
//  DataManager.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/14.
//  Copyright © 2020 kjm. All rights reserved.
//

import Foundation
import CoreData

class DataManager{
    /*
     Managed Object and Managed Object Context
     1. Core Data Stackd을 초기화해서 사용
     2. 싱글톤으로 구현함
     3. Core Data를 담을 Container 객체 생성
     --> 동일한 스레드에서 처리해줘야함
     4. core data 파일 생성
     --> Sample 이라는 이름으로 생성
     --> Person entity 생성 후 age(integer 16), name(string) attribute 생성
     --> Codegen에서 Class Definition 을 선택할 경우 Coredata와 class 이름이 겹칠 경우 에러가 남. 여기선 Manual로 해줌.
     --> editor - Create NSObject... 를 통해 subclass파일을 만들 수 있음
     5. Setup 메서드를 통해 Container init
     6. Context 저장해주는 메서드 생성
     7. Appdelegate 에서 Core Data 초기화
     */
    
    /*
        Concurrency
     1. Background Context에 접근할 수 있도록 새로운 context 생성
     
     */
    
    // 싱글톤으로 구현 (2)
    static let shared = DataManager()
    private init() {}
    
    // Container 생성 및 저장 (3)
    var container : NSPersistentContainer?
    var mainContext : NSManagedObjectContext{
        guard let context = container?.viewContext else{
            fatalError()
        }
        
        return context
    }
    
    // Container init (5)
    func setup(modelName : String){
        container = NSPersistentContainer(name: modelName)
        container?.loadPersistentStores(completionHandler: { (desc, error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        })
    }
    
    // Save Context (6)
    func saveMainContext(){
        mainContext.perform {
            if self.mainContext.hasChanges{
                do{
                    try self.mainContext.save()
                }catch{
                    print(error)
                }
            }
        }
    }
    
    // Background Context (2-1)
    lazy var backgroundContext : NSManagedObjectContext = {
        guard let context = container?.newBackgroundContext() else{
            fatalError()
        }
        
        return context
    }()
}
