//
//  PARClient.swift
//  on-the-map
//
//  Created by Danilo Gomes on 05/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

class PARClient: NSObject {
    
    typealias StudentLocationCallback = (_ data : [StudentInformation]?, _ errorMessage : String?) -> Void
    

    let session = URLSession.shared
    let baseUrl = "https://www.udacity.com/api"
    
    class func sharedInstance() -> PARClient {
        struct Singleton {
            static var sharedInstance = PARClient()
        }
        return Singleton.sharedInstance
    }
    
    func getSecurityHeaders() -> [String:String] {
        return ["X-Parse-Application-Id":"QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
                "X-Parse-REST-API-Key" : "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"]
    }
    
    func applyHeaders(_ headers : [String:String], request : NSMutableURLRequest){
        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
    }

    func applySecurityHeaders(request : NSMutableURLRequest){
        applyHeaders(getSecurityHeaders(), request: request)
    }
    
    func createRequestWithUrl(_ url : String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: URL(string: url)!)
        applySecurityHeaders(request: request)
        return request
    }
    
    func getJsonString(data : Data?) -> String? {
        
        guard let validData = data else {
            return nil
        }
        
        guard let validString = NSString(data: validData, encoding: String.Encoding.utf8.rawValue) else {
            return nil
        }
        
        return validString as String
    }
    
    func parseStudentsJson (json : String?) -> [StudentInformation]? {
        
        guard let jsonObject = JsonUtil.jsonStringToMap(string: json) else {
            return nil
        }
        
        guard let results = jsonObject["results"] as? [[String : Any?]] else {
            return nil
        }
        
        let students = results.map { (row) -> StudentInformation in
            return StudentInformation(dictionary: row)
        }
        
        return students
    }
    
    func getServerError(_ data : Data?) -> String{
        let jsonString = self.getJsonString(data: data)
        
        guard let map = JsonUtil.jsonStringToMap(string: jsonString) else {
            return ""
        }
        
        guard let error = map["error"] as? String else {
            return ""
        }
        
        return error
    }
    
    func handleLocationServerResponse(data: Data?, response: URLResponse?,
                                      error : Error?, completionHandler : @escaping StudentLocationCallback) {
        
        DispatchQueue.main.async {
            
            // Validates sdk error
            guard error == nil else {
                completionHandler(nil, Constants.Msg.failedToRetrieveLocationData)
                return
            }
            
            // Validates wrong response type
            guard let resp = response as? HTTPURLResponse else {
                completionHandler(nil, Constants.Msg.failedToRetrieveLocationData)
                return
            }
            
            // Validates status code
            guard resp.statusCode == Constants.Http.statusOk else {
                let descHttp = HTTPURLResponse.localizedString(forStatusCode: resp.statusCode)
                let serverError = self.getServerError(data)
                completionHandler(nil, "\(Constants.Msg.failedToRetrieveLocationData): Details: (\(descHttp) | \(serverError))")
                return
            }
            
            // Validates response format json string
            guard let jsonString = self.getJsonString(data: data) else {
                completionHandler(nil, Constants.Msg.failedToRetrieveLocationData)
                return
            }
            
            // Validates response format students json
            guard let students = self.parseStudentsJson(json: jsonString) else {
                completionHandler(nil, Constants.Msg.failedToRetrieveLocationData)
                return
            }
            
            // Success
            completionHandler(students, nil)
        }
    }
    
    
    
    func retrieveLatestStudentLocations(completionHandler :@escaping StudentLocationCallback){
    
        let request = createRequestWithUrl("https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            self.handleLocationServerResponse(data:data, response:response,
                                              error:error, completionHandler:completionHandler)
            
        }
        task.resume()
    }
    
    
    func retrieveStudentLocations(range : CoordinatesRange, completionHandler : @escaping StudentLocationCallback) {
    
        let rangeParams = range.getParseEscapedJson()
        
        let request = createRequestWithUrl("https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt&where=\(rangeParams)")
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            self.handleLocationServerResponse(data:data, response:response,
                                              error:error, completionHandler:completionHandler)
        }
        task.resume()
    }
    
    
    
    
    func buildSaveBody(user : UDAUser) -> Data? {
        let jsonString = user.json()
        let data = jsonString?.data(using: String.Encoding.utf8)
        return data
    }
    
    func saveStudentLocation(user : UDAUser,
                             completionHandler : @escaping (_ success : Bool, _ errorMessage : String?) -> Void) {
        
        let request = createRequestWithUrl("https://parse.udacity.com/parse/classes/StudentLocation")
        request.httpMethod = "POST"
        applyHeaders(["Content-Type":"application/json"], request: request)
        
        guard let bodyData = buildSaveBody(user: user) else {
            completionHandler(false, "Invalid request parameters")
            return
        }
        
         request.httpBody = bodyData
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                completionHandler(false, "Failed to retrieve data")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                if error != nil {
                    completionHandler(false, "Failed to retrieve data")
                }
                return
            }
            
            DispatchQueue.main.async {
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    completionHandler(true, nil)
                } else {
                    completionHandler(false, "Failed to save location")
                }
            }
        }
        task.resume()
    }
}
