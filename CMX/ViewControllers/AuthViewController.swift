//
//  AuthViewController.swift
//  CMX
//
//  Created by Nikolay Derkach on 11/8/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import UIKit

class AuthViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: - Observers

        NotificationCenter.default.addObserver(self, selector: #selector(self.dismissScreen), name: Notification.Name("LoggedIn"), object: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Selectors

    @objc private func dismissScreen(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
