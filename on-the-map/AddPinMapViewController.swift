//
//  AddPinMapViewController.swift
//  on-the-map
//
//  Created by Danilo Gomes on 06/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import MapKit

class AddPinMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let reuseId = "pin"
    var location : String?
    var website : String?
    var annotation : MKPointAnnotation?
    var coordinates : CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let coord = coordinates {
            goToLocation(coodinates: coord)
            placeAnnotation(coodinates: coord)
        }
    }
    
    func updateUser() {
        // TODO: Check this
        // This code is dupicated because we can't keep reference for user. It's a struct...
        AppDelegate.sharedInstance().currentUser?.location = location
        AppDelegate.sharedInstance().currentUser?.mediaUrl = website
        AppDelegate.sharedInstance().currentUser?.latitude = annotation!.coordinate.latitude
        AppDelegate.sharedInstance().currentUser?.longitude = annotation!.coordinate.longitude
    }
    
    @IBAction func didTapOnConfirmButton(_ sender: Any) {
        updateUser()
        self.navigationController?.popToRootViewController(animated: true)
    }

    func showErrorMessage(_ message: String?) {
        UIUtils.showErrorMessage(message, viewController: self)
    }
    
    // MARK: - Geocode / Annotations
    
    func goToLocation(coodinates : CLLocationCoordinate2D){
        let distanceInMeters : Double = 1000 * 10 // 10 KM
        let region = MKCoordinateRegionMakeWithDistance(coodinates, distanceInMeters, distanceInMeters)
        self.mapView.setRegion(region, animated: true)
    }
    
    func placeAnnotation(coodinates : CLLocationCoordinate2D){
        annotation = MKPointAnnotation()
        annotation!.coordinate = coodinates
        self.mapView.addAnnotation(annotation!)
    }
    
    func buildNewAnnotationPin(annotation: MKAnnotation) -> MKAnnotationView {
        let newPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        newPin.isDraggable = true
        newPin.animatesDrop = true
        return newPin
    }
    
    func populateAnnotationPin(annotation: MKAnnotation, pin : MKAnnotationView){
        pin.annotation = annotation
    }
}

extension AddPinMapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if pinView == nil {
            pinView = buildNewAnnotationPin(annotation: annotation)
        }
        populateAnnotationPin(annotation: annotation, pin: pinView!)
        
        return pinView
    }
}
