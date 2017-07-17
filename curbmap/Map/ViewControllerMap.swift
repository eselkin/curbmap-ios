///Users/eliselkin/Documents/workspace/curbmap/curbmap-ios/curbmap/curbmap.xcodeproj
//  ViewControllerMap.swift
//  curbmap
//
//  Created by Eli Selkin on 7/14/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import UIKit
import MapKit

class ViewControllerMap: UIViewController, CLLocationManagerDelegate  {
    var locationManager: CLLocationManager!
    var userHeading: CLLocationDirection?
    let regionRadius: CLLocationDistance = 2000
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
        self.locationManager = CLLocationManager()
        let bbi = MKUserTrackingBarButtonItem(mapView:self.mapView)
        self.toolbar.barStyle = .blackOpaque
        self.toolbar.setItems([bbi], animated: true)
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingHeading()
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                    self.locationManager.startUpdatingHeading()
                    centerMapOnLocation(location: self.locationManager.location!)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy < 0 { return }
        let heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        userHeading = heading
    }
}
