//
//  LoginController.swift
//  UberClone
//
//  Created by Maksim on 17/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {

    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        return label
    }()
    
    
    private lazy var emailContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(systemName: "envelope") ?? #imageLiteral(resourceName: "ic_mail_outline_white_2x") , textField: emailTextField)
        view.anchor(height: 50)
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(systemName: "lock") ?? #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
        view.anchor(height: 50)
        return view
    }()
    
    
    private let emailTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    }()
    
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
    }()
    
    private let loginButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    private let noAccountButton: UIButton = {
        let button = AccountButton(type: .system)
        button.setupLabel(question: "Don't have an account?", actionName: "Sign Up")
        button.addTarget(self, action: #selector(showSignUpPage), for: .touchUpInside)
        return button
    }()
      
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureNavigationBar()
        configureUI()
    }
    
    
    //MARK: - Selectors
    
    @objc private func loginButtonPressed() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("DEBUG: Failed login user, error: \(error.localizedDescription)")
                return
            }
            
            print("DEBUG: Succesful login!")
            let rootController = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController
            guard let controller = rootController as? HomeController else {return}
            controller.configureUI()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @objc func showSignUpPage() {
        let signupVC = SignUpController()
        navigationController?.pushViewController(signupVC, animated: true)
    }

    
    //MARK: - Configurations methods for UI
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    
    
    private func configureUI() {
        view.backgroundColor = .backgroundColour
        
        /* Create top title "UBER" */
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(inView: view)
        
        /* Create stack for textfields containers */
        let stack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, loginButton])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.anchor(top: titleLabel.bottomAnchor, paddingTop: 40,
                     left: view.leftAnchor, paddingLeft: 16,
                     right: view.rightAnchor, paddingRight: 16)
        
        
        /* Add bottom button */
        view.addSubview(noAccountButton)
        noAccountButton.centerX(inView: view)
        noAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
    }

}
