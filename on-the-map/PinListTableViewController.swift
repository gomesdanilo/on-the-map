//
//  PinListTableViewController.swift
//  on-the-map
//
//  Created by Danilo Gomes on 05/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

class PinListTableViewController: UITableViewController {

    var currentUser : UDAUser?
    var students : [StudentInformation]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = AppDelegate.sharedInstance().currentUser
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveStudents()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if "addPin" == segue.identifier {
            if let vc = segue.destination as? AddPinViewController {
                vc.currentUser = self.currentUser
            }
        }
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
        self.students = students
        self.tableView.reloadData()
    }
    
    func retrieveStudents(){
        PARClient.sharedInstance().retrieveLatestStudentLocations { (students, error) in
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
            
            AppDelegate.sharedInstance().currentUser = nil
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
        return students != nil ? students!.count : 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = students![indexPath.row]
        openBrowserWithStudent(student)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PinListTableViewCell
        let row = students![indexPath.row]
        cell.populateWithStudent(row)
        
        return cell
    }

}
