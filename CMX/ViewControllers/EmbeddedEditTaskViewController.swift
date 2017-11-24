//
//  EmbeddedEditTaskViewController.swift
//  CMX
//
//  Created by Nikolay Derkach on 11/7/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import UIKit

class EmbeddedEditTaskViewController: UITableViewController {

    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var avgValueLabel: UILabel!

    var selectedTextField: UITextField?
    @IBOutlet weak var impactField: UITextField!
    @IBOutlet weak var easeField: UITextField!
    @IBOutlet weak var confidenceField: UITextField!

    var idea: Idea?

    let pickerValues = (1...10).map { $0 }

    var delegate: EmbeddedEditTaskViewControllerrDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        configurePickers()

        let dismissKeyboardOnTap = UITapGestureRecognizer(target: self, action: #selector(self.dissmissKeyboard))
        dismissKeyboardOnTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboardOnTap)

        if let idea = idea {
            contentTextField.text = idea.content
            impactField.text = "\(idea.impact)"
            easeField.text = "\(idea.ease)"
            confidenceField.text = "\(idea.confidence)"
            avgValueLabel.text = String(format: "%.1f", idea.averageScore)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        contentTextField.becomeFirstResponder()
    }

    private func configurePickers() {
        let impactPicker = UIPickerView()
        impactPicker.delegate = self
        impactPicker.dataSource = self
        impactPicker.selectRow((idea?.impact)!-1, inComponent: 0, animated: false)
        impactField.inputView = impactPicker

        let easePicker = UIPickerView()
        easePicker.delegate = self
        easePicker.dataSource = self
        easePicker.selectRow((idea?.ease)!-1, inComponent: 0, animated: false)
        easeField.inputView = easePicker

        let confidencePicker = UIPickerView()
        confidencePicker.delegate = self
        confidencePicker.dataSource = self
        confidencePicker.selectRow((idea?.confidence)!-1, inComponent: 0, animated: false)
        confidenceField.inputView = confidencePicker
    }

    // MARK: - Selectors

    @objc private func dissmissKeyboard() {
        contentTextField.resignFirstResponder()
        impactField.resignFirstResponder()
        easeField.resignFirstResponder()
        confidenceField.resignFirstResponder()
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.row {
        case 1:
            selectedTextField = impactField
            impactField.becomeFirstResponder()
        case 2:
            selectedTextField = easeField
            easeField.becomeFirstResponder()
        case 3:
            selectedTextField = confidenceField
            confidenceField.becomeFirstResponder()
        default:
            selectedTextField = nil
        }
    }
}

protocol EmbeddedEditTaskViewControllerrDelegate {
    func contentChanged(value: String)
    func impactChanged(value: Int)
    func easeChanged(value: Int)
    func confidenceChanged(value: Int)
    func averageScoreChanged(value: Double)
}

// MARK: - UIPickerViewDelegate

extension EmbeddedEditTaskViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerValues[row])"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTextField?.text = "\(pickerValues[row])"
    }
}

// MARK: - UIPickerViewDataSource

extension EmbeddedEditTaskViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerValues.count
    }
}

// MARK: - UITextFieldDelegate

extension EmbeddedEditTaskViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.contentTextField {
            // 255 characters max
            let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
            return result.count < 255
        } else {
            return true
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.contentTextField {
            delegate?.contentChanged(value: textField.text!)
        } else {
            let intTextValue = Int((textField.text)!)!
            let avgValue: Double = (Double((impactField.text)!)! + Double((easeField.text)!)! + Double((confidenceField.text)!)!) / 3
            avgValueLabel.text = String(format: "%.1f", avgValue)
            delegate?.averageScoreChanged(value: avgValue)

            if textField == self.impactField {
                delegate?.impactChanged(value: intTextValue)
            } else if textField == self.easeField {
                delegate?.easeChanged(value: intTextValue)
            } else if textField == self.confidenceField {
                delegate?.confidenceChanged(value: intTextValue)
            }
        }
    }
}
