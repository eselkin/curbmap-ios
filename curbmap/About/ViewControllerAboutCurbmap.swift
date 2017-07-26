//
//  ViewControllerAboutCurbmap.swift
//  curbmap
//
//  Created by Eli Selkin on 7/25/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import UIKit

class ViewControllerAboutCurbmap: UIViewController {
    @IBOutlet weak var aboutCurbmapText: UITextView!

    @IBOutlet weak var teamAbout: UITextView!
    
    let whoWeAre = "Team:\n" +
                "Eli Selkin,\n" +
    "\n";
    override func viewDidLoad() {
        super.viewDidLoad()
        aboutCurbmapText.scrollRangeToVisible(NSRange(location:0, length:0))
        teamAbout.text = whoWeAre
        teamAbout.scrollRangeToVisible(NSRange(location:0, length:0))
        // Do any additional setup after loading the view.
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
