//
//  WebUtils.swift
//  on-the-map
//
//  Created by Danilo Gomes on 06/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

class WebUtils: NSObject {

    static func escapeStringSafeQuery(data : String) -> String? {
        return data.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
}
