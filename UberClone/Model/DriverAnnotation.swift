//
//  DriverAnnotation.swift
//  UberClone
//
//  Created by Maksim on 21/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import MapKit

let annotationIdentifier = "DiverAnnotaton"


class DriverAnnotation: NSObject, MKAnnotation {
    
    dynamic var coordinate: CLLocationCoordinate2D
    var uid: String
    
    init(uid:String, coordinate: CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
    }
    
    
    
    func updateAnnotationPosition(with coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.2) {
            self.coordinate = coordinate
        }
    }
    
}
