//
//  UserData.swift
//  on-the-map
//
//  Created by Danilo Gomes on 07/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

// Using class instead of struct, need single reference everywhere.
class UserData: NSObject {
    
    var loggedInUser : UDAUser?
    
    // Lists lastest 100 students. global
    var latestStudents : [StudentInformation]?
    
    // Lists latest 100 students created in a specific region.
    var studentsPerRegion : [StudentInformation]?
}
