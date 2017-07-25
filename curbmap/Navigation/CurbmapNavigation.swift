//
//  CurbmapNavigation.swift
//  curbmap
//
//  Created by Eli Selkin on 7/14/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import UIKit
import CoreLocation

class CurbmapNavigation: UITableViewController{
    let backgroundImage = UIImage(named: "curb.jpg")
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var SwiftTimer: Timer = Timer()
    var notLoggedIn = true

    override func viewWillAppear(_ animated: Bool) {
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateCounter), userInfo:nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        let storyboard = self.storyboard
        selectedCell.backgroundColor = UIColor.black
        if (indexPath.section == 2 && indexPath.row == 0) {
            let VCMap = storyboard?.instantiateViewController(withIdentifier: "ViewControllerMap")
            navigationController?.pushViewController(VCMap!, animated: true)
        } else if (indexPath.section == 0 && indexPath.row == 0 && !appDelegate.user.isLoggedIn()) {
            let VCLogin = storyboard?.instantiateViewController(withIdentifier: "ViewControllerLogin")
            self.navigationController?.pushViewController(VCLogin!, animated: true)
        } else if (indexPath.section == 0 && appDelegate.user.isLoggedIn()) {
            let VCSettings = storyboard?.instantiateViewController(withIdentifier: "ViewControllerSettings")
            self.navigationController?.pushViewController(VCSettings!, animated: true)
        } else if (indexPath.section == 1){
            let TVCAbout = storyboard?.instantiateViewController(withIdentifier: "TableViewControllerAbout")
            self.navigationController?.pushViewController(TVCAbout!, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let unSelectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        unSelectedCell.backgroundColor =  UIColor.black
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            if (appDelegate.user.get_username() != "curbmapuser" && appDelegate.user.isLoggedIn()) {
                return "Settings"
            } else {
                return "Get the most out of the app"
            }
            return "go to the map..."
        } else if (section == 1) {
            return "got questions about us?"
        } else {
            return "go to the map"
        }
    }
    
    func updateCounter() {
        if (self.notLoggedIn && appDelegate.user.isLoggedIn()) {
            self.notLoggedIn = false
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0 && appDelegate.user.isLoggedIn()) {
            return 120.0
        } else {
            return 80.0
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if (appDelegate.user.isLoggedIn()) {
            if (indexPath.section == 0) {
                print(indexPath.section)
                tableView.register(UINib(nibName: "LoggedInTableViewCell", bundle: nil), forCellReuseIdentifier: "LoggedInCell")
                var tempcell = tableView.dequeueReusableCell(withIdentifier: "LoggedInCell", for: indexPath) as? LoggedInTableViewCell
                print(appDelegate.user.get_badge())
                tempcell?.imageView?.image = UIImage(named: "badge_"+appDelegate.user.get_badge())
                tempcell?.usernameLabel.text = appDelegate.user.get_username()
                tempcell?.scoreLabel.text = String(appDelegate.user.get_score())
                tempcell?.badgeLabel.text = "beginner"
                cell = tempcell
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "curbmapNavigationCell", for: indexPath)
                cell?.backgroundColor = UIColor.black
                cell?.textLabel?.textColor = UIColor.white
                if (indexPath.section == 1) {
                    cell?.textLabel?.text = "About"
                } else {
                    cell?.textLabel?.text = "Map"
                    notLoggedIn = false
                }
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "curbmapNavigationCell", for: indexPath)
            cell?.backgroundColor = UIColor.black
            cell?.textLabel?.textColor = UIColor.white
            if (indexPath.section == 0) {
                cell?.textLabel?.text = "Login"
            } else if (indexPath.section == 1) {
                cell?.textLabel?.text = "About"
            } else {
                cell?.textLabel?.text = "Map"
                notLoggedIn = true
            }
        }
        return cell!
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

    }

}
