//
//  SignupLoginBaseViewContoller.swift
//  CMX
//
//  Created by Nikolay Derkach on 11/9/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import UIKit

class SignupLoginBaseViewContoller: UIViewController {

    func presentAlert(withMessage message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // Email & password check

    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }

    func validatePassword(candidate: String) -> Bool {
        let passwordRegex = "(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d-$@$!%*#?&]{8,}"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: candidate)
    }
}


