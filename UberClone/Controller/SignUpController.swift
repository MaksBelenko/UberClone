//
//  SignUpController.swift
//  UberClone
//
//  Created by Maksim on 17/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit
import Firebase


class SignUpController: UIViewController {
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        return label
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(systemName: "envelope") ?? #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var fullnameContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(systemName: "person") ?? #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: fullnameTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(systemName: "lock") ?? #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var accountTypeContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(systemName: "person.crop.square.fill") ?? #imageLiteral(resourceName: "ic_person_outline_white_2x"), segmentedControl: accountTypeSegmentedControl)  // 􀉺
        view.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return view
    }()
    
    private let emailTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    }()
    
    private let fullnameTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Full Name", isSecureTextEntry: false)
    }()
    
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
    }()
    
    private let accountTypeSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Rider", "Driver"])
        sc.backgroundColor = .backgroundColour
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.backgroundColour], for: .selected)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    
    private let signupButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(signupButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    private let haveAccountButton: UIButton = {
        let button = AccountButton(type: .system)
        button.setupLabel(question: "Already have an account?", actionName: "Login")
        button.addTarget(self, action: #selector(showLoginPage), for: .touchUpInside)
        return button
    }()
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        
        configureUI()
    }
    
    
    
    //MARK: - Selectors
    
    
    @objc private func signupButtonPressed() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullnameTextField.text else { return }
        let accountTypeIndex = accountTypeSegmentedControl.selectedSegmentIndex
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("DEBUG: Failed register user, error: \(error.localizedDescription)")
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            let values = ["email"       : email,
                          "fullname"    : fullname,
//                          "password"    : password,
                          "accountType" : accountTypeIndex] as [String : Any]
            
            Database.database().reference().child("users").child(uid).updateChildValues(values) { (error, ref) in
                print("DEBUG: Successfully registered and saved!")
                let rootController = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController
                guard let controller = rootController as? HomeController else {return}
                controller.configureUI()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    @objc private func showLoginPage() {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    
    //MARK: - Configurations methods for UI
    
    private func configureUI() {
        view.backgroundColor = .backgroundColour
        
        /* Create top title "UBER" */
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(inView: view)
        
        /* Create stack for textfields containers */
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   fullnameContainerView,
                                                   passwordContainerView,
                                                   accountTypeContainerView,
                                                   signupButton])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 16


        view.addSubview(stack)
        stack.anchor(top: titleLabel.bottomAnchor, paddingTop: 40,
                     left: view.leftAnchor, paddingLeft: 16,
                     right: view.rightAnchor, paddingRight: 16)
        
        
        /* Add bottom button */
        view.addSubview(haveAccountButton)
        haveAccountButton.centerX(inView: view)
        haveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
    }
}
