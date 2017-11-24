//
//  IdeaListViewController.swift
//  CMX
//
//  Created by Nikolay Derkach on 11/7/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import UIKit
import Siesta

class IdeaListViewController: UIViewController {

    let cellIdentifier = "IdeaTableViewCell"

    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.ideasChanged), name: Notification.Name("ideasChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.ideasReloaded), name: Notification.Name("ideasReloaded"), object: nil)

        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 7.5, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)

        // MARK: - Observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.presentLogin), name: Notification.Name("Logout"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshIdeas), name: Notification.Name("LoggedIn"), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !CMXAPI.isAuthenticated() {
            if CMXAPI.hasCredentials() {
                CMXAPI.refreshAuth()
            } else {
                presentLogin(self)
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editTaskVc = segue.destination as? EditTaskViewController {
            let cell = sender as? IdeaTableViewCell
            if sender == nil {
                editTaskVc.idea = Idea()
                editTaskVc.delegate = self
            } else {
                editTaskVc.idea = cell?.idea
                editTaskVc.delegate = cell
            }
        }
    }

    // MARK: - Selectors

    @IBAction func addButtonTouched(_ sender: Any) {
        performSegue(withIdentifier: "editIdeaSegue", sender: nil)
    }

    @IBAction func logoutTapped(_ sender: Any) {
        logoutButton.isEnabled = false
        CMXAPI.logout().onCompletion { _ in
            self.logoutButton.isEnabled = true
        }
    }

    @objc private func ideasChanged(_ sender: Any) {
        if IdeaManager.total > 0 {
            tableView.backgroundView = nil
        } else {
            tableView.backgroundView = NoIdeasView()
        }
    }

    @objc private func ideasReloaded(_ sender: Any) {
        tableView.reloadData()
    }

    @objc private func refreshIdeas(_ sender: Any) {
        IdeaManager.fetchIdeas()
    }

    @objc private func presentLogin(_ sender: Any) {
        let auth = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()!
        self.present(auth, animated: false, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension IdeaListViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return IdeaManager.total
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! IdeaTableViewCell
        cell.idea = IdeaManager.idea(atIndex: indexPath.row)
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate

extension IdeaListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! IdeaTableViewCell
        performSegue(withIdentifier: "editIdeaSegue", sender: cell)
    }
}

// MARK: - IdeaTableViewCellDelegate

extension IdeaListViewController: IdeaTableViewCellDelegate {

    func cellIndexUpdated(fromIndex: Int, newIndex: Int) {
        if fromIndex != newIndex {
            tableView.moveRow(at: IndexPath(row: fromIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
        }
    }

    func cellTapped(cell: IdeaTableViewCell) {

        let alertController = UIAlertController(title: "Actions", message: nil, preferredStyle: .actionSheet)

        let editButton = UIAlertAction(title: "Edit", style: .default) { (action) in
            self.performSegue(withIdentifier: "editIdeaSegue", sender: cell)
        }

        let deleteButton = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            let alert = UIAlertController(title: "Are you sure?", message: "\n\nThe idea will be permanently deleted.\n\n\n", preferredStyle: .alert)
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
            let okButton = UIAlertAction(title: "OK", style: .default) { (action) in
                let indexPath = self.tableView.indexPath(for: cell)!
                IdeaManager.removeIdea(atIndex: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            alert.addAction(cancelButton)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }

        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }

        alertController.addAction(editButton)
        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)

        navigationController?.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - EditTaskViewControllerDelegate

extension IdeaListViewController: EditTaskViewControllerDelegate {
    func ideaChanged(idea: Idea) {
        IdeaManager.addIdea(idea, onFailure: { message in
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }, onSuccess: { index in
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        })
    }
}

