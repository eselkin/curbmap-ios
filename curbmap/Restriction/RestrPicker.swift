//
//  RestrPicker.swift
//  curbmap
//
//  Created by Eli Selkin on 7/17/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import UIKit

class RestrPicker: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    let data: [String: String] = [
        "rednp": "Red: No Parking",
        "redns": "Red: No Stopping",
        "np": "No Parking",
        "ns": "No Stopping",
        "yel": "Yellow Zone",
        "whi": "White Zone",
        "dis": "Handicapped Zone",
        "gre": "Green Zone",
        "ppd": "Residential Permit",
        "com": "Commercial Permit",
        "met": "Metered",
        "tem": "Temporary, No Parking"
    ]
    var parent: ViewControllerRestrEditor?
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let key: String = (data.keys.sorted())[row]
        self.parent?.changedPickerSubview(key)
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.keys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let key: String = (data.keys.sorted())[row]
        return data[key]
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let key = (data.keys.sorted())[row]
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
            label.text = data[key]
        } else {
            label.text = data[key]
        }
        return label
    }

}
