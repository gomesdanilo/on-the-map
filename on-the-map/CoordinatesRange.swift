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
    func getParseEscapedJson() -> String {
        
        if minLat == nil || maxLat == nil || minLong == nil || maxLong == nil {
            return ""
        }
        
        // E.g {"score":{"$gte":1000,"$lte":3000}}'
        let jsonData = [
            "latitude" : ["$lte": maxLat!, "$gte": minLat!],
            "longitude" : ["$lte": maxLong!, "$gte": minLong!]
        ]
        
        guard let jsonString = JsonUtil.mapToJsonString(map: jsonData) else {
            return ""
        }
        
        guard let escaped = WebUtils.escapeStringSafeQuery(data: jsonString) else {
            return ""
        }
        
        return escaped
    }
    
}
