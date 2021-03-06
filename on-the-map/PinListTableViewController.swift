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
    var logoutController : LogoutController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userData = AppDelegate.sharedInstance().userData
        logoutController = LogoutController(viewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveStudentsFromServer()
    }
    
    func openBrowserWithStudent(_ student : StudentInformation){
        if let website = student.mediaUrl {
            UIUtils.openWebsite(url: website)
        }
    }
    
    
    func loadStudents(students:[StudentInformation]){
        userData.latestStudents = students
        self.tableView.reloadData()
    }
    
    func showErrorMessage(_ message : String) {
        UIUtils.showErrorMessage(message, viewController: self)
    }
    
    func retrieveStudentsFromServer(){
        UIUtils.showProgressIndicator()
        PARClient.sharedInstance().retrieveLatestStudentLocations { (students, error) in
            UIUtils.hideProgressIndicator()
            if error != nil{
                self.showErrorMessage(error!)
                return
            }
            self.loadStudents(students: students!)
        }
    }
    
    @IBAction func didClickOnReload(_ sender: Any){
        retrieveStudentsFromServer()
    }
    
    @IBAction func didClickOnLogout(_ sender: Any) {
        logoutController?.logout()
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
        
        let key = Constants.reuseCellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: key) as! PinListTableViewCell
        let row = userData.latestStudents![indexPath.row]
        cell.populateWithStudent(row)
        
        return cell
    }

}
