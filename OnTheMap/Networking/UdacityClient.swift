//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Trung Hieu Luong on 20/07/2022.
//

import Foundation
class UdacityClient {
    
    static let apiKey = "4e03fca1263f03121f98f4d8b76837d9"
    
    struct Auth{
        static var sessionId: String? = nil
        static var key = ""
        static var firstName = ""
        static var lastName = ""
        static var objectId = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case login
        case logout
        case studentLocation
        case addLocation
        case updateLocation
        case getLoggedInUserProfile
        case signUp
        
        var stringValue: String {
            switch self {
            case .signUp:
                return "https://auth.udacity.com/sign-up"
            case .login: return Endpoints.base + "/session"
            case .logout: return Endpoints.base + "/logout"
            case .studentLocation: return Endpoints.base + "/StudentLocation?limit=100&order=-updatedAt"
            case .addLocation: return Endpoints.base + "/StudentLocation"
            case .updateLocation:
                return Endpoints.base + "/StudentLocation/" + Auth.objectId
            case .getLoggedInUserProfile:
                return Endpoints.base + "/users/" + Auth.key
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func login(username:String, password:String, completion: @escaping (Bool,Error?)->Void){
        let body = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        RequestHelpers.taskForPOSTRequest(url: Endpoints.login.url, apiType: "Udacity", responseType: LoginResponse.self, body: body, httpMethod: "POST") { (data, error) in
            if let data = data {
                Auth.sessionId = data.session.id
                Auth.key = data.account.key
                getLoggedInUserProfile(completion: { (success, error) in
                    if success {
                        print("Logged in user's profile fetched.")
                    }
                })
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    
    // MARK: Get Logged In User's Name
    
    class func getLoggedInUserProfile(completion: @escaping (Bool, Error?) -> Void) {
        RequestHelpers.taskForGETRequest(url: Endpoints.getLoggedInUserProfile.url, apiType: "Udacity", responseType: UserProfile.self) { (data, error) in
            if let data = data {
                print("First Name : \(data.firstName) && Last Name : \(data.lastName) && Full Name: \(data.nickname)")
                Auth.firstName = data.firstName
                Auth.lastName = data.lastName
                completion(true, nil)
            } else {
                print("Failed to get user's profile.")
                completion(false, error)
            }
        }
    }
    
    class func logout(completion: @escaping ()->Void){
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                print("Error logout")
                return
            }
            let range = 5..<data!.count
            let newData = data?.subdata(in: range)
            print(String(data: newData!, encoding: .utf8)!)
            Auth.sessionId = ""
            completion()
        }
        task.resume()
    }
    
    class func getStudentLocation(completion: @escaping ([StudentInformation]?, Error?) -> Void){
        RequestHelpers.taskForGETRequest(url: Endpoints.studentLocation.url, apiType: "Parse", responseType: StudentLocation.self) { (data, error) in
            if let data = data{
                completion(data.results,nil)
            }else{
                completion([],error)
            }
        }
    }
    
    // MARK: Add a Location
    
    class func addStudentLocation(information: StudentInformation, completion: @escaping (Bool, Error?) -> Void) {
        let body = "{\"uniqueKey\": \"\(information.uniqueKey ?? "")\", \"firstName\": \"\(information.firstName)\", \"lastName\": \"\(information.lastName)\",\"mapString\": \"\(information.mapString ?? "")\", \"mediaURL\": \"\(information.mediaURL ?? "")\",\"latitude\": \(information.latitude ?? 0.0), \"longitude\": \(information.longitude ?? 0.0)}"
        print(body)
        RequestHelpers.taskForPOSTRequest(url: Endpoints.addLocation.url, apiType: "Parse", responseType: PostLocationResponse.self, body: body, httpMethod: "POST") { (response, error) in
            if let response = response, response.createdAt != nil {
                Auth.objectId = response.objectId ?? ""
                completion(true, nil)
            }
            completion(false, error)
        }
    }
    
    // MARK: Update Location
    
    class func updateStudentLocation(information: StudentInformation, completion: @escaping (Bool, Error?) -> Void) {
        let body = "{\"uniqueKey\": \"\(information.uniqueKey ?? "")\", \"firstName\": \"\(information.firstName)\", \"lastName\": \"\(information.lastName)\",\"mapString\": \"\(information.mapString ?? "")\", \"mediaURL\": \"\(information.mediaURL ?? "")\",\"latitude\": \(information.latitude ?? 0.0), \"longitude\": \(information.longitude ?? 0.0)}"
        RequestHelpers.taskForPOSTRequest(url: Endpoints.updateLocation.url, apiType: "Parse", responseType: UpdateLocationResponse.self, body: body, httpMethod: "PUT") { (response, error) in
            if let response = response, response.updatedAt != nil {
                completion(true, nil)
            }
            completion(false, error)
        }
    }
    
    
}
