//
//  UDAUser.swift
//  on-the-map
//
//  Created by Danilo Gomes on 06/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

struct UDAUser {

    // This is retrieved from login
    var userId : String?
    var fullname : String?
    var firstName : String?
    var lastName : String?
    var email : String?
    
    // This is updated everytime this user posts a new location.
    var location : String?
    var mediaUrl : String?
    var longitude : Double?
    var latitude : Double?
    
    func json() -> String?{
        
        let json = [
            "uniqueKey": self.userId,
            "firstName": self.firstName,
            "lastName":  self.lastName,
            "mapString": self.location,
            "mediaURL": self.mediaUrl,
            "latitude": self.latitude,
            "longitude": self.longitude
            ] as [String : Any?]
        
        let jsonString = JsonUtil.mapToJsonString(map: json)
        return jsonString
    }
}
