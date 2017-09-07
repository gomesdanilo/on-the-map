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
    
    
    // Used to handle error messages
    var loggedIn = false
    var errorMessage : String?
    
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
    
    
    static func parseWithDetails(dictionary : [String: Any?]?) -> UDAUser? {
    
        guard let data = dictionary else {
            // Invalid json
            return nil
        }
        
        guard let account = data["user"] as? [String: Any?] else {
            // Invalid json
            return nil
        }
        
        guard let firstName = account["first_name"] as? String else {
            // Invalid json
            return nil
        }
        
        guard let lastName = account["last_name"] as? String else {
            // Invalid json
            return nil
        }
        
        var user = UDAUser()
        user.firstName = firstName
        user.lastName = lastName
        user.fullname = "\(firstName) \(lastName)"
        user.loggedIn = true
        return user
    }
    
    static func parseWithLogin(dictionary : [String: Any?]?) -> UDAUser {
        
        guard let data = dictionary else {
            return buildErrorMessage(message: "Invalid message from server")
        }
        
        if let error = data["error"] as? String {
            return buildErrorMessage(message: error)
        }
        
        guard let account = data["account"] as? [String: Any?] else {
            return buildErrorMessage(message: "Invalid message from server")
        }
        
        guard let key = account["key"] as? String else {
            return buildErrorMessage(message: "Invalid message from server")
        }
        
        return buildSuccessMessage(withKey: key)
    }
    
    private static func buildErrorMessage(message : String) -> UDAUser {
        var user = UDAUser()
        user.loggedIn = false
        user.errorMessage = message
        return user
    }
    
    private static func buildSuccessMessage(withKey key : String) -> UDAUser {
        var user = UDAUser()
        user.userId = key
        user.loggedIn = true
        return user
    }
   
}
