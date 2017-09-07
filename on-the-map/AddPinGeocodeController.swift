//
//  AddPinGeocodeController.swift
//  on-the-map
//
//  Created by Danilo Gomes on 07/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import MapKit

class AddPinGeocodeController: NSObject {

    func findCoordinates(withAddress address : String,
                     completionHandler : @escaping (_ coordinates : CLLocationCoordinate2D?, _ errorMessage : String?) -> Void){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil || placemarks?.count == 0 {
                
                DispatchQueue.main.async {
                    completionHandler(nil, "Failed to find address")
                }
                return
            }
            let place = MKPlacemark(placemark: placemarks![0])
            DispatchQueue.main.async {
                completionHandler(place.coordinate, nil)
            }
        })
    }
    
}
