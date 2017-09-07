//
//  PinListTableViewController.swift
//  on-the-map
//
//  Created by Danilo Gomes on 05/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

class PinListTableViewController: UITableViewController {

    var userData : UserData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userData = AppDelegate.sharedInstance().userData
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveStudents()
    }
    
    func openBrowserWithStudent(_ student : StudentInformation){
        if let website = student.mediaUrl {
            UIUtils.openWebsite(url: website)
        }
    }
    
    func goToLoginPage(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadStudents(students:[StudentInformation]){
        userData.latestStudents = students
        self.tableView.reloadData()
    }
    
    func retrieveStudents(){
        UIUtils.showProgressIndicator()
        PARClient.sharedInstance().retrieveLatestStudentLocations { (students, error) in
            UIUtils.hideProgressIndicator()
            if error != nil{
                // Error
                return
            }
            self.loadStudents(students: students!)
        }
    }
    
    @IBAction func didClickOnReload(_ sender: Any){
        retrieveStudents()
    }
    
    @IBAction func didClickOnLogout(_ sender: Any) {
        UDAClient.sharedInstance().logout { (success, errorMessage) in
            
            if errorMessage != nil {
                // Error
                return
            }
            
            self.userData.loggedInUser = nil
            self.goToLoginPage()
        }
    }
}

// MARK: - Table delegates

extension PinListTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userData.latestStudents != nil ? userData.latestStudents!.count : 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = userData.latestStudents![indexPath.row]
        openBrowserWithStudent(student)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PinListTableViewCell
        let row = userData.latestStudents![indexPath.row]
        cell.populateWithStudent(row)
        
        return cell
    }

}
