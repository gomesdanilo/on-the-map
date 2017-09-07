//
//  LogoutController.swift
//  on-the-map
//
//  Created by Danilo Gomes on 07/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

class LogoutController {

    let viewController : UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    private func goToLoginPage(completion: (() -> Void)?){
        self.viewController.dismiss(animated: true, completion: completion)
    }
    
    private func deleteLocalSession(){
        AppDelegate.sharedInstance().userData.loggedInUser = nil
    }

    private func logoutOnServer(){
        UIUtils.showProgressIndicator()
        UDAClient.sharedInstance().logout { (success, errorMessage) in
            UIUtils.hideProgressIndicator()
            if errorMessage != nil {
                print("Failed to call logout on server. \(errorMessage!)")
                return
            }
            
            print("Logout executed with success on server")
            self.deleteLocalSession()
        }
    }
    
    func logout(){
        
        goToLoginPage { 
            self.logoutOnServer()
        }
    }
}
