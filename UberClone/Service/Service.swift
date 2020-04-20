//
//  Service.swift
//  UberClone
//
//  Created by Maksim on 19/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import Firebase
import CoreLocation
import GeoFire


let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")


struct Service {
    
    ///let constant in order to share Service
    static let shared = Service()
    
    
    /**
     Fetches user data for specified uid
     - Parameter uid: User's unique ID in firebase
     - Parameter completion: Closure that returns the user data
     */
    func fetchUserData(uid: String, completion: @escaping(User) -> Void) {
        print("DEBUG: Fetching use data for uid = \(uid)")
        
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let user = User(dictionary: dictionary)
            
            completion(user)
        }
    }
    
    
    
    /**
     Fetches nearby drivers' locations
     - Parameter location: Location of the rider
     - Parameter completion: Closure that returns drivers in the area
     */
    func fetchDrivers(location: CLLocation, completion: @escaping(User) -> Void) {
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        
        geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { (uid, location) in
            self.fetchUserData(uid: uid) { (user) in
                var driver = user
                driver.location = location
                completion(driver)
            }
        })
    }
    
    
}
