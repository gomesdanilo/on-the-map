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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func didClickOnLoginButton(_ sender: Any) {
        print("Login clicked")
        login()
    }
    
    
    
    
    // MARK: API Calls
    
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
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func navigateToMap(){
        self.performSegue(withIdentifier: "showMap", sender: self)
    }
    
    func login(){
        if !validateCredentials(showErrorMessage) {
            return
        }
        
        UDAClient.sharedInstance().login(email: emailTextfield.text!, password: passwordTextfield.text!) { (success, errorMessage) in
            
            if success {
                print("login is ok")
                self.navigateToMap()
            } else {
                showErrorMessage(errorMessage)
            }
        }
    }
}
