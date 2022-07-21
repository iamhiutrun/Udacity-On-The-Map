//
//  UserProfile.swift
//  OnTheMap
//
//  Created by Trung Hieu Luong on 21/07/2022.
//

import Foundation
struct UserProfile: Codable {
    let firstName: String
    let lastName: String
    let nickname: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case nickname
    }
 
}
