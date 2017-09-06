//
//  PARClient.swift
//  on-the-map
//
//  Created by Danilo Gomes on 05/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

class PARClient: NSObject {

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

    func applySecurityHeaders(request : NSMutableURLRequest){
        let headers = getSecurityHeaders()
        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
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
    
    func parseStudentsJson (json : String?) -> [StudentInformation] {
        let defaultValue = [StudentInformation]()
        
        guard let jsonObject = JsonUtil.jsonStringToMap(string: json) else {
            return defaultValue
        }
        
        guard let results = jsonObject["results"] as? [[String : Any?]] else {
            return defaultValue
        }
        
        let students = results.map { (row) -> StudentInformation in
            return StudentInformation(dictionary: row)
        }
        
        return students
    }
    
    
    func retrieveStudentLocations(range : CoordinatesRange, limit : Int = 100,
                                  completionHandler : @escaping (_ data : [StudentInformation]?, _ errorMessage : String?) -> Void) {
    
        let request = createRequestWithUrl("https://parse.udacity.com/parse/classes/StudentLocation")
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                completionHandler(nil, "Failed to retrieve data")
                return
            }
            let jsonString = self.getJsonString(data: data)
            let students = self.parseStudentsJson(json: jsonString)
            completionHandler(students, nil)
        }
        task.resume()
    }
}
