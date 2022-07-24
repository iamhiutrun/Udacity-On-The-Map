//
//  ViewController.swift
//  OnTheMap
//
//  Created by Trung Hieu Luong on 18/07/2022.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var acitivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        username.text = ""
        password.text = ""
        hideIndicator(acitivityIndicator)
    }
    
    @IBAction func login(_ sender: Any) {
        let username = username.text ?? ""
        let password = password.text ?? ""
        if username != "" && password != ""{
            showIndicator(acitivityIndicator)
            UdacityClient.login(username: username, password: password, completion: handleLoginResponse(success:error:))
        }else{
            showAlert(message: "Please input all of required field", title: "Input Error")
        }
        
    }
    
    @IBAction func signUp(_ sender: Any) {
        UIApplication.shared.open(UdacityClient.Endpoints.signUp.url, options: [:], completionHandler: nil)
    }
    
    func handleLoginResponse(success: Bool, error: Error?) {
        DispatchQueue.main.async {
            self.hideIndicator(self.acitivityIndicator)
            if success {
                self.performSegue(withIdentifier: "login", sender: nil)
            } else {
                self.showAlert(message: "Please enter valid credentials.", title: "Login Error")
            }
        }
    }
    
}

