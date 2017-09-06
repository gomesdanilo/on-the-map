//
//  PinListTableViewCell.swift
//  on-the-map
//
//  Created by Danilo Gomes on 06/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

class PinListTableViewCell: UITableViewCell {

    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    func populateWithStudent(_ student: StudentInformation){
        self.websiteLabel.text = student.mediaUrl
        self.nameLabel.text = student.name
    }
}
