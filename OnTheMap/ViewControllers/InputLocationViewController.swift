//
//  InputLocationViewController.swift
//  OnTheMap
//
//  Created by Trung Hieu Luong on 20/07/2022.
//

import Foundation
import UIKit
import MapKit

class InputLocationViewController: UIViewController, UITextFieldDelegate{
    
    var objectId: String?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        hideIndicator(activityIndicator)
    }
    // MARK: Find location action
    
    @IBAction func findLocation(sender: UIButton) {
        let location = locationTextField.text
        geocodePosition(newLocation: location ?? "")
    }
    
    // MARK: Find geocode position
    
    private func geocodePosition(newLocation: String) {
        showIndicator(activityIndicator)
        CLGeocoder().geocodeAddressString(newLocation) { (newMarker, error) in
            if let error = error {
                self.showAlert(message: error.localizedDescription, title: "Location Not Found")
                print("Location not found.")
            } else {
                var location: CLLocation?
                
                if let marker = newMarker, marker.count > 0 {
                    location = marker.first?.location
                }
                
                if let location = location {
                    self.navigateToConfirm(location: location.coordinate)
                } else {
                    self.showAlert(message: "Please try again later.", title: "Error")
                    print("There was an error.")
                }
            }
            self.hideIndicator(self.activityIndicator)
        }
    }
    
    func navigateToConfirm(location: CLLocationCoordinate2D){
        let controller = storyboard?.instantiateViewController(withIdentifier: "confirmlocationviewcontroller") as! ConfirmLocationViewController
        controller.studentInformation = buildStudentInfo(location)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func buildStudentInfo(_ coordinate: CLLocationCoordinate2D) -> StudentInformation {
        var studentInfo = [
            "uniqueKey": UdacityClient.Auth.key,
            "firstName": UdacityClient.Auth.firstName,
            "lastName": UdacityClient.Auth.lastName,
            "mapString": locationTextField.text!,
            "mediaURL": "",
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            ] as [String: AnyObject]
        
        if let objectId = objectId {
            studentInfo["objectId"] = objectId as AnyObject
            print(objectId)
        }
        return StudentInformation(studentInfo)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        locationTextField.resignFirstResponder()
        return true
    }
    
}
