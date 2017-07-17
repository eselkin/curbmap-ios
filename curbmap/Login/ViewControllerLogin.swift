//
//  ViewControllerLogin.swift
//  curbmap
//
//  Created by Eli Selkin on 7/16/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import UIKit

class ViewControllerLogin: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func loginButton(_ sender: Any) {
        appDelegate.user.set_username(username: username.text!)
        appDelegate.user.set_password(password: password.text!)
        appDelegate.user.login(callback: self.completeLogin)
    }
    @IBOutlet weak var remember: UISwitch!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        remember.isOn = false
        self.password.backgroundColor = UIColor(displayP3Red: 0.3, green: 0.3, blue: 0.3, alpha: 0.99)
        self.username.backgroundColor = UIColor(displayP3Red: 0.3, green: 0.3, blue: 0.3, alpha: 0.99)
        let fontColor = [ NSForegroundColorAttributeName: UIColor.white ]
        self.password.attributedPlaceholder = NSAttributedString(string: "password", attributes: fontColor)
        self.username.attributedPlaceholder = NSAttributedString(string: "username", attributes: fontColor)
        self.username.delegate = self
        self.password.delegate = self
        // Do any additional setup after loading the view.
    }
    func completeLogin() -> Void {
        if (appDelegate.user.isLoggedIn()) {
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
                let topController = navController.topViewController as! CurbmapNavigation
                topController.tableView.reloadData()
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
