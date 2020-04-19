//
//  Service.swift
//  UberClone
//
//  Created by Maksim on 19/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Firebase

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")

struct Service {
    
    static let shared = Service()
    let currentUid = Auth.auth().currentUser?.uid
    
    func fetchUserData(completion: @escaping(User) -> Void) {
        print("DEBUG: Fetching use data, current uid = \(currentUid!)")
        REF_USERS.child(currentUid!).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let user = User(dictionary: dictionary)
            
            print("DEBUG: Current user's email: \(user.email)")
            print("DEBUG: Current user's full name: \(user.fullname)")
            
            completion(user)
        }
    }
}
