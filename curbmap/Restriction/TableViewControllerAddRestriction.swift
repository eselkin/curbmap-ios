//
//  TableViewControllerAddRestriction.swift
//  curbmap
//
//  Created by Eli Selkin on 7/17/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import UIKit
import MapKit

class TableViewControllerAddRestriction: UITableViewController {
    var restrictions = [Restriction]()
    var restrictionsSelected = [Bool]()
    let formatter = DateFormatter()
    let isPoint: Bool = true
    let coordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let titleLookup: [String: String] = [
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
    override func viewDidLoad() {
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        super.viewDidLoad()
        let count = (self.navigationController?.viewControllers.count)! - 2
        let parent = self.navigationController?.viewControllers[count] as! ViewControllerMap
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: parent, action: #selector(parent.cancel))
        let addButtonItem = UIBarButtonItem(title: "+ add", style: .plain, target: self, action: #selector(addItem))
        self.navigationItem.rightBarButtonItems = [addButtonItem]
    }
    
    func addItem() {
        let TVCRestrictionEditor = storyboard?.instantiateViewController(withIdentifier: "RestrictionEditor")
        self.navigationController?.pushViewController(TVCRestrictionEditor!, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restrictions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddRestrictionCell", for: indexPath as IndexPath)
        cell.textLabel?.text = titleLookup[restrictions[indexPath.row].type]
        cell.detailTextLabel?.text = formatter.string(from: restrictions[indexPath.row].dateAdded!)
        cell.detailTextLabel?.textColor = UIColor.lightText
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    func addRestriction(r: Restriction) {
        r.dateAdded = Date()
        restrictions.append(r)
        restrictionsSelected.append(false)
        self.tableView.reloadData()
        let count = (self.navigationController?.viewControllers.count)! - 2
        let navPrev = self.navigationController?.viewControllers[count] as? ViewControllerMap
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"Done", style: .plain, target: navPrev, action: #selector(navPrev?.done))
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction(style: .default, title: " Remove ", handler: removeItem)
        let downVotewRowAction = UITableViewRowAction(style: .default, title: "  -1   ", handler: downVote)
        downVotewRowAction.backgroundColor = UIColor.init(displayP3Red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        let upVoteRowAction = UITableViewRowAction(style: .default, title: "  +1   ", handler: upVote)
        upVoteRowAction.backgroundColor = UIColor.init(displayP3Red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        return [deleteRowAction, downVotewRowAction, upVoteRowAction]
    }

    func removeItem(_ action: UITableViewRowAction, indexPath: IndexPath) -> Void {
        restrictionsSelected.remove(at: indexPath.row)
        if (restrictions[indexPath.row].id == nil) {
            restrictions.remove(at: indexPath.row)
        } else {
            // this rule has an id so we must have received it from the system. We need to put it on a list to be deleted
            if (isPoint) {
                let title: String = "lat="+String(coordinates[0].latitude)+"lng="+String(coordinates[0].longitude)
                if (!appDelegate.user.pointsToRemove.keys.contains(title)) {
                    appDelegate.user.pointsToRemove[title] = []
                }
                appDelegate.user.pointsToRemove[title]?.append(restrictions[indexPath.row])
                restrictions.remove(at: indexPath.row)
            } else {
                var title: String = ""
                var i = 0
                for point in coordinates {
                    title += "lat"+String(i)+"="+String(point.latitude)+"lng"+String(i)+"="+String(point.longitude)
                }
                if (!appDelegate.user.linesToRemove.keys.contains(title)) {
                    appDelegate.user.linesToRemove[title] = []
                }
                appDelegate.user.linesToRemove[title]?.append(restrictions[indexPath.row])
                restrictions.remove(at: indexPath.row)
            }
        }
        tableView.reloadData()
    }
    
    func upVote(_ action: UITableViewRowAction, indexPath: IndexPath) -> Void {
    }
    
    func downVote(_ action: UITableViewRowAction, indexPath: IndexPath) -> Void {
    }
    
}
