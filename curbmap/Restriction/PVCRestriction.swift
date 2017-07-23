//
//  PVCRestriction.swift
//  curbmap
//
//  Created by Eli Selkin on 7/17/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import UIKit

class PVCRestriction: UIPageViewController, UIPageViewControllerDataSource {
    var VCs: [UIViewController?] = []
    var pages: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        // Do any additional setup after loading the view.
        VCs.append(self.storyboard?.instantiateViewController(withIdentifier: "RestrictionEditor1"))
        pages.append("RestrictionEditor1")
        if (!pages.contains("RestrictionEditor")) {
            restartAction("RestrictionEditor1", viewController: VCs[0])
        }
    }
    
    func restartAction(_ editorWindow: String, viewController: UIViewController?) {
        print(editorWindow)
        if (!pages.contains(editorWindow)) {
            pages.insert(editorWindow, at: 0)
            if (VCs.count < 2) {
                print("HERE")
                VCs.insert(self.storyboard?.instantiateViewController(withIdentifier: editorWindow), at: 0)
            }
        }
        print(pages)
        print(VCs)
        if (viewController != nil) {
            setViewControllers([viewController!],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        } else {
            setViewControllers([VCs[1]!],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
    func removePage(_ editorWindow: String) {
        if (pages.contains(editorWindow)) {
            let index = pages.index(of: editorWindow)
            pages.remove(at: index!)
            self.VCs[index!]?.removeFromParentViewController()
            reloadInputViews()
            VCs.remove(at: index!)
        }
        print(pages)
        print(VCs)
        setViewControllers([VCs[0]!],
                           direction: .forward,
                           animated: true,
                           completion: nil)
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let identifier = viewController.restorationIdentifier {
            if let index = pages.index(of: identifier) {
                if index > 0 {
                    return VCs[index-1]
                }
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let identifier = viewController.restorationIdentifier {
            if let index = pages.index(of: identifier) {
                if index < pages.count - 1 {
                    return VCs[index+1]
                }
            }
        }
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        if let identifier = viewControllers?.first?.restorationIdentifier {
            if let index = pages.index(of: identifier) {
                return index
            }
        }
        return 0
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in view.subviews {
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds // Why? I don't know.
            }
            else if view is UIPageControl {
                view.backgroundColor = UIColor.clear
            }
        }
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
