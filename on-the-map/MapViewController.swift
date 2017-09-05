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

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPins()
    }
    
    @IBAction func didClickOnLogout(_ sender: Any) {
        print("logout")
    }

    @IBAction func didClickOnRefresh(_ sender: Any) {
        print("refresh")
    }
    
    @IBAction func didClickOnAdd(_ sender: Any) {
        print("add")
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    func loadPins(){
        self.retrieveData { (serverData) in
            self.parseData(data: serverData, completionHandler: { (listPoints) in
                self.populatesMapWithPoints(listPoints)
            })
        }
    }
    
    func populatesMapWithPoints(_ listPoints : [MKPointAnnotation]){
        self.mapView.addAnnotations(listPoints)
    }
    
    func retrieveData(_ completionHandler : @escaping (_ data : [[String : Any]]) -> Void) {
        PARClient.sharedInstance().retrieveFakeData(completionHandler: completionHandler)
    }
    
    func parseData(data: [[String : Any]],  completionHandler : @escaping (_ data : [MKPointAnnotation]) -> Void){
        
        var returnList = [MKPointAnnotation]()
    
        for dictionary in data {
    
            let lat = CLLocationDegrees(dictionary["latitude"] as! Double)
            let long = CLLocationDegrees(dictionary["longitude"] as! Double)
    
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    
            let first = dictionary["firstName"] as! String
            let last = dictionary["lastName"] as! String
            let mediaURL = dictionary["mediaURL"] as! String
    
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            returnList.append(annotation)
        }
        
        completionHandler(returnList)
    }
}

extension MapViewController : MKMapViewDelegate {

    // MARK: Responding to Map Position Changes
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("regionWillChangeAnimated")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChangeAnimated")
    }
    
    // MARK: Managing Annotation Views
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
    
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
    
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .blue
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
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
}

