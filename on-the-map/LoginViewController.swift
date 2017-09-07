//
//  LoginViewController.swift
//  on-the-map
//
//  Created by Danilo Gomes on 05/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    var userData : UserData!
    var keyboardController : KeyboardController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userData = AppDelegate.sharedInstance().userData
        
        keyboardController = KeyboardController()
        keyboardController?.viewController = self
        keyboardController?.manageTextField(emailTextfield!)
        keyboardController?.manageTextField(passwordTextfield!)
        
    }
    
    @IBAction func didClickOnLoginButton(_ sender: Any) {
        login()
    }
    
    func validateCredentials(_ errorMessageCallback : (_ message: String) -> Void) -> Bool {
        
        let isTextValid = {(txt : UITextField) in
            return txt.text != nil && txt.text!.characters.count > 4
        }
        
        if !isTextValid(emailTextfield) {
            errorMessageCallback("Invalid email")
            return false
        }
        
        if !isTextValid(passwordTextfield) {
            errorMessageCallback("Invalid password")
            return false
        }
        
        return true
    }
    
    func showErrorMessage(_ message: String?) {
        UIUtils.showErrorMessage(message, viewController: self)
    }
    
    func navigateToMap(){
        self.performSegue(withIdentifier: "showMap", sender: self)
    }
    
    func login(){
        if !validateCredentials(showErrorMessage) {
            return
        }
        let email = emailTextfield.text!
        let password = passwordTextfield.text!
        
        UIUtils.showProgressIndicator()
        UDAClient.sharedInstance().loginAndData(email: email, password: password) { (user, errorMessage) in
            UIUtils.hideProgressIndicator()
            
            if errorMessage == nil {
                self.userData.loggedInUser = user
                self.navigateToMap()
            } else {
                self.showErrorMessage(errorMessage!)
            }
        }
    }
    
    @IBAction func didClickOnSignUp(_ sender : Any) {
        UIUtils.openWebsite(url: Constants.Login.loginUrl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardController?.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardController?.unsubscribeToKeyboardNotifications()
    }
}
