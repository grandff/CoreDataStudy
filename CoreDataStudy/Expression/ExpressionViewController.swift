//
//  ExpressionViewController.swift
//  CoreDataStudy
//
//  Created by 김정민 on 2020/03/27.
//  Copyright © 2020 kjm. All rights reserved.
//

import UIKit
import CoreData

class ExpressionViewController: UIViewController {
    
    /*
        Expression
     1. Expression을 사용해서 집계함수(avg, count ...) 계산
     2. Expression을 사용하지 않으면 지속적으로 메모리 누수가 발생하므로 주의
     --> Profile을 통해 비교 가능
     */
    
    lazy var formatter : NumberFormatter = {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "en_US")
        f.numberStyle = .currency
        return f
    }()
    
    var list = [Any]()
    
    @IBOutlet weak var listTableView: UITableView!
    
    // Expression을 사용해서 집계함수 구현 (1)
    func fetch(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Department")
        
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortByName]
        
        // expression을 활용해서 집계함수 계산
        request.resultType = .dictionaryResultType  // expression의 경우 꼭 딕셔너리 타입이어야함
        let employeeCountExprDescription = NSExpressionDescription()
        employeeCountExprDescription.name = "count"     // count 사용
        let countArg = NSExpression(forKeyPath: "employees")
        let countExpr = NSExpression(forFunction: "count:", arguments: [countArg])
        
        // expression에 저장
        employeeCountExprDescription.expression = countExpr
        employeeCountExprDescription.expressionResultType = .integer64AttributeType
        
        // 평균 계산 expression
        let averageSalaryExprDescription = NSExpressionDescription()
        averageSalaryExprDescription.name = "avg"
        
        let salaryArg = NSExpression(forKeyPath: "employees.salary")
        averageSalaryExprDescription.expression = NSExpression(forFunction: "average:", arguments: [salaryArg])
        averageSalaryExprDescription.expressionResultType = .decimalAttributeType
        
        // request에 설정
        request.propertiesToFetch = ["name", employeeCountExprDescription, averageSalaryExprDescription]
        
        do{
            list = try DataManager.shared.mainContext.fetch(request)
            listTableView.reloadData()
        }catch{
            fatalError(error.localizedDescription)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetch()
    }
}

extension ExpressionViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Expression 사용 유무 비교 (2)
        if let target = list[indexPath.row] as? NSManagedObject{
            let count = target.value(forKeyPath: "employees.@count.intValue") as? Int
            let avg = target.value(forKeyPath: "employees.@avg.salary.doubleValue") as? Double
            
            if let name = target.value(forKey: "name") as? String, let count = count {
                cell.textLabel?.text = "\(name)\n\(count) employees"
            }
            
            let avgStr = formatter.string(for: avg ?? 0) ?? "0"
            cell.detailTextLabel?.text = avgStr
        }else if let target = list[indexPath.row] as? [String : Any]{
            let count = target["count"] as? Int
            let avg = target["avg"] as? Double
            
            if let name = target["name"] as? String, let count = count {
                cell.textLabel?.text = "\(name)\n\(count) employees"
            }
            
            let avgStr = formatter.string(for: avg ?? 0) ?? "0"
            cell.detailTextLabel?.text = avgStr
        }
        
        return cell
    }
    
    
}
