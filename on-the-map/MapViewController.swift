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

    var currentUser : UDAUser?
    let reuseId = "pin"
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = AppDelegate.sharedInstance().currentUser
    }
    
    @IBAction func didClickOnLogout(_ sender: Any) {
        UDAClient.sharedInstance().logout { (success, errorMessage) in
            
            if errorMessage != nil {
                // Error
                return
            }
            
            AppDelegate.sharedInstance().currentUser = nil
            self.goToLoginPage()
        }
    }

    @IBAction func didClickOnRefresh(_ sender: Any) {
        print("refresh")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadMap()
    }
    
    func goToLoginPage(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func getCoordinatesRange(map : MKMapView) -> CoordinatesRange {
        var range = CoordinatesRange()
        
        range.minLat = map.region.center.latitude - (map.region.span.latitudeDelta/2.0)
        range.maxLat = map.region.center.latitude + (map.region.span.latitudeDelta/2.0)
        range.minLong = map.region.center.longitude + (map.region.span.longitudeDelta/2.0)
        range.maxLong = map.region.center.longitude + (map.region.span.longitudeDelta/2.0)
        
        return range
    }
    
    func loadPinsWithMap(map : MKMapView){
        
        let range = getCoordinatesRange(map:map)
        
        self.retrieveData(range: range) { (students, errorMessage) in
            if errorMessage != nil {
                // Error
            } else {
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
}

extension MapViewController : MKMapViewDelegate {

    // MARK: Responding to Map Position Changes
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("regionWillChangeAnimated")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChangeAnimated")
        loadPinsWithMap(map: mapView)
    }
    
    // MARK: Managing Annotation Views
    
    func buildNewAnnotationPin(annotation: MKAnnotation) -> MKAnnotationView {
        
        let newPin = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        newPin.canShowCallout = true
        newPin.image = UIImage(named: "icon_pin")
        newPin.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return newPin
    }
    
    func populateAnnotationPin(annotation: MKAnnotation, pin : MKAnnotationView){
        pin.annotation = annotation
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if pinView == nil {
            pinView = buildNewAnnotationPin(annotation: annotation)
        }
        populateAnnotationPin(annotation: annotation, pin: pinView!)
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        print("didAdd")
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("calloutAccessoryControlTapped")
        
        if control == view.rightCalloutAccessoryView {
            
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: { (success) in
                    
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if "addPin" == segue.identifier {
            if let vc = segue.destination as? AddPinViewController {
                vc.currentUser = self.currentUser
            }
        }
    }
}

