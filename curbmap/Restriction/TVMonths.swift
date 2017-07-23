//
//  TVMonths.swift
//  curbmap
//
//  Created by Eli Selkin on 7/20/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import UIKit

class TVMonths: UIViewController, UITableViewDelegate, UITableViewDataSource{
    let months: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"]
    var monthsSelected: [Bool] = [true, true, true, true, true, true, true, true, true, true, true, true]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        monthsSelected[indexPath.row] = !monthsSelected[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        if (monthsSelected[indexPath.row]) {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
        (self.parent as? Months)?.monthsChanged(months: monthsSelected)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return months.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MonthsCell", for: indexPath as IndexPath)
        cell.textLabel?.text = months[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        if (monthsSelected[indexPath.row]) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func getMonthsSelectedInArray() -> [Bool] {
        return monthsSelected
    }
    
    func selectMonths(_ value: Bool) {
        for (i,_) in monthsSelected.enumerated() {
            monthsSelected[i] = value
        }
    }
}
