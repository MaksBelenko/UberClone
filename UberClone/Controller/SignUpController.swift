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
        
    let authViewsHelper = AuthViewsHelper()
   
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .backgroundColour
        configureUI()
    }
    
    
    //MARK: - Configurations methods for UI
       
    
    private func configureUI() {
        /* Create top title "UBER" */
        let titleLabel = authViewsHelper.titleLabel
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(inView: view)
        
        /* Create stack for textfields containers */
        let signupButton = authViewsHelper.createActionButton(title: "Sign Up", target: self, action: #selector(signupButtonPressed))
        let stack = UIStackView(arrangedSubviews: [authViewsHelper.emailContainerView,
                                                   authViewsHelper.fullnameContainerView,
                                                   authViewsHelper.passwordContainerView,
                                                   authViewsHelper.accountTypeContainerView,
                                                   signupButton])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 16


        view.addSubview(stack)
        stack.anchor(top: titleLabel.bottomAnchor, paddingTop: 40,
                     left: view.leftAnchor, paddingLeft: 16,
                     right: view.rightAnchor, paddingRight: 16)
        
        
        /* Add bottom button */
        let haveAccountButton = authViewsHelper.createBottomButton(question: "Already have an account?", actionName: "Login",
                                                                   target: self, action: #selector(showLoginPage))
        view.addSubview(haveAccountButton)
        haveAccountButton.centerX(inView: view)
        haveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
    }
    
    
    
    
    //MARK: - Selectors
    
    
    @objc private func signupButtonPressed() {
        guard let email = authViewsHelper.emailTextField.text else { return }
        guard let password = authViewsHelper.passwordTextField.text else { return }
        guard let fullname = authViewsHelper.fullnameTextField.text else { return }
        let accountTypeIndex = authViewsHelper.accountTypeSegmentedControl.selectedSegmentIndex
        
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
}
