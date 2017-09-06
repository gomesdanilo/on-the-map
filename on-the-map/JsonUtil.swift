//
//  JsonUtil.swift
//  on-the-map
//
//  Created by Danilo Gomes on 06/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

class JsonUtil: NSObject {
    
    static func mapToJsonString(map : [String:Any?]) -> String? {
    
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: map, options: .prettyPrinted)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
            return jsonString as String?
        } catch {
            return nil
        }
    }
    
    static func jsonStringToMap(string : String?) -> [String:Any?]? {
        
        guard let data = string?.data(using: .utf8) else {
            return nil
        }
        
        do {
            let map = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return map as? [String:Any?]
        } catch  {
            return nil
        }
    }
}
