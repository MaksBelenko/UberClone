//
//  User.swift
//  UberClone
//
//  Created by Maksim on 19/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

struct User {
    let fullname: String
    let email: String
    let accountType: Int
    
    init(dictionary: [String : Any]) {
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.accountType = dictionary["accountType"] as? Int ?? 0
    }
}
