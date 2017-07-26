//
//  TVCSettings.swift
//  curbmap
//
//  Created by Eli Selkin on 7/24/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import UIKit

class TVCSettings: UITableViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (section == 0 || section == 1) {
            return 2
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                let vCChangePass = storyboard?.instantiateViewController(withIdentifier: "VCChangePass")
                self.navigationController?.pushViewController(vCChangePass!, animated: true)
            } else if (indexPath.row == 1) {
                appDelegate.user.resetPassword(callback: completedReset)
            }
        } else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                appDelegate.user.logout(callback: completedLogout)
            }
        }
    }
    
    
    func completedReset() -> Void {
        
    }
    
    func completedLogout() -> Void {
        print("logout done")
        let count = (self.navigationController?.viewControllers.count)! - 2
        let navPrev = self.navigationController?.viewControllers[count] as! CurbmapNavigation
        navPrev.tableView.reloadData()
        self.navigationController?.popViewController(animated: true)

        // send user back to main page and reset to curbmaptest
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "password"
        } else if (section == 1) {
            return "account"
        }
        else  {
            return "settings"
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        cell.textLabel?.textColor = UIColor.white
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell.textLabel?.text = "Change password"
            } else {
                cell.textLabel?.text = "Password reset"
            }
        } else if (indexPath.section == 2) {
            cell.textLabel?.text = "Sign out"
            cell.textLabel?.textColor = UIColor(displayP3Red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
        }
        return cell
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
