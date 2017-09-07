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
    var userData : UserData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userData = AppDelegate.sharedInstance().userData
        
        if let coord = coordinates {
            goToLocation(coodinates: coord)
            placeAnnotation(coodinates: coord)
        }
    }
    
    func updateUser() {
        userData.loggedInUser?.location = location
        userData.loggedInUser?.mediaUrl = website
        userData.loggedInUser?.latitude = annotation!.coordinate.latitude
        userData.loggedInUser?.longitude = annotation!.coordinate.longitude
    }
    
    @IBAction func didTapOnConfirmButton(_ sender: Any) {
        
        updateUser()
        saveLocationOnServer { (success, errorMessage) in
            if success {
                self.returnToMainScreen()
            } else {
                self.showErrorMessage(errorMessage!)
            }
        }
    }
    
    func saveLocationOnServer(completionHandler : @escaping (_ success : Bool, _ errorMessage : String?) -> Void){
        PARClient.sharedInstance().saveStudentLocation(user: userData.loggedInUser!,
                                                       completionHandler: completionHandler)
    }
    
    func returnToMainScreen(){
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
