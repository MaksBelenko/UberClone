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

    
    private let mapView = MKMapView()
    private var testButton: UIButton!
    
    
    
    
    
    //MARK: - Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .backgroundColour
        checkIfUserLoggedIn()
    }
    
    
    //MARK: - API
    
    private func checkIfUserLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            print("DEBUG: User NOT logged in")
            showLoginPage {
                self.testButton.removeFromSuperview()
                self.mapView.removeFromSuperview()
            }
        } else {
            print("DEBUG: User id is \(Auth.auth().currentUser?.uid)")
            configureUI()
        }
    }
    
    
    @objc private func signOut() {
        print("DEBUG: Signing out...")
        do {
            try Auth.auth().signOut()
            showLoginPage()
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
        view.addSubview(mapView)
        mapView.frame = view.frame
    
        testButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        testButton.setTitle("sign out", for: .normal)
        testButton.tintColor = .black
        testButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        view.addSubview(testButton)
    }

}
