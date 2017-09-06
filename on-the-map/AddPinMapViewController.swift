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

    let reuseId = "pin"
    var currentUser : UDAUser?
    var location : String?
    var website : String?
    @IBOutlet weak var mapView: MKMapView!
    var locationSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goToLocation()
    }
    
    @IBAction func didTapOnConfirmButton(_ sender: Any) {
        if !locationSelected {
            showErrorMessage("Please pin a location first")
            return
        }
    }

    func showErrorMessage(_ message: String?) {
        UIUtils.showErrorMessage(message, viewController: self)
    }
    
    // MARK: - Geocode
    
    func goToLocation(){
        
        if let address = location {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
                if error != nil || placemarks?.count == 0 {
                    self.showErrorMessage("Failed to find address")
                    return
                }
                let place = MKPlacemark(placemark: placemarks![0])
                
                self.goToLocation(place)
                self.placeAnnotation(place)
                self.locationSelected = true
            })
        }
    }
    
    func goToLocation(_ place : MKPlacemark){
        let distanceInMeters : Double = 1000 * 10 // 10 KM
        let region = MKCoordinateRegionMakeWithDistance(place.coordinate, distanceInMeters, distanceInMeters)
        self.mapView.setRegion(region, animated: true)
    }
    
    // MARK: - Annotations
    
    func placeAnnotation(_ place : MKPlacemark){
        let annotation = MKPointAnnotation()
        annotation.coordinate = place.coordinate
        self.mapView.addAnnotation(annotation)
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
