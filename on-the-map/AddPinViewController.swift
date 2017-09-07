//
//  AddPinViewController.swift
//  on-the-map
//
//  Created by Danilo Gomes on 05/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import MapKit

class AddPinViewController: UIViewController {

    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var websiteTextfield: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let geocoder = AddPinGeocoder()
    var coordinates : CLLocationCoordinate2D?
    var userData : UserData!
    var keyboardController : KeyboardController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userData = AppDelegate.sharedInstance().userData
        updateUserName()
        
        keyboardController = KeyboardController()
        keyboardController?.viewController = self
        keyboardController?.manageTextField(locationTextfield!)
        keyboardController?.manageTextField(websiteTextfield!)
    }
    
    func updateUserName(){
        if let user = userData.loggedInUser?.fullname {
            self.nameLabel.text = user
        } else {
            self.nameLabel.text = "< Name >"
        }
    }
    
    func isTextFieldValid(_ textField : UITextField) -> Bool{
        return textField.text != nil &&
            textField.text!.characters.count > Constants.minimumNumberCharactersInput
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
            searchAddressGeocode()
        }
    }
    
    func searchAddressGeocode(){
    
        showLoadingUI()
        geocoder.findCoordinates(withAddress: locationTextfield.text!) { (coordinates, errorMessage) in
            self.hideLoadingUI()
            if errorMessage != nil {
                self.showErrorMessage(errorMessage!)
                return
            }
            self.goToAddPinOnMapScreen(coordinates: coordinates!)
        }
    }
    
    func goToAddPinOnMapScreen(coordinates : CLLocationCoordinate2D){
        self.coordinates = coordinates
        self.performSegue(withIdentifier: Constants.Segue.addPinOnMap, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if Constants.Segue.addPinOnMap == segue.identifier {
            if let vc = segue.destination as? AddPinMapViewController {
                vc.location = self.locationTextfield.text!
                vc.website = self.websiteTextfield.text!
                vc.coordinates = self.coordinates!
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardController?.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardController?.unsubscribeToKeyboardNotifications()
    }
    
    func showLoadingUI(){
        view.isUserInteractionEnabled = false
        UIUtils.showProgressIndicator()
        activityIndicator?.startAnimating()
    }
    
    func hideLoadingUI(){
        view.isUserInteractionEnabled = true
        UIUtils.hideProgressIndicator()
        activityIndicator?.stopAnimating()
    }
    
}
