//
//  TVCWeeks.swift
//  curbmap
//
//  Created by Eli Selkin on 7/20/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import UIKit

class TVWeeks: UIViewController, UITableViewDelegate, UITableViewDataSource{
    let weeks: [String] = ["1st", "2nd", "3rd", "4th"]
    var weeksSelected: [Bool] = [true, true, true, true]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("here in select")
        weeksSelected[indexPath.row] = !weeksSelected[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        if (weeksSelected[indexPath.row]) {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
        (self.parent as? Weeks)?.weeksChanged(weeks: weeksSelected)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weeks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeeksCell", for: indexPath as IndexPath)
        cell.textLabel?.text = weeks[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        if (weeksSelected[indexPath.row]) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func getWeeksSelectedInArray() -> [Bool] {
        return weeksSelected
    }
    
    func selectWeeks(_ value: Bool) {
        for (i,_) in weeksSelected.enumerated() {
            weeksSelected[i] = value
        }
    }

}
