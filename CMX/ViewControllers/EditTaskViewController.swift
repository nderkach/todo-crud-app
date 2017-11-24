//
//  AddTaskViewController.swift
//  CMX
//
//  Created by Nikolay Derkach on 11/7/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import UIKit

class EditTaskViewController: UIViewController {

    var delegate: EditTaskViewControllerDelegate?

    var content: String?
    var impact: Int?
    var ease: Int?
    var confidence: Int?
    var averageScore: Double?
    var id: String?

    var idea: Idea? {
        didSet {
            content = idea?.content
            impact = idea?.impact
            ease = idea?.ease
            confidence = idea?.confidence
            averageScore = idea?.averageScore
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - IBAction

    @IBAction func saveTapped(_ sender: Any) {
        guard let content = content, content != "", let id = self.idea?.id, let impact = impact, let ease = ease, let confidence = confidence, let averageScore = averageScore else {
            let alert = UIAlertController(title: "Error", message: "Empty content", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }

        let idea = Idea(id: id, content: content, impact: impact, ease: ease, confidence: confidence, averageScore: averageScore)
        delegate?.ideaChanged(idea: idea)

        self.navigationController?.popViewController(animated: false)
    }

    @IBAction func cancelTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Embedded UITableViewController
        if let embeddedVc = segue.destination as? EmbeddedEditTaskViewController {
            embeddedVc.delegate = self
            embeddedVc.idea = idea
        }
    }
}

extension EditTaskViewController: EmbeddedEditTaskViewControllerrDelegate {
    func contentChanged(value: String) {
        content = value
    }

    func impactChanged(value: Int) {
        impact = value
    }

    func easeChanged(value: Int) {
        ease = value
    }

    func confidenceChanged(value: Int) {
        confidence = value
    }

    func averageScoreChanged(value: Double) {
        averageScore = value
    }
}

protocol EditTaskViewControllerDelegate {
    func ideaChanged(idea: Idea)
}
