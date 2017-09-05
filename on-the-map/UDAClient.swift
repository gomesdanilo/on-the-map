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
    let baseUrl = "https://www.udacity.com/api"
    
    class func sharedInstance() -> UDAClient {
        struct Singleton {
            static var sharedInstance = UDAClient()
        }
        return Singleton.sharedInstance
    }
    
    
    func getUrl(_ relativePath : String) -> URL {
        return URL(string: baseUrl.appending(relativePath))!
    }
    
    func decodeResponse(data : Data) -> String {
        let range = Range(5..<data.count)
        let newData = data.subdata(in: range)
        return NSString(data: newData, encoding: String.Encoding.utf8.rawValue)! as String
    }
    
    
    func login(email:String, password:String,
               completionHandler : (_ success : Bool,_ errorMessage : String?) -> Void) {
        
        completionHandler(true, nil)
        
//        let request = NSMutableURLRequest(url: getUrl("/session"))
//        request.httpMethod = "POST"
//        
//        // Add headers
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let postData = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
//            .data(using: String.Encoding.utf8)
//        request.httpBody = postData
//        
//        
//        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
//            
//            if error != nil {
//                // Error
//                return
//            }
//            
//            print(self.decodeResponse(data: data!))
//            
//        }
//        
//        task.resume()
    }
    
    func logout(completionHandler : (_ success : Bool,_ errorMessage : String?) -> Void){
        let request = NSMutableURLRequest(url: getUrl("/session"))
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                // Error
                return
            }
            print(self.decodeResponse(data: data!))
        }
        task.resume()
    }
    
    func getUserInfo(userId : String) {
        let request = NSMutableURLRequest(url: getUrl("/users/\(userId)"))
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                // Error
                return
            }
            print(self.decodeResponse(data: data!))
        }
        task.resume()
    
    }
    
    
}
