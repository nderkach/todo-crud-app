//
//  IdeaTableViewCell.swift
//  CMX
//
//  Created by Nikolay Derkach on 11/7/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import UIKit
import QuartzCore

class IdeaTableViewCell: UITableViewCell {

    var delegate: IdeaTableViewCellDelegate?

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var impactValueLabel: UILabel!
    @IBOutlet weak var easeValueLabel: UILabel!
    @IBOutlet weak var confidenceValueLabel: UILabel!
    @IBOutlet weak var avgValueLabel: UILabel!

    @IBOutlet weak var cardView: UIView!
    var idea: Idea? {
        didSet {
            // Configure view`
            if let idea = idea {
                contentLabel.text = idea.content
                impactValueLabel.text = "\(idea.impact)"
                easeValueLabel.text = "\(idea.ease)"
                confidenceValueLabel.text = "\(idea.confidence)"
                avgValueLabel.text = String(format: "%.1f", idea.averageScore)
            }
        }
    }

    @IBAction func editTapped(_ sender: Any) {
        delegate?.cellTapped(cell: self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        cardView.layer.cornerRadius = 5.0

        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        cardView.layer.shadowRadius = 3.0
        cardView.layer.shadowPath = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: 5.0).cgPath
        cardView.layer.shadowColor = Color.shadow.value.cgColor
        cardView.layer.shadowOpacity = 1.0

        // performance optimizations
        cardView.layer.shouldRasterize = true
        cardView.layer.rasterizationScale = UIScreen.main.scale
    }
}

protocol IdeaTableViewCellDelegate {
    func cellTapped(cell: IdeaTableViewCell)
    func cellIndexUpdated(fromIndex: Int, newIndex: Int)
}

// MARK: - EditTaskViewControllerDelegate

extension IdeaTableViewCell: EditTaskViewControllerDelegate {
    func ideaChanged(idea: Idea) {
        IdeaManager.updateIdea(withIdea: idea) { (oldIndex, newIndex) in
            self.idea = idea
            self.delegate?.cellIndexUpdated(fromIndex: oldIndex, newIndex: newIndex)
        }
    }
}

