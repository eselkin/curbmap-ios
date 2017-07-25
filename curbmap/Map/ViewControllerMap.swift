///Users/eliselkin/Documents/workspace/curbmap/curbmap-ios/curbmap/curbmap.xcodeproj
//  ViewControllerMap.swift
//  curbmap
//
//  Created by Eli Selkin on 7/14/17.
//  Copyright © 2017 curbmap. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class ViewControllerMap: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate  {
    var locationManager: CLLocationManager!
    var userHeading: CLLocationDirection?
    var regionRadius: CLLocationDistance = 1400
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
    var geodesic: CurbmapPolyLine?
    var addPointLongPressGesture: UILongPressGestureRecognizer!
    var addLinesLongPressGesture: UILongPressGestureRecognizer!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var linesToDraw: [CurbmapPolyLine] = []
    var lineBeginning: MapMarker!
    var pointsToDraw: [MapMarker] = []
    var addingPoint: CLLocationCoordinate2D?
    lazy var geocoder = CLGeocoder()
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let topLeft = mapView.convert(CGPoint.zero, toCoordinateFrom: mapView)
        let bottomRight = mapView.convert(CGPoint(x: mapView.frame.width, y: mapView.frame.height), toCoordinateFrom: mapView)
        let headers = [
            "session": appDelegate.user.get_session(),
            "username": appDelegate.user.get_username()
        ]
        let parameters = [
            "lat1": topLeft.latitude,
            "lng1": topLeft.longitude,
            "lat2": bottomRight.latitude,
            "lng2": bottomRight.longitude
        ]
        Alamofire.request("https://curbmap.com:50003/areaPolygon", parameters: parameters, headers: headers).responseJSON { response in
            self.mapView.removeOverlays(self.linesToDraw)
            self.linesToDraw = []
            if var json = response.result.value as? [[String: Any]] {
                if (json.count == 0) {
                    return
                }
                for dict in json {
                    var lineCLLocation: [CLLocationCoordinate2D] = []
                    for point in (dict["coordinates"] as! NSArray) {
                        let pointAsArray = point as! NSArray
                        let newPoint = CLLocationCoordinate2D(latitude: pointAsArray[1] as! Double, longitude: pointAsArray[0] as! Double)
                        lineCLLocation.append(newPoint)
                    }
                    var restrs = [Restriction]()
                    for restr in (dict["restrs"] as! NSArray) {
                        let new_restr = restr as! NSArray
                        let charAsBool: [Bool] = (new_restr[1] as! String).characters.map({(value: Character) -> Bool in return NSString(string: String(value)).boolValue })
                        let restrJson = Restriction(type: new_restr[0] as! String, days: charAsBool, from: (new_restr[3] as! NSString).integerValue, to: (new_restr[4] as! NSString).integerValue, limit: (new_restr[5] as! NSString).integerValue)
                        restrs.append(restrJson)
                    }
                    let line : CurbmapPolyLine = CurbmapPolyLine(coordinates: &lineCLLocation, count: lineCLLocation.count)
                    line.restrictions = restrs
                    self.linesToDraw.append(line)
                }
                self.mapView.addOverlays(self.linesToDraw)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is CurbmapPolyLine {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            let curbmapPoly = overlay as! CurbmapPolyLine
            if (curbmapPoly.restrictions.count > 0) {
                polylineRenderer.strokeColor = getColorForResrictions(curbmapPoly.restrictions, isPoint: false) as? UIColor
            } else {
                polylineRenderer.strokeColor = UIColor.blue
            }
            polylineRenderer.lineWidth = 3
            return polylineRenderer
        } else if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            if (geodesic != nil && (overlay as! MKPolyline) == geodesic!) {
                polylineRenderer.strokeColor = UIColor.blue
                polylineRenderer.lineWidth = 3
                return polylineRenderer
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
    
    func getColorForResrictions(_ r: [Restriction], isPoint: Bool) -> Any {
        var color: UIColor = UIColor.black;
        var colorImg: String = "blackmarker";
        for restriction in r {
            switch(restriction.type) {
                case "hyd", "ns", "np", "rednp", "redns":
                    color = UIColor.red
                    colorImg = "marker_red"
                    break;
                case "whi":
                    if (color != UIColor.red) {
                        color = UIColor.white
                        colorImg = "marker_white"
                    }
                    break;
                case "gre":
                    if (color != UIColor.red) {
                        color = UIColor.green
                        colorImg = "marker_green"
                    }
                    break;
                case "dis":
                    color = UIColor.init(displayP3Red: 0.7, green: 0.7, blue: 1.0, alpha: 1.0)
                    colorImg = "marker_blue"
                    break;
                case "com", "yel":
                    if (color != UIColor.red){
                        colorImg = "marker_yellow"
                        color = UIColor.yellow
                    }
                    break;
                case "met":
                    if (color != UIColor.red) {
                        color = UIColor.magenta
                        colorImg = "marker_magenta"
                    }
                    break;
                case "ppd":
                    if (color != UIColor.red) {
                        color = UIColor.brown
                        colorImg = "marker_brown"
                    }
                    break;
                case "tim":
                    if (color != UIColor.red) {
                        color = UIColor.gray
                        colorImg = "marker_gray"
                    }
                    break;
                default:
                    if (color != UIColor.red){
                        colorImg = "marker_black"
                        color = UIColor.black
                    }
                    break;
            }
        }
        if (isPoint) {
            return colorImg
        } else {
            return color
        }
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
        let TVCAddRestriction = storyboard?.instantiateViewController(withIdentifier: "AddRestriction") as! TableViewControllerAddRestriction
        TVCAddRestriction.isPoint = false
        self.navigationController?.pushViewController(TVCAddRestriction, animated: true)
    }
    func addPointLongPress(gesture: UILongPressGestureRecognizer) {
        if (gesture.state == .ended) {
            let point = gesture.location(in: self.mapView)
            addingPoint = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            let TVCAddRestriction = storyboard?.instantiateViewController(withIdentifier: "AddRestriction")
            self.navigationController?.pushViewController(TVCAddRestriction!, animated: true)
        }
    }
    func cancelPointRestr() {
        self.mapView.removeAnnotation(self.appDelegate.user.pointsAdded.last!)
        self.appDelegate.user.pointsAdded.removeLast()
        self.navigationController?.popViewController(animated: true)
        self.mapView.removeGestureRecognizer(addPointLongPressGesture)
    }
    func cancelLineRestr() {
        self.mapView.removeOverlays([geodesic!])
        self.mapView.removeAnnotation(lineBeginning)
        self.navigationController?.popViewController(animated: true)
        self.mapView.removeGestureRecognizer(addLinesLongPressGesture)
        self.lineOfPoints = []
        self.regionRadius = 1400
        self.centerMapOnLocation(location: CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude))

    }
    func donePoint(r: [Restriction]) {
        print("REALLY DONE")
        let annotation = MapMarker(coordinate: addingPoint!)
        self.appDelegate.user.pointsAdded.append(annotation)
        annotation.restrictions = r
        annotation.color = getColorForResrictions(r, isPoint: true) as! String
        self.mapView.addAnnotation(annotation)
        navigationController?.popViewController(animated: true)
        // add restrictions to line or point
    }
    
    func doneLine(r: [Restriction]) {
        print ("Done with line")
        geodesic?.restrictions = r
        appDelegate.user.linesAdded.append(geodesic!)
        navigationController?.popViewController(animated: true)
        lineOfPoints = []
        self.centerMapOnLocation(location: CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude))
        
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation
        {
            return nil
        }
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = false
        }else{
            annotationView?.annotation = annotation
        }
        print(annotation)
        if (annotation is MapMarker) {
            annotationView?.image = UIImage(named: (annotation as! MapMarker).color)
        }
        return annotationView
    }
    func addLinesLongPress(gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: self.mapView)
        let converted = self.mapView.convert(point, toCoordinateFrom: self.mapView)
        lineOfPoints.append(converted)
        print(mapView.annotations.count)
        if (gesture.state == .ended && mapView.annotations.count == 1) {
            lineBeginning = MapMarker(coordinate: lineOfPoints[0])
            lineBeginning.color = "marker_black"
            mapView.addAnnotation(lineBeginning)
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
                geodesic = CurbmapPolyLine(coordinates: &lineOfPoints, count: lineOfPoints.count)
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
        if (lineBeginning != nil) {
            self.mapView.removeAnnotation(lineBeginning)
        }
        lineBeginning = nil
        self.lineOfPoints = []
        self.regionRadius = 1400
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
        contentInset.top = contentInset.top + (self.navigationController?.navigationBar.frame.size.height)!
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
