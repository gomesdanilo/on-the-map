//
//  KeyboardController.swift
//  on-the-map
//
//  Created by Danilo Gomes on 07/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

class KeyboardController : NSObject, UITextFieldDelegate {
    
    // Space between bottom of textfield and keyboard
    let margin : CGFloat = 30
    var activeTextField : UITextField?
    var viewController : UIViewController?
    
    
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        
        guard let field = activeTextField, let root = viewController?.view else {
            return
        }
        
        // Converts frame to root coordinates system.
        let frameField = field.convert(field.bounds, to: root)
        
        let oldYField = frameField.origin.y
        let rootHeight = root.frame.size.height
        let keyboardHeight = getKeyboardHeight(notification)
        let fieldHeight = field.frame.size.height
        
        let newYField = rootHeight - keyboardHeight - fieldHeight - margin
        
        let delta = newYField - oldYField
        
        if delta < 0 {
            moveScreenByDelta(delta)
        } else {
            // field is visible.
        }
    }

    func keyboardWillHide(_ notification:Notification) {
        resetPosition()
    }
    
    func moveScreenByDelta(_ delta : CGFloat){
        viewController?.view.frame.origin.y += delta
    }
    
    func resetPosition(){
        viewController?.view.frame.origin.y = 0
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func manageTextField(_ textField : UITextField){
        textField.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if activeTextField == textField {
            activeTextField = nil
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

