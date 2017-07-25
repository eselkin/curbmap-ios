//
//  TableViewControllerAbout.swift
//  curbmap
//
//  Created by Eli Selkin on 7/24/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import UIKit

class TableViewControllerAbout: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell", for: indexPath)
        cell.textLabel?.textColor = UIColor.white
        if (indexPath.row == 0) {
            cell.textLabel?.text = "About curbmap"
        } else if (indexPath.row == 1) {
            cell.textLabel?.text = "Open data and licenses"
        } else if (indexPath.row == 2) {
            cell.textLabel?.text = "End User License Agreement"
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
