//
//  LoginRequest.swift
//  OnTheMap
//
//  Created by Trung Hieu Luong on 20/07/2022.
//

import Foundation
struct LoginRequest : Codable {
    let username: String
    let password: String
    
    enum CodingKeys: String, CodingKey{
        case username = "username"
        case password = "password"
    }
}
