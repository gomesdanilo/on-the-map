//
//  UIUtils.swift
//  on-the-map
//
//  Created by Danilo Gomes on 06/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

class UIUtils {

    static func showErrorMessage(_ message: String?, viewController: UIViewController) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }

    static func openWebsite(url urlString: String) {
        
        if urlString == "" {
            return
        }
        
        guard let url = URL(string: urlString) else {
            // Invalid url
            return
        }
        
        let app = UIApplication.shared
        app.open(url, options: [:], completionHandler: { (success) in
            // Results...
        })
    }
    
    static func showProgressIndicator(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    static func hideProgressIndicator(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
