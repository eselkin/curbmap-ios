//
//  ViewControllerRestrEditor.swift
//  curbmap
//
//  Created by Eli Selkin on 7/17/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import UIKit

class ViewControllerRestrEditor: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, pickerSubViewChanged {
    let hours:[Int] = Array(0...23)
    let minutes:[Int] = Array(0...59)
    var hour_selected = 10
    var minute_selected = 30
    let dsRestrPicker = RestrPicker()
    var restrVal: String = "rednp"
    let tableViewDays = TVDays()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fromTime: UIPickerView!
    @IBOutlet weak var toTime: UIPickerView!
    @IBOutlet weak var allDaysButton: UIButton!
    @IBOutlet weak var allHoursButton: UIButton!
    @IBOutlet weak var restrPicker: UIPickerView!
    @IBAction func allDaysButtonPress(_ sender: Any) {
        tableViewDays.selectAllDays()
        tableView.reloadData()
    }
    @IBOutlet weak var longTime: UIPickerView!

    @IBAction func allHoursButtonPress(_ sender: Any) {
        fromTime.selectRow(0, inComponent: 0, animated: true)
        fromTime.selectRow(0, inComponent: 1, animated: true)
        toTime.selectRow(hours.count-1, inComponent: 0, animated: true)
        toTime.selectRow(minutes.count-1, inComponent: 1, animated: true)
    }
    var restriction: Restriction?
    
    override func viewDidLoad() {
        dsRestrPicker.parent = self
        super.viewDidLoad()
        let date = Date()
        let calendar = Calendar.current
        hour_selected = calendar.component(.hour, from: date)
        minute_selected = calendar.component(.minute, from: date)
        fromTime.dataSource = self
        fromTime.delegate = self
        toTime.dataSource = self
        toTime.delegate = self
        longTime.delegate = self
        longTime.dataSource = self
        restrPicker.dataSource = dsRestrPicker
        restrPicker.delegate = dsRestrPicker
        restrPicker.selectRow(7, inComponent: 0, animated: true)
        fromTime.selectRow(hour_selected, inComponent: 0, animated: true)
        fromTime.selectRow(minute_selected, inComponent: 1, animated: true)
        toTime.selectRow(hour_selected, inComponent: 0, animated: true)
        toTime.selectRow(minute_selected, inComponent: 1, animated: true)
        fromTime.backgroundColor = UIColor.darkText
        fromTime.layer.borderColor = UIColor.white.cgColor
        fromTime.layer.borderWidth = 1
        toTime.backgroundColor = UIColor.darkText
        toTime.layer.borderColor = UIColor.white.cgColor
        toTime.layer.borderWidth = 1
        longTime.backgroundColor = UIColor.darkText
        longTime.layer.borderColor = UIColor.white.cgColor
        longTime.layer.borderWidth = 1
        if (restriction != nil) {
            toTime.selectRow((Int((restriction?.toTime)! / 60)), inComponent: 0, animated: true)
            toTime.selectRow(((restriction?.toTime)! % 60), inComponent: 1, animated: true)
            fromTime.selectRow((Int((restriction?.fromTime)! / 60)), inComponent: 0, animated: true)
            fromTime.selectRow(((restriction?.fromTime)! % 60), inComponent: 1, animated: true)
            longTime.selectRow((Int((restriction?.timeLimit)! / 60)), inComponent: 0, animated: true)
            longTime.selectRow(((restriction?.timeLimit)! % 60), inComponent: 1, animated: true)
        }
        let rightBarButtonItem = UIBarButtonItem(title: "next >", style: .plain, target: self, action: #selector(goToNextPage))
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: true)
        
        tableView.dataSource = tableViewDays
        tableView.delegate = tableViewDays
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return hours.count
        }
            
        else {
            return minutes.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let identifier = pickerView.restorationIdentifier {
            print(identifier)
            let total = 60 * pickerView.selectedRow(inComponent: 0) + pickerView.selectedRow(inComponent: 1)
            if (identifier == "toTime") {
                if (total != restriction?.toTime) {
                    restriction?.isEdited = true
                }
            } else if (identifier == "fromTime") {
                if (total != restriction?.fromTime) {
                    restriction?.isEdited = true
                }
            } else {
                if (total != restriction?.timeLimit) {
                    restriction?.isEdited = true
                }
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0) {
            return String(hours[row])
        } else {
            return String(minutes[row])
        }
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "SanFranciscoText-Light", size: 8)
        
        // where data is an Array of String
        if (component == 0) {
            label.text = String(hours[row])
        } else {
            label.text = String(minutes[row])
        }
        return label
    }

    func changedPickerSubview(_ val: String) {
        self.restrVal = val
        if (restriction != nil) {
            restriction?.isEdited = restriction?.type != val ? true : (restriction?.isEdited)!
        }
        if (["ns", "np", "redns", "rednp", "dis"].contains(val)) {
            self.longTime.selectRow(0, inComponent: 0, animated: true)
            self.longTime.selectRow(0, inComponent: 1, animated: true)
            resetDetailInfo()
        } else if (val == "gre") {
            self.longTime.selectRow(0, inComponent: 0, animated: true)
            self.longTime.selectRow(15, inComponent: 1, animated: true)
            resetDetailInfo()
        } else if (["yel", "whi"].contains(val)) {
            self.longTime.selectRow(0, inComponent: 0, animated: true)
            self.longTime.selectRow(5, inComponent: 1, animated: true)
            resetDetailInfo()
        } else if (val == "ppd" || val == "com") {
            resetDetailInfo()
        }
    }
    
    func resetDetailInfo() {
        
    }
    func goToNextPage() {
        // save current info to Restriction object
        let from = fromTime.selectedRow(inComponent: 0) * 60 + fromTime.selectedRow(inComponent: 1)
        let to = toTime.selectedRow(inComponent: 0) * 60 + toTime.selectedRow(inComponent: 1)
        let limit = longTime.selectedRow(inComponent: 0) * 60 + longTime.selectedRow(inComponent: 1)
        if (restriction == nil) {
            restriction = Restriction(type: restrVal, days: tableViewDays.getDaysSelectedInArray(), from: from, to: to, limit: limit)
        } else {
            if ((restriction?.isEdited)!) {
                restriction?.type = self.restrVal
                restriction?.days = tableViewDays.getDaysSelectedInArray()
                restriction?.fromTime = from
                restriction?.toTime = to
                restriction?.timeLimit = limit
            }
        }
        let TVCRestrictionEditor = storyboard?.instantiateViewController(withIdentifier: "RestrictionDetail")
        self.navigationController?.pushViewController(TVCRestrictionEditor!, animated: true)
    }
    
    func done() {
        // called from the next page
        print("DONE")
        let count = (self.navigationController?.viewControllers.count)! - 2
        let restrAdd = self.navigationController?.viewControllers[count] as? TableViewControllerAddRestriction
        restrAdd?.addRestriction(r: restriction!)
        self.navigationController?.popViewController(animated: false)
    }

}

protocol pickerSubViewChanged {
    func changedPickerSubview(_ val: String)
}
