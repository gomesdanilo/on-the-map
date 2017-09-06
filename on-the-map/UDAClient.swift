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
    
    func getJsonHeaders() -> [String:String] {
        return [
            "Accept" : "application/json",
            "Content-Type" : "application/json"
        ]
    }
    
    func applyHeaders(headers: [String:String], request : NSMutableURLRequest){
        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
    }
    
    func buildRequest(path : String, method : String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: getUrl(path))
        request.httpMethod = method
        return request
    }
    
    func getPostDataForLogin(email:String, password:String) -> Data? {
        return "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
            .data(using: String.Encoding.utf8)
    }
    
    
    func loginAndData(email:String, password:String,
                      completionHandler : @escaping (_ user : UDAUser?, _ errorMessage : String?) -> Void){
    
        self.login(email: email, password: password) { (user, errorMessage) in
            
            if errorMessage != nil {
                // Error
                completionHandler(nil, errorMessage)
                return
            }
            
            self.getUserInfo(userId: user!.userId!, email:email,
                completionHandler: { (userDetails, errorMessage) in
                
                if errorMessage != nil {
                    // Error
                    completionHandler(nil, errorMessage)
                    return
                }
                
                completionHandler(userDetails!, nil)
            })
        }
    }
    
    private func login(email:String, password:String,
               completionHandler : @escaping (_ user : UDAUser?, _ errorMessage : String?) -> Void) {
        
        let request = buildRequest(path: "/session", method: "POST")
        applyHeaders(headers: getJsonHeaders(), request: request)
        request.httpBody = getPostDataForLogin(email: email, password: password)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if error != nil {
                // Error
                completionHandler(nil, error!.localizedDescription)
                return
            }
            
            if let dic = self.parseJsonMessage(data:data) {
                if let account = dic["account"] as? [String: Any?] {
                    let key = account["key"] as? String
                    var user = UDAUser()
                    user.userId = key
                    completionHandler(user, nil)
                    return
                }
                
                if let error = dic["error"] as? String {
                    completionHandler(nil, error)
                    return
                }
            }
            
            completionHandler(nil, "Failed to login")
        }
        
        task.resume()
    }
    
    func parseJsonMessage(data : Data?) -> [String: Any?]?{
        let jsonString = self.decodeResponse(data: data!)
        return JsonUtil.jsonStringToMap(string: jsonString)
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
    
    private func getUserInfo(userId:String, email: String,
                     completionHandler : @escaping (_ user : UDAUser?, _ errorMessage : String?) -> Void) {
        let request = NSMutableURLRequest(url: getUrl("/users/\(userId)"))
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                // Error
                completionHandler(nil, error!.localizedDescription)
                return
            }
            
            if let dic = self.parseJsonMessage(data:data) {
                if let account = dic["user"] as? [String: Any?] {
                    let firstName = account["first_name"] as? String
                    let lastName = account["last_name"] as? String
                    
                    var fullName = ""
                    if firstName != nil{
                        fullName.append(firstName!)
                    }
                    if lastName != nil{
                        fullName.append(" ")
                        fullName.append(lastName!)
                    }
                    
                    var user = UDAUser()
                    user.name = fullName
                    user.userId = userId
                    user.email = email
                    completionHandler(user, nil)
                    return
                }
            }
            
            completionHandler(nil, "Failed to retrieve user data")
        }
        task.resume()
    }
}
