//
//  TVCDays.swift
//  curbmap
//
//  Created by Eli Selkin on 7/20/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import UIKit

class TVDays: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let days: [String] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    var daysSelected: [Bool] = [false, false, false, false, false, false, false]
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        daysSelected[indexPath.row] = !daysSelected[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        if (daysSelected[indexPath.row]) {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DaysCell", for: indexPath as IndexPath)
        cell.textLabel?.text = days[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        if (daysSelected[indexPath.row]) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func getDaysSelectedInArray() -> [Bool] {
        return daysSelected
    }
    
    func selectAllDays() {
        for (i,_) in daysSelected.enumerated() {
            daysSelected[i] = true
        }
    }
    
    // MARK: - Table view data source

    
}
