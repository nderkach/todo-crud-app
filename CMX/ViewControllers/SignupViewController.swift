//
//  SignupViewController.swift
//  CMX
//
//  Created by Nikolay Derkach on 11/9/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import UIKit
import KeychainAccess

class SignupViewController: SignupLoginBaseViewContoller {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        nameTextField.becomeFirstResponder()
    }

    // MARK: - IBAction

    @IBAction func generatePassword(_ sender: Any) {
        let generatedPassword = Keychain.generatePassword()
        passwordTextField.text = generatedPassword
        passwordTextField.isSecureTextEntry = false
    }

    @IBOutlet weak var generatePassword: UIButton!
    @IBAction func signupTapped(_ sender: Any) {
        signupButton.isEnabled = false

        if nameTextField.text == "" {
            presentAlert(withMessage:  "Empty name")
            self.signupButton.isEnabled = true
            return
        }

        if !validateEmail(candidate: emailTextField.text!) {
            self.presentAlert(withMessage: "Invalid email")
            self.signupButton.isEnabled = true
            return
        }

        if !validatePassword(candidate: passwordTextField.text!) {
            self.presentAlert(withMessage: "Invalid password (should be at least 8 characters, including 1 uppercase letter, 1 lowercase letter, and 1 number)")
            self.signupButton.isEnabled = true
            return
        }

        CMXAPI.signup(email: emailTextField.text!, password: passwordTextField.text!, name: nameTextField.text!, onSuccess: {
            self.dismiss(animated: true, completion: nil)
        }, onFailure: { message in
            self.presentAlert(withMessage: "Invalid signup credentials (\(message))")
        }).onCompletion({ _ in
            self.signupButton.isEnabled = true
        })
    }

    @IBAction func passwordEdited(_ sender: Any) {
         passwordTextField.isSecureTextEntry = true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension SignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === nameTextField {
            textField.resignFirstResponder()
            emailTextField.becomeFirstResponder()
        }
        if textField === emailTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        }

        return true
    }
}
