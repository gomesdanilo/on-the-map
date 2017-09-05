//
//  UDAClient.swift
//  on-the-map
//
//  Created by Danilo Gomes on 05/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

/**
 This class represents all the communication executed with Udacity APIS.
 */
class UDAClient: NSObject {
    
    let session = URLSession.shared
    
    class func sharedInstance() -> UDAClient {
        struct Singleton {
            static var sharedInstance = UDAClient()
        }
        return Singleton.sharedInstance
    }
    
    
    func login(email:String, password:String,
               completionHandler : (_ success : Bool,_ errorMessage : String?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        
        // Add headers
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let postData = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
            .data(using: String.Encoding.utf8)
        request.httpBody = postData
        
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if error != nil {
                // Error
                return
            }
            
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range)
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            
            
//            {"account": {"registered": true, "key": "10877213997"}, "session": {"id": "1536169741Sefdb365f96eacfc206990708fb482928", "expiration": "2017-11-04T17:49:01.088860Z"}}
        }
        
        task.resume()
    }
}
