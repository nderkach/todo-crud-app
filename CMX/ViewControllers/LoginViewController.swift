//
//  LoginViewController.swift
//  CMX
//
//  Created by Nikolay Derkach on 11/8/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import UIKit

class LoginViewController: SignupLoginBaseViewContoller {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "AlreadyLaunchedBefore") {
            performSegue(withIdentifier: "signupFlow", sender: self)
            defaults.set(true, forKey: "AlreadyLaunchedBefore")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        emailTextField.becomeFirstResponder()
    }

    // MARK: - IBAction
    
    @IBAction func loginTapped(_ sender: Any) {
        loginButton.isEnabled = false

        if !validateEmail(candidate: emailTextField.text!) {
            self.presentAlert(withMessage: "Invalid email")
            self.loginButton.isEnabled = true
            return
        }

        if !validatePassword(candidate: passwordTextField.text!) {
            self.presentAlert(withMessage: "Invalid password (should be at least 8 characters, including 1 uppercase letter, 1 lowercase letter, and 1 number)")
            self.loginButton.isEnabled = true
            return
        }

        CMXAPI.login(email: emailTextField.text!, password: passwordTextField.text!, onSuccess: {
            self.dismiss(animated: true, completion: nil)
        }, onFailure: { message in
             self.presentAlert(withMessage: "Invalid login credentials (\(message))")
        }).onCompletion({ _ in
            self.loginButton.isEnabled = true
        })
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Segues

    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {

    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === emailTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        }

        return true
    }
}
