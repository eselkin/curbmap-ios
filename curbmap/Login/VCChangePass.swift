//
//  ViewControllerChangePass.swift
//  curbmap
//
//  Created by Eli Selkin on 7/25/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import UIKit
import EasyTipView

class ViewControllerChangePass: UIViewController, UITextFieldDelegate, EasyTipViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var oldPass: UITextField!
    
    @IBOutlet weak var newPass: UITextField!
    
    @IBOutlet weak var newPassRetype: UITextField!

    @IBAction func changePass(_ sender: Any) {
        if (newPass.text! == newPassRetype.text!) && (newPass.text! != "") && (newPass.text! != oldPass.text!){
            // let the server side do the rest of the checking
            appDelegate.user.changePassword(old_pass: oldPass.text!, new_pass: newPass.text!, callback: doneChanging)
        } else {
            EasyTipView.show(forView: self.newPassRetype,
                             withinSuperview: self.navigationController?.view,
                             text: "Your new passwords may not match or you have entered the same password as your old password!",
                             preferences: preferenceserror,
                             delegate: self)
        }
    }
    var preferencessuccess = EasyTipView.Preferences()
    var preferenceserror = EasyTipView.Preferences()

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        // do something
    }
    
    func doneChanging(val: Int) {
        print(val)
        if (val == 0) {
            EasyTipView.show(forView: self.newPassRetype,
                             withinSuperview: self.navigationController?.view,
                             text: "Cannot change the password of curbmaptest!",
                             preferences: preferenceserror,
                             delegate: self)
        } else if (val == -1) {
            EasyTipView.show(forView: self.newPassRetype,
                             withinSuperview: self.navigationController?.view,
                             text: "Cannot change the password of some other user!",
                             preferences: preferenceserror,
                             delegate: self)
        } else if (val == -2) {
            EasyTipView.show(forView: self.newPassRetype,
                             withinSuperview: self.navigationController?.view,
                             text: "You must type the correct current password! If you don't remember that, consider using password reset from the last menu.",
                             preferences: preferenceserror,
                             delegate: self)
        } else if (val == -3) {
            EasyTipView.show(forView: self.newPassRetype,
                             withinSuperview: self.navigationController?.view,
                             text: "The new password does not meet criteria. Length = 9-40, and contains one special character !@#$%^&*)(<>+=._, one number, one capital, one lowercase!",
                             preferences: preferenceserror,
                             delegate: self)
        } else if (val == 1) {
            EasyTipView.show(forView: self.newPassRetype,
                             withinSuperview: self.navigationController?.view,
                             text: "Success! Your password was changed!",
                             preferences: preferencessuccess,
                             delegate: self)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        preferenceserror.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
        preferenceserror.drawing.foregroundColor = UIColor.white
        preferenceserror.drawing.backgroundColor = UIColor(displayP3Red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)
        preferenceserror.drawing.arrowPosition = EasyTipView.ArrowPosition.top

        preferencessuccess.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
        preferencessuccess.drawing.foregroundColor = UIColor.white
        preferencessuccess.drawing.backgroundColor = UIColor(hue:0.46, saturation:0.99, brightness:0.6, alpha:1)
        preferencessuccess.drawing.arrowPosition = EasyTipView.ArrowPosition.top

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tap);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        oldPass.delegate = self
        newPass.delegate = self
        newPassRetype.delegate = self
        
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
        var contentInset:UIEdgeInsets = UIEdgeInsets.zero
        contentInset.top = contentInset.top + 44
        scrollView.contentInset = contentInset
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    func dismissKeyboard() {
        oldPass.endEditing(true)
        newPass.endEditing(true)
        newPassRetype.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
