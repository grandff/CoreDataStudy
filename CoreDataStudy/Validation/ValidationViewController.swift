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
     
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
