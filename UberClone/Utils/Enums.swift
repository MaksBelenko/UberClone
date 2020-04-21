//
//  Enums.swift
//  UberClone
//
//  Created by Maksim on 21/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import GeoFire

enum DriverLocationInRadius {
    case driverAppeared, driverChangedLocation, driverExited
    
    ///Convert to GeoFire's GFEventType
    func gfEventType() -> GFEventType {
        switch self
        {
        case .driverAppeared:
            return .keyEntered
        case .driverChangedLocation:
            return .keyMoved
        case .driverExited:
            return .keyExited
        }
    }
}
