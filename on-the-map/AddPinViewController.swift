//
//  AddPinViewController.swift
//  on-the-map
//
//  Created by Danilo Gomes on 05/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

class AddPinViewController: UIViewController {

    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var websiteTextfield: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    
    var currentUser : UDAUser?
    
    let segueAddPinOnMap = "addPinOnMap"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUserName()
    }
    
    func updateUserName(){
        if let user = currentUser?.fullname {
            self.nameLabel.text = user
        } else {
            self.nameLabel.text = "< Name >"
        }
    }
    
    func isTextFieldValid(_ textField : UITextField) -> Bool{
        return textField.text != nil && textField.text!.characters.count > 4
    }
    
    func isUserInpuValid(_ completionHandler : (String) -> Void) -> Bool{
        if !isTextFieldValid(locationTextfield) {
            completionHandler("Invalid location")
            return false
        }
        
        if !isTextFieldValid(websiteTextfield) {
            completionHandler("Invalid website")
            return false
        }
        return true
    }
    
    func showErrorMessage(_ message: String?) {
        UIUtils.showErrorMessage(message, viewController: self)
    }

    @IBAction func didClickOnFindLocation(_ sender: Any) {
        let valid = isUserInpuValid { (message) in
            showErrorMessage(message)
        }
        
        if valid {
            self.goToAddPinOnMapScreen()
        }
    }
    
    func goToAddPinOnMapScreen(){
        self.performSegue(withIdentifier: segueAddPinOnMap, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segueAddPinOnMap == segue.identifier {
            if let vc = segue.destination as? AddPinMapViewController {
                vc.location = self.locationTextfield.text!
                vc.website = self.websiteTextfield.text!
            }
        }
    }
}
