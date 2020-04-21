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

    private let locationManager = LocationHandler.shared.locationManager
    private let mapView = MKMapView()
    private var testButton: UIButton!
    
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    
    private var user: User? {
        didSet {
            locationInputView.user = user
        }
    }
    
    private final let locationInputViewHeight: CGFloat = 160
    
    
    
    //MARK: - Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        inputActivationView.delegate = self
        locationInputView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
    
        view.backgroundColor = .backgroundColour
        checkIfUserLoggedIn()
        fetchUserData()
        fetchDrivers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        enableLocationServices()
    }
    
    
    //MARK: - API
    
    func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(uid: currentUid) { user in
            self.user = user
        }
    }
    
    
    func fetchDrivers() {
        guard let location  = locationManager?.location else { return }
        
        /* Driver appeared in the Radius */
        Service.shared.listenDriver(for: .driverAppeared, location: location) { (driver) in
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            self.mapView.addAnnotation(annotation)
        }
        
        /* Drivers location changed within the radius */
        Service.shared.listenDriver(for: .driverChangedLocation, location: location) { (driver) in
            guard let coordinate = driver.location?.coordinate else { return }
            
            for annotation in self.mapView.annotations {
                guard let driverAnno = annotation as? DriverAnnotation else { continue }
                if driverAnno.uid == driver.uid {
                    print("DEBUG: Update \(driver.fullname) driver position")
                    driverAnno.updateAnnotationPosition(with: coordinate)
                    return
                }
            }
        }
        
        /* Driver exited the radius */
        Service.shared.listenDriver(for: .driverExited, location: location) { (driver) in
            for annotation in self.mapView.annotations {
                guard let driverAnno = annotation as? DriverAnnotation else { continue }
                if driverAnno.uid == driver.uid {
                    self.mapView.removeAnnotation(driverAnno)
                    return
                }
            }
        }
        
    }
    
    
    
    
    
    //MARK: - LoggedIn & Signout
    private func checkIfUserLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            print("DEBUG: User NOT logged in")
            showLoginPage()
        } else {
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
        setupTestButton()
        
        setupInputActivationView()
        configureTableView()
        configureLocationInputView()
    }
    
    
    private func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        mapView.showsCompass = false
    }
    
    
    
    private func setupInputActivationView() {
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 70,
                                   width: view.frame.width - 64, height: 50)
        inputActivationView.alpha = 0
        
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
    }
    
    
    private func setupTestButton() {
        testButton = UIButton(frame: CGRect(x: 100, y: 30, width: 100, height: 50))
        testButton.setTitle("sign out", for: .normal)
        testButton.setTitleColor(.black, for: .normal)
        testButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        view.addSubview(testButton)
    }
    
    
    
    private func configureLocationInputView() {
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor,
                                 left: view.leftAnchor,
                                 right: view.rightAnchor,
                                 height: locationInputViewHeight)
        
        locationInputView.alpha = 0
    }

    
    private func configureTableView() {
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifierLocationCell)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        
        view.addSubview(tableView)
    }
}





//MARK: - MKMapViewDelegate

extension HomeController: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            
            let image = #imageLiteral(resourceName: "DriverIconSmall")
            let resizedSize = CGSize(width: 50, height: 25)

            UIGraphicsBeginImageContext(resizedSize)
            image.draw(in: CGRect(origin: .zero, size: resizedSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            view.image = resizedImage
            return view
        }
        return nil
    }
}




//MARK: - Location Services

extension HomeController {
    
    func enableLocationServices() {
        switch CLLocationManager.authorizationStatus()
        {
        case .notDetermined:
            print("DEBUG: Not determined LocationManager authorization status")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted:
            print("DEBUG: Auth restricted")
        case .denied:
            print("DEBUG: Auth denied")
            //TODO: implement alert saying enable in settings
        case .authorizedAlways:
            print("DEBUG: Auth always")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use")
            locationManager?.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
}


//MARK: - Location Input Activation View

extension HomeController: LocationInputActivationViewDelegate {
    
    func presentLocationInputView() {
        print("DEBUG: Present input activation view")
        self.inputActivationView.alpha = 0
        
        UIView.animate(withDuration: 0.3){
            self.locationInputView.alpha = 1
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.tableView.frame.origin.y = self.locationInputViewHeight
        }, completion: nil)
    }
}


//MARK: - Location Input View

extension HomeController: LocationInputViewDelegate {
    
    func dismissLocationInputView() {
        print("DEBUG: Dismiss location input view")
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
            }
        }
    }
}


//MARK: - TableView

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "test"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 2 : 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierLocationCell, for: indexPath) as! LocationCell
        return cell
    }
    
    
}

