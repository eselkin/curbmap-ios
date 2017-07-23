///Users/eliselkin/Documents/workspace/curbmap/curbmap-ios/curbmap/curbmap.xcodeproj
//  ViewControllerMap.swift
//  curbmap
//
//  Created by Eli Selkin on 7/14/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import UIKit
import MapKit

class ViewControllerMap: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate  {
    var locationManager: CLLocationManager!
    var userHeading: CLLocationDirection?
    var regionRadius: CLLocationDistance = 2000
    var tempGestureRecognizers: [UIGestureRecognizer] = []
    var constraints_scrollview_h: [NSLayoutConstraint]!
    var constraints_scrollview_v: [NSLayoutConstraint]!
    var constraints_toolbar_h: [NSLayoutConstraint]!
    var constraints_total_v: [NSLayoutConstraint]!
    var constraints_map_h: [NSLayoutConstraint]!
    var constraints_search_h: [NSLayoutConstraint]!
    var portrait_oriented: Bool = true
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapView: MKMapView!
    var views: [String: UIView]!
    var bbi_addPoint:UIBarButtonItem?
    var bbi_addPoint_cancel:UIBarButtonItem?
    var bbi_addLine:UIBarButtonItem?
    var bbi_addLine_cancel:UIBarButtonItem?
    var bbi_map: MKUserTrackingBarButtonItem?
    var bbi_addRestr: UIBarButtonItem?
    var pointStarted: CLLocationCoordinate2D?
    var lineOfPoints: [CLLocationCoordinate2D] = []
    var zoomBefore: Double?
    var geodesic: MKPolyline?
    var addPointLongPressGesture: UILongPressGestureRecognizer!
    var addLinesLongPressGesture: UILongPressGestureRecognizer!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var geocoder = CLGeocoder()
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            if (geodesic != nil && (overlay as! MKPolyline) == geodesic!) {
                polylineRenderer.strokeColor = UIColor.blue
                polylineRenderer.lineWidth = 3
                return polylineRenderer
            }
        } else if overlay is CurbmapPolyLine {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            let curbmapPoly = overlay as! CurbmapPolyLine
            if (curbmapPoly.restrictions != nil) {
                polylineRenderer.strokeColor = getColorForResrictions(curbmapPoly.restrictions)
            }
        }
        return MKOverlayRenderer()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        geocoder.cancelGeocode()
        geocoder.geocodeAddressString((searchBar.text)!, completionHandler: { (placemarks, error) in
            // Process Response
            self.processGeocode(withPlacemarks: placemarks, error: error)
        })
    }
    
    func processGeocode(withPlacemarks : [CLPlacemark]?, error: Error?) {
        if (error != nil) {
            return
        }
        if ((withPlacemarks?.count)! > 0) {
            let point: CLLocationCoordinate2D = (withPlacemarks?[0].location?.coordinate)!
            centerMapOnLocation( location: CLLocation(latitude: point.latitude, longitude: point.longitude) )
        }
    }
    
    func getColorForResrictions(_ r: [Restriction]) -> UIColor {
        var color: UIColor = UIColor.black;
        for restriction in r {
            switch(restriction.type) {
                case "hyd", "ns", "np", "rednp", "redns":
                    color = UIColor.red
                    break;
                case "whi":
                    if (color != UIColor.red) {
                        color = UIColor.white
                    }
                    break;
                case "gre":
                    if (color != UIColor.red) {
                        color = UIColor.green
                    }
                    break;
                case "dis":
                    color = UIColor.init(displayP3Red: 0.7, green: 0.7, blue: 1.0, alpha: 1.0)
                    break;
                case "com", "yel":
                    if (color != UIColor.red){
                        color = UIColor.yellow
                    }
                    break;
                default:
                    if (color != UIColor.red){
                        color = UIColor.black
                    }
                    break;
            }
        }
        return color
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self;
        bbi_addPoint = UIBarButtonItem(image: UIImage(named: "addPoint.png"), landscapeImagePhone: UIImage(named: "addPointL.png"), style: .plain, target: self, action: #selector(addPoint))
        bbi_addPoint_cancel = UIBarButtonItem(image: UIImage(named: "addPointCancel.png"), landscapeImagePhone: UIImage(named: "addPointCancelL.png"), style: .plain, target: self, action: #selector(addPointCancel))
        bbi_addLine = UIBarButtonItem(image: UIImage(named: "addLine.png"), landscapeImagePhone: UIImage(named: "addLineL.png"), style: .plain, target: self, action: #selector(addLine))
        bbi_addLine_cancel = UIBarButtonItem(image: UIImage(named: "addLineCancel.png"), landscapeImagePhone: UIImage(named: "addLineCancelL.png"), style: .plain, target: self, action: #selector(addLineCancel))
        self.mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
        self.locationManager = CLLocationManager()
        bbi_map = MKUserTrackingBarButtonItem(mapView:self.mapView)
        addLinesLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addLinesLongPress(gesture:)))
        addPointLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addPointLongPress(gesture:)))
        bbi_addRestr = UIBarButtonItem(title: " Finish ", style: .plain, target: self, action: #selector(addRestrToLine))
        self.toolbar.barStyle = .blackOpaque
        self.toolbar.setItems([bbi_map!, bbi_addPoint!, bbi_addLine!], animated: true)
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingHeading()
        self.locationManager.requestWhenInUseAuthorization()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tap);
        views = [
            "view": view,
            "scroll": scrollView,
            "toolbar": toolbar,
            "search": searchBar,
            "map": mapView
        ]
        setupViews(portrait_oriented)
    }
    
    func setupViews(_ portrait: Bool) {
        if (constraints_toolbar_h != nil) {
            NSLayoutConstraint.deactivate(constraints_toolbar_h)
            NSLayoutConstraint.deactivate(constraints_scrollview_h)
            NSLayoutConstraint.deactivate(constraints_scrollview_v)
            NSLayoutConstraint.deactivate(constraints_total_v)
            NSLayoutConstraint.deactivate(constraints_search_h)
            NSLayoutConstraint.deactivate(constraints_map_h)
        }
        scrollView.frame = view.frame
        var displaywidth = Int((view.frame.width))
        var displayheight = Int((view.frame.height))
        print(displayheight, displaywidth)
        if ((!portrait && displaywidth < displayheight) || (portrait && displayheight < displaywidth)) {
            displaywidth = Int((view.frame.height))
            displayheight = Int((view.frame.width))
        }
        //view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        let format_scrollview_h = "H:|[scroll("+String(displaywidth)+")]|"
        let format_scrollview_v = "V:|-0-[scroll("+String(displayheight)+")]|"
        constraints_scrollview_h = NSLayoutConstraint.constraints(withVisualFormat: format_scrollview_h, options: .alignAllTop, metrics: nil, views: views)
        NSLayoutConstraint.activate(constraints_scrollview_h)
        constraints_scrollview_v = NSLayoutConstraint.constraints(withVisualFormat: format_scrollview_v, options: .alignAllTop, metrics: nil, views: views)
        NSLayoutConstraint.activate(constraints_scrollview_v)
        
        let format_toolbar_h = "H:|[toolbar("+String(displaywidth)+"@1000)]|"
        constraints_toolbar_h = NSLayoutConstraint.constraints(withVisualFormat: format_toolbar_h, options: .alignAllTop, metrics: nil, views: views)
        NSLayoutConstraint.activate(constraints_toolbar_h)
        
        let format_total_v = "V:|[toolbar(==70@1000)]-[map(>="+String(displayheight-180)+"@800)]-[search(==60@1000)]|"
        constraints_total_v = NSLayoutConstraint.constraints(withVisualFormat: format_total_v, options: .alignAllCenterX, metrics: nil, views: views)
        NSLayoutConstraint.activate(constraints_total_v)
        
        let format_map_h = "H:|[map("+String(displaywidth)+")]|"
        constraints_map_h = NSLayoutConstraint.constraints(withVisualFormat: format_map_h, options: .alignAllTop, metrics: nil, views: views)
        NSLayoutConstraint.activate(constraints_map_h)
        
        let format_search_h = "H:|[search("+String(displaywidth)+")]|"
        constraints_search_h = NSLayoutConstraint.constraints(withVisualFormat: format_search_h, options: .alignAllTop, metrics: nil, views: views)
        NSLayoutConstraint.activate(constraints_search_h)
        
        scrollView.backgroundColor = UIColor.gray
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (_) in
            let orient = UIApplication.shared.statusBarOrientation
            self.portrait_oriented = orient.isPortrait
        }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            self.setupViews(self.portrait_oriented)
        })
    }
    
    func addRestrToLine() {
        self.mapView.isScrollEnabled = true
        self.mapView.isZoomEnabled = true
        self.mapView.isRotateEnabled = true
        self.mapView.removeGestureRecognizer(addLinesLongPressGesture)
        self.toolbar.setItems([bbi_map!, bbi_addPoint!, bbi_addLine!], animated: true)
        let TVCAddRestriction = storyboard?.instantiateViewController(withIdentifier: "AddRestriction")
        self.navigationController?.pushViewController(TVCAddRestriction!, animated: true)
    }
    func addPointLongPress(gesture: UILongPressGestureRecognizer) {
        print(gesture)
        if (gesture.state == .ended) {
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            print(coordinate)
            var annotation = MapMarker(coordinate: coordinate)
            self.appDelegate.user.pointsAdded.append(annotation)
            self.mapView.addAnnotation(annotation)
            let TVCAddRestriction = storyboard?.instantiateViewController(withIdentifier: "AddRestriction")
            self.navigationController?.pushViewController(TVCAddRestriction!, animated: true)
        }
    }
    func cancel() {
        self.mapView.removeAnnotation(self.appDelegate.user.pointsAdded.last!)
        self.appDelegate.user.pointsAdded.removeLast()
        self.navigationController?.popViewController(animated: true)
    }
    func done() {
        
        
    }
    func addLinesLongPress(gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: self.mapView)
        let converted = self.mapView.convert(point, toCoordinateFrom: self.mapView)
        lineOfPoints.append(converted)
        print(mapView.annotations.count)
        if (gesture.state == .ended && mapView.annotations.count == 1) {
            var annotation = MapMarker(coordinate: lineOfPoints[0])
            mapView.addAnnotation(annotation)
        }
        if (lineOfPoints.count == 1) {
            self.mapView.isScrollEnabled = false
            self.mapView.isZoomEnabled = false
            self.mapView.isRotateEnabled = false
            self.toolbar.items?.append(bbi_addRestr!)
        } else {
            if (gesture.state == .ended) {
                if (geodesic != nil) {
                    mapView.remove(geodesic!)
                }
                print(lineOfPoints)
                geodesic = MKPolyline(coordinates: &lineOfPoints, count: lineOfPoints.count)
                mapView.addOverlays([geodesic!])
            }
        }
    }
    func addPoint() {
        self.toolbar.setItems([bbi_map!, bbi_addPoint_cancel!], animated: true)
        if let gRec = self.mapView.gestureRecognizers {
            tempGestureRecognizers = gRec
        }
        self.mapView.addGestureRecognizer(addPointLongPressGesture)
    }
    func addPointCancel() {
        self.toolbar.setItems([bbi_map!, bbi_addPoint!, bbi_addLine!], animated: true)
        self.mapView.removeGestureRecognizer(addPointLongPressGesture)
    }
    func addLineCancel() {
        self.mapView.isScrollEnabled = true
        self.mapView.isZoomEnabled = true
        self.mapView.isRotateEnabled = true
        self.mapView.removeGestureRecognizer(addLinesLongPressGesture)
        self.lineOfPoints = []
        self.regionRadius = 2000
        self.centerMapOnLocation(location: CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude))
        if (geodesic != nil) {
            mapView.removeOverlays([geodesic!])
        }
        self.toolbar.setItems([bbi_map!, bbi_addPoint!, bbi_addLine!], animated: true)

    }
    func addLine() {
        self.toolbar.setItems([bbi_map!, bbi_addLine_cancel!], animated: true)
        if let gRec = self.mapView.gestureRecognizers {
            tempGestureRecognizers = gRec
            print(tempGestureRecognizers)
        }
        self.regionRadius = 130
        self.centerMapOnLocation(location: CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude))
        self.mapView.addGestureRecognizer(addLinesLongPressGesture)
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func dismissKeyboard() {
        searchBar.endEditing(true)
    }

    func keyboardWillHide(notification:NSNotification){
        var contentInset:UIEdgeInsets = UIEdgeInsets.zero
        print(self.navigationController?.navigationBar.frame.size.height)
        
        contentInset.top = contentInset.top + (self.navigationController?.navigationBar.frame.size.height)! + 10
        scrollView.contentInset = contentInset
        setupViews(self.portrait_oriented)
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
