//
//  Constants.swift
//  on-the-map
//
//  Created by Danilo Gomes on 07/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

struct Constants {
    
    static let minimumNumberCharactersInput = 4
    static let reuseCellIdentifier = "cell"
    static let reuseAnnotationIdentifier = "pin"
    
    struct Login {
        static let loginUrl = "https://auth.udacity.com/sign-in?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated"
    }
    
    struct Segue {
        static let showMap =  "showMap"
        static let addPinOnMap = "addPinOnMap"
    }

    struct Http {
        static let statusOk = 200
        static let GET = "GET"
        static let DELETE = "DELETE"
        static let POST = "POST"
        static let PUT = "PUT"
    }
    
    struct Msg {
        static let failedToRetrieveLocationData = "Failed to retrieve location data"
        static let failedToSaveLocation = "Failed to save location"
    }
}
