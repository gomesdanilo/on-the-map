//
//  StudentInformation.swift
//  on-the-map
//
//  Created by Danilo Gomes on 05/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

struct StudentInformation {

    let name : String
    let mediaUrl : String?
    let lat : Double?
    let long : Double?
    
    init(dictionary : [String : Any?]) {
        
        self.lat = dictionary["latitude"] as? Double
        self.long = dictionary["longitude"] as? Double
        self.mediaUrl = dictionary["mediaURL"] as? String
        
        let first = dictionary["firstName"] as? String
        let last = dictionary["lastName"] as? String
        
        if first != nil && last != nil {
            self.name = "\(first!) \(last!)"
        }
        else {
            self.name = "N/A"
        }
    }
}

