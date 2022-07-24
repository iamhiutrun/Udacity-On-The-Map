//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Trung Hieu Luong on 20/07/2022.
//

import Foundation
import UIKit
import MapKit

class MapViewController : UIViewController, MKMapViewDelegate {
    
    // MARK: IBOutlet
    @IBOutlet weak var mapView: MKMapView!
    
    var locations = [StudentInformation]()
    var annotations = [MKPointAnnotation]()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getStudentLocation()
    }
    
    func getStudentLocation(){
        UdacityClient.getStudentLocation(){locations, error in
            if error == nil{
                self.mapView.removeAnnotations(self.annotations)
                self.annotations.removeAll()
                self.locations = locations ?? []
                for dictionary in locations ?? [] {
                    let lat = CLLocationDegrees(dictionary.latitude ?? 0.0)
                    let long = CLLocationDegrees(dictionary.longitude ?? 0.0)
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    let first = dictionary.firstName
                    let last = dictionary.lastName
                    let mediaURL = dictionary.mediaURL
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(first) \(last)"
                    annotation.subtitle = mediaURL
                    self.annotations.append(annotation)
                }
                DispatchQueue.main.async {
                    self.mapView.addAnnotations(self.annotations)
                }
            }else{
                DispatchQueue.main.async {
                    self.showAlert(message: "Can not download data", title: "Error")
                }
            }
        }
    }
    
    
    // MARK: IBAction
    
    @IBAction func refreshData(_ sender: Any) {
        getStudentLocation()
    }
    
    @IBAction func logout(_ sender: Any) {
        UdacityClient.logout(completion: handleLogoutResponse)
    }
    
    func handleLogoutResponse(){
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
    
    // MARK: Map view data source
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle {
                openLink(toOpen ?? "")
            }
        }
    }
    
}
