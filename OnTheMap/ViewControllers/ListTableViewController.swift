//
//  ListTableViewController.swift
//  OnTheMap
//
//  Created by Trung Hieu Luong on 20/07/2022.
//

import Foundation
import UIKit
class ListTableViewController : UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var students = [StudentInformation]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentsInformation()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath)
        
        let student = students[indexPath.row]
        cell.textLabel?.text = "\(student.firstName)" + " " + "\(student.lastName)"
        cell.detailTextLabel?.text = "\(student.mediaURL ?? "")"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = students[indexPath.row]
        openLink(student.mediaURL ?? "")
    }
    
    
    @IBAction func refreshData(_ sender: Any) {
        getStudentsInformation()
    }
   
    @IBAction func logout(_ sender: Any) {
        UdacityClient.logout(completion: handleLogoutResponse)
    }
    
    func handleLogoutResponse(){
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
    
    // MARK: Get student information
    
    func getStudentsInformation() {
        UdacityClient.getStudentLocation() {students, error in
            self.students = students ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
