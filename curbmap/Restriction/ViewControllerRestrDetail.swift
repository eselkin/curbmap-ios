//
//  ViewControllerRestrDetail.swift
//  curbmap
//
//  Created by Eli Selkin on 7/20/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import UIKit

class ViewControllerRestrDetail: UIViewController, UITextFieldDelegate, Weeks, Months {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var permit: UITextField!
    @IBOutlet weak var meter_cost: UITextField!
    @IBOutlet weak var meter_per: UITextField!
    @IBOutlet weak var permitLabel: UILabel!
    @IBOutlet weak var meter_costLabel: UILabel!

    @IBOutlet weak var meter_perLabel: UILabel!
    
    @IBAction func allWeeksButtonPressed(_ sender: Any) {
        weeksTable.selectWeeks(true)
        weeksTableView.reloadData()
    }
    @IBAction func allMonthsButtonPressed(_ sender: Any) {
        monthsTable.selectMonths(true)
        monthsTableView.reloadData()
    }
    @IBAction func noWeeksButtonPressed(_ sender: Any) {
        weeksTable.selectWeeks(false)
        weeksTableView.reloadData()
    }
    @IBAction func noMonthsButtonPressed(_ sender: Any) {
        monthsTable.selectMonths(false)
        monthsTableView.reloadData()
    }
    @IBOutlet weak var weeksTableView: UITableView!
    let weeksTable = TVWeeks()
    @IBOutlet weak var monthsTableView: UITableView!
    let monthsTable = TVMonths()
    var restrEditor: ViewControllerRestrEditor? // The view to which the "restriction" actually belongs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tap);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        let count = (self.navigationController?.viewControllers.count)! - 2
        restrEditor = self.navigationController?.viewControllers[count] as? ViewControllerRestrEditor
        weeksTable.weeksSelected = (restrEditor?.restriction?.weeks)!
        monthsTable.monthsSelected = (restrEditor?.restriction?.months)!
        permit.text = (restrEditor?.restriction?.permit)!
        meter_cost.text = String((restrEditor?.restriction?.cost)!)
        meter_per.text = String((restrEditor?.restriction?.per)!)
        weeksTableView.delegate = weeksTable
        weeksTableView.dataSource = weeksTable
        monthsTableView.delegate = monthsTable
        monthsTableView.dataSource = monthsTable
        weeksTableView.reloadData()
        monthsTableView.reloadData()
        meter_cost.delegate = self
        meter_per.delegate = self
        permit.delegate = self
        let rightButton = UIBarButtonItem(title: "done", style: .plain, target: self, action: #selector(done))
        self.navigationItem.setRightBarButton(rightButton, animated: true)
        if (["rednp", "redns", "np", "ns", "com", "temp", "ppd", "gre", "yel", "whi"].contains((restrEditor?.restriction?.type)!)) {
            meter_per.isEnabled = false
            meter_cost.isEnabled = false
            meter_cost.backgroundColor = UIColor.black
            meter_per.backgroundColor = UIColor.black
            meter_perLabel.isHidden = true
            meter_perLabel.textColor = UIColor.black
            meter_costLabel.isHidden = true
        }
        if (!["ppd", "com"].contains((restrEditor?.restriction?.type)!)) {
            permit.isEnabled = false
            permit.backgroundColor = UIColor.black
            permitLabel.isHidden = true
        }
    }
    
    func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    func weeksChanged(weeks:[Bool]) {
        if (weeks != (restrEditor?.restriction?.weeks)!) {
            // you can actually compare arrays this way in Swift
            restrEditor?.restriction?.isEdited = true
        }
    }
    
    func monthsChanged(months: [Bool]) {
        if (months != (restrEditor?.restriction?.months)!) {
            restrEditor?.restriction?.isEdited = true
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func dismissKeyboard() {
        permit.endEditing(true)
        meter_cost.endEditing(true)
        meter_per.endEditing(true)
    }
    func done() {
        restrEditor?.restriction?.weeks = weeksTable.getWeeksSelectedInArray()
        restrEditor?.restriction?.months = monthsTable.getMonthsSelectedInArray()
        if (permit.isEnabled) {
            restrEditor?.restriction?.permit = permit.text!
        }
        if (meter_cost.isEnabled) {
            restrEditor?.restriction?.cost = Float((meter_cost.text)!)!
            restrEditor?.restriction?.per = Int(meter_per.text!)!
        }
        self.navigationController?.popViewController(animated: false)
        restrEditor?.done()
    }

}

protocol Months {
    func monthsChanged(months: [Bool])
}

protocol Weeks {
    func weeksChanged(weeks: [Bool])
}
