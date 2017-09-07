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
    
    private let session = URLSession.shared
    private let baseUrl = "https://www.udacity.com/api"
    
    class func sharedInstance() -> UDAClient {
        struct Singleton {
            static var sharedInstance = UDAClient()
        }
        return Singleton.sharedInstance
    }
    
    private func getUrl(_ relativePath : String) -> URL {
        return URL(string: baseUrl.appending(relativePath))!
    }
    
    private func decodeResponse(data : Data) -> String {
        let range = Range(5..<data.count)
        let newData = data.subdata(in: range)
        return NSString(data: newData, encoding: String.Encoding.utf8.rawValue)! as String
    }
    
    private func getJsonHeaders() -> [String:String] {
        return [
            "Accept" : "application/json",
            "Content-Type" : "application/json"
        ]
    }
    
    private func applyHeaders(headers: [String:String?], request : NSMutableURLRequest){
        for header in headers {
            if let val = header.value {
                request.addValue(val, forHTTPHeaderField: header.key)
            }
        }
    }
    
    private func buildRequest(path : String, method : String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: getUrl(path))
        request.httpMethod = method
        return request
    }
    
    private func getPostDataForLogin(email:String, password:String) -> Data? {
        return "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
            .data(using: String.Encoding.utf8)
    }
    
    
    private func parseJsonMessage(data : Data?) -> [String: Any?]?{
        let jsonString = self.decodeResponse(data: data!)
        return JsonUtil.jsonStringToMap(string: jsonString)
    }
    
    private func getSecutiryCookie() -> String?{
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                return cookie.value
            }
        }
        return nil
    }
    
    private func getSecurityHeaders() -> [String : String?]{
        return ["X-XSRF-TOKEN" : getSecutiryCookie()]
    }
    
    
    func loginAndData(email:String, password:String,
                      completionHandler : @escaping (_ user : UDAUser?, _ errorMessage : String?) -> Void){
    
        self.login(email: email, password: password) { (user, errorMessage) in
            
            if errorMessage != nil {
                // Error
                DispatchQueue.main.async {
                    completionHandler(nil, errorMessage)
                }
                return
            }
            
            self.getUserInfo(userId: user!.userId!, email:email,
                completionHandler: { (userDetails, errorMessage) in
                
                if errorMessage != nil {
                    // Error
                    DispatchQueue.main.async {
                        completionHandler(nil, errorMessage)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completionHandler(userDetails!, nil)
                }
            })
        }
    }
    
    private func login(email:String, password:String,
               completionHandler : @escaping (_ user : UDAUser?, _ errorMessage : String?) -> Void) {
        
        let request = buildRequest(path: "/session", method: Constants.Http.POST)
        applyHeaders(headers: getJsonHeaders(), request: request)
        request.httpBody = getPostDataForLogin(email: email, password: password)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if error != nil {
                // Error
                completionHandler(nil, error!.localizedDescription)
                return
            }
            
            var user = UDAUser.parseWithLogin(dictionary : self.parseJsonMessage(data:data))
            
            if user.loggedIn {
                user.email = email
                completionHandler(user, nil)
            } else {
                completionHandler(nil, user.errorMessage!)
            }
        }
        
        task.resume()
    }
    
    func logout(completionHandler : @escaping (_ success : Bool,_ errorMessage : String?) -> Void){
        let request = buildRequest(path: "/session", method: Constants.Http.DELETE)
        applyHeaders(headers: getSecurityHeaders(), request: request)
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler(false, error!.localizedDescription)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(true, nil)
            }
        }
        task.resume()
    }
    
    private func getUserInfo(userId:String, email: String,
                     completionHandler : @escaping (_ user : UDAUser?, _ errorMessage : String?) -> Void) {
        let request = buildRequest(path: "/users/\(userId)", method: Constants.Http.GET)
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                // Error
                completionHandler(nil, error!.localizedDescription)
                return
            }
            
            var user = UDAUser.parseWithDetails(dictionary : self.parseJsonMessage(data:data))
            
            if user != nil {
                user?.email = email
                user?.userId = userId
                completionHandler(user, nil)
            } else {
                completionHandler(nil, "Failed to retrieve user details")
            }
        }
        task.resume()
    }
}
