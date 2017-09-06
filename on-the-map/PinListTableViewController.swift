//
//  PinListTableViewController.swift
//  on-the-map
//
//  Created by Danilo Gomes on 05/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

class PinListTableViewController: UITableViewController {

    var students : [StudentInformation]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students != nil ? students!.count : 0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = students![indexPath.row]
        openBrowserWithStudent(student)
    }
    
    func openBrowserWithStudent(_ student : StudentInformation){
        if let website = student.mediaUrl {
            UIUtils.openWebsite(url: website)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PinListTableViewCell
        let row = students![indexPath.row]
        cell.populateWithStudent(row)
        
        return cell
    }
    
    func goToLoginPage(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didClickOnLogout(_ sender: Any) {
        UDAClient.sharedInstance().logout { (success, errorMessage) in
            
            if errorMessage != nil {
                // Error
                return
            }
            
            AppDelegate.sharedInstance().currentUser = nil
            self.goToLoginPage()
        }
    }
}
