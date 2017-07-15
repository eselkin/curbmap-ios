//
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
    
    let regionRadius: CLLocationDistance = 2000
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
        self.mapView.showsCompass = true
        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        self.locationManager.startUpdatingHeading()
        self.locationManager.requestAlwaysAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status.rawValue)
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                    print("auth given")
                    self.locationManager.startUpdatingHeading()
                    centerMapOnLocation(location: self.locationManager.location!)
                }
            }
        }
    }

}
