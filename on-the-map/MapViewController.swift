//
//  MapViewController.swift
//  on-the-map
//
//  Created by Danilo Gomes on 05/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var userData : UserData!
    let reuseId = "pin"
    
    var logoutController : LogoutController?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userData = AppDelegate.sharedInstance().userData
        logoutController = LogoutController(viewController: self)
    }
    
    @IBAction func didClickOnLogout(_ sender: Any) {
        logoutController?.logout()
    }

    @IBAction func didClickOnRefresh(_ sender: Any) {
        print("refresh")
        reloadMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadMap()
    }
    
    
    func getCoordinatesRange(map : MKMapView) -> CoordinatesRange {
        var range = CoordinatesRange()
        
        range.minLat = map.region.center.latitude - map.region.span.latitudeDelta
        range.maxLat = map.region.center.latitude + map.region.span.latitudeDelta
        range.minLong = map.region.center.longitude - map.region.span.longitudeDelta
        range.maxLong = map.region.center.longitude + map.region.span.longitudeDelta
        
        return range
    }
    
    func loadPinsWithMap(map : MKMapView){
        
        let range = getCoordinatesRange(map:map)
        UIUtils.showProgressIndicator()
        self.retrieveData(range: range) { (students, errorMessage) in
            UIUtils.hideProgressIndicator()
            if errorMessage != nil {
                // Error
            } else {
                self.userData.studentsPerRegion = students
                self.convertStudentToAnnotation(students: students!, completionHandler: { (annotations) in
                    self.populatesMapWithPoints(annotations)
                })
            }
        }
    }
    
    func populatesMapWithPoints(_ listPoints : [MKPointAnnotation]){
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotations(listPoints)
    }
    
    func retrieveData(range: CoordinatesRange,
                      _ completionHandler : @escaping (_ data : [StudentInformation]?, _ errorMessage: String?) -> Void) {
        PARClient.sharedInstance().retrieveStudentLocations(range: range,
                                                            completionHandler: completionHandler)
    }
    
    func convertStudentToAnnotation(students: [StudentInformation],  completionHandler : @escaping (_ data : [MKPointAnnotation]) -> Void){
        
        let ret = students.map { (student) -> MKPointAnnotation in
            let lat = CLLocationDegrees(student.lat!)
            let long = CLLocationDegrees(student.long!)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = student.name
            annotation.subtitle = student.mediaUrl
            
            return annotation
        }
        
        completionHandler(ret)
    }
    
    func reloadMap(){
        loadPinsWithMap(map: self.mapView)
    }
    
    // MARK: Managing Annotation Views
    
    func buildNewAnnotationPin(annotation: MKAnnotation) -> MKAnnotationView {
        
        let newPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        newPin.canShowCallout = true
        newPin.pinTintColor = MKPinAnnotationView.greenPinColor()
        newPin.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return newPin
    }
    
    func populateAnnotationPin(annotation: MKAnnotation, pin : MKAnnotationView){
        pin.annotation = annotation
    }
    
}

extension MapViewController : MKMapViewDelegate {

    // MARK: Responding to Map Position Changes

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        loadPinsWithMap(map: mapView)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if pinView == nil {
            pinView = buildNewAnnotationPin(annotation: annotation)
        }
        populateAnnotationPin(annotation: annotation, pin: pinView!)
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control != view.rightCalloutAccessoryView {
            return
        }
        
        // subtitle is double optional for some reason.
        if let url1 = view.annotation?.subtitle, let url = url1 {
            UIUtils.openWebsite(url: url)
        }
    }
}

