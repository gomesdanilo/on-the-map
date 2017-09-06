//
//  CoordinatesRange.swift
//  on-the-map
//
//  Created by Danilo Gomes on 06/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

/**
 Represents a coordinate range. E.g a area/square
 */
struct CoordinatesRange {
    
    var minLat : Double?
    var maxLat : Double?
    var minLong : Double?
    var maxLong : Double?
    
    
    /**
     Formats a escaped json to send with the parse api.
     */
    func getParseEscapedJson() -> String? {
        
        let defaultValue = ""
        
        guard let lat0 = minLat else {
            return defaultValue
        }
        
        guard let lat1 = minLat else {
            return defaultValue
        }
        
        guard let long0 = minLat else {
            return defaultValue
        }
        
        guard let long1 = minLat else {
            return defaultValue
        }
        
        // E.g {"score":{"$gte":1000,"$lte":3000}}'
        let jsonData = ["latitude" : ["$lte": lat0, "$gte": lat1],
                    "longitude" : ["$lte":long0, "$gte":long1]]
        
        guard let jsonString = JsonUtil.mapToJsonString(map: jsonData) else {
            return defaultValue
        }
        
        guard let escaped = WebUtils.escapeStringSafeQuery(data: jsonString) else {
            return defaultValue
        }
        
        return escaped
    }
    
}
