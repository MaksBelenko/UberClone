//
//  HomeController.swift
//  UberClone
//
//  Created by Maksim on 18/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit
import Firebase
import MapKit


class HomeController: UIViewController {

    private let locationManager = CLLocationManager()
    private let mapView = MKMapView()
    private var testButton: UIButton!
    
    
    
    
    
    //MARK: - Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        view.backgroundColor = .backgroundColour
        checkIfUserLoggedIn()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        enableLocationServices()
    }
    
    
    //MARK: - API
    
    private func checkIfUserLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            print("DEBUG: User NOT logged in")
            showLoginPage()
        } else {
            print("DEBUG: User id is \(Auth.auth().currentUser?.uid)")
            configureUI()
        }
    }
    
    
    @objc private func signOut() {
        print("DEBUG: Signing out...")
        do {
            try Auth.auth().signOut()
            showLoginPage{
                self.testButton.removeFromSuperview()
                self.mapView.removeFromSuperview()
            }
        } catch {
            print("DEBUG: Error signing out, error \(error)")
        }
    }
    
    
    
    
    
    private func showLoginPage(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let nav = UINavigationController(rootViewController: LoginController())
            if #available(iOS 13.0, *) {
                nav.isModalInPresentation = true
            }
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: completion)
        }
    }
    
    
    
    //MARK: - Helper functions
    
    func configureUI() {
        print("DEBUG: Configuring Home UI")
        configureMapView()
    
        testButton = UIButton(frame: CGRect(x: 00, y: 50, width: 100, height: 50))
        testButton.setTitle("sign out", for: .normal)
        testButton.setTitleColor(.black, for: .normal)
        testButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        view.addSubview(testButton)
    }
    
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
    }

}


//MARK: - Location Services

extension HomeController: CLLocationManagerDelegate {
    
    func enableLocationServices() {
        switch CLLocationManager.authorizationStatus()
        {
        case .notDetermined:
            print("DEBUG: Not determined LocationManager authorization status")
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("DEBUG: Auth restricted")
        case .denied:
            print("DEBUG: Auth denied")
            //TODO: implement alert saying enable in settings
        case .authorizedAlways:
            print("DEBUG: Auth always")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use")
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
}
