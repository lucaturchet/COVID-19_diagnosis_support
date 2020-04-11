//
//  FillableUserForm.swift
//  Covid-19DiagnosisSupport
//
//  Created by Luca Gasparetto on 04/04/2020.
//  Copyright © 2020 Luca Gasparetto. All rights reserved.
//

import UIKit

class FillableUserForm: UIViewController, UITextFieldDelegate {

    let nameTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Name"
        return label
    }()
    
    let nameTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.FlatColors.borderGray.cgColor
        return view
    }()
    
    let surnameTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Last name"
        return label
    }()
    
    let surnameTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.FlatColors.borderGray.cgColor
        
        return view
    }()
    
    let dateOfBirthIcon: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icon-calendar"), for: .normal)
        
        return button
    }()
    
    let dateOfBirthTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Date of birth"
        return label
    }()
    
    let dateOfBirthTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.FlatColors.borderGray.cgColor
        view.placeholder = "dd/mm/aaaa"
        view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 50))
        view.leftViewMode = .always
        return view
    }()
    
    let dateOfAcquisitionIcon: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icon-calendar"), for: .normal)
        
        return button
    }()
    
    let dateOfAcquisitionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Date of acquisition"
        return label
    }()
    
    let dateOfAcquisitionTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.FlatColors.borderGray.cgColor
        view.placeholder = "dd/mm/aaaa"
        view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 50))
        view.leftViewMode = .always
        return view
    }()
    
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.backgroundColor = UIColor.DynamicColors.whiteBlack
        self.view.layer.borderWidth = 1
        self.view.layer.borderColor = UIColor.FlatColors.borderGray.cgColor
        
        // set date picker
        self.datePicker.translatesAutoresizingMaskIntoConstraints = false
        self.datePicker.datePickerMode = .date
        
        let endBtn = UIBarButtonItem(title: "Fine",
                                     style: .done,
                                     target: self,
                                     action: #selector(dismissKeyboard))
        
        let endEditingBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 40))
        let emptySpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        endEditingBar.items = [emptySpace, endBtn]
        
        self.dateOfBirthTextField.inputAccessoryView = endEditingBar
        self.dateOfBirthTextField.inputView = self.datePicker
        self.dateOfBirthTextField.delegate = self
        
        self.dateOfAcquisitionTextField.inputAccessoryView = endEditingBar
        self.dateOfAcquisitionTextField.inputView = self.datePicker
        self.dateOfAcquisitionTextField.delegate = self
                    
        self.view.addSubview(self.nameTitleLabel)
        self.nameTitleLabel.anchorViewTop(top: self.view.topAnchor, topC: 10,
                                          leading: self.view.leadingAnchor, leadingC: 5,
                                          trailing: self.view.trailingAnchor, trailingC: -5,
                                          height: nil)
        
        self.view.addSubview(self.nameTextField)
        self.nameTextField.anchorViewTop(top: self.nameTitleLabel.bottomAnchor, topC: 0,
                                         leading: self.view.leadingAnchor, leadingC: 5,
                                         trailing: self.view.trailingAnchor, trailingC: -5,
                                         height: 30)
        
        self.view.addSubview(self.surnameTitleLabel)
        self.surnameTitleLabel.anchorViewTop(top: self.nameTextField.bottomAnchor, topC: 10,
                                          leading: self.view.leadingAnchor, leadingC: 5,
                                          trailing: self.view.trailingAnchor, trailingC: -5,
                                          height: nil)
        
        self.view.addSubview(self.surnameTextField)
        self.surnameTextField.anchorViewTop(top: self.surnameTitleLabel.bottomAnchor, topC: 0,
                                         leading: self.view.leadingAnchor, leadingC: 5,
                                         trailing: self.view.trailingAnchor, trailingC: -5,
                                         height: 30)
        
        self.view.addSubview(self.dateOfBirthTitleLabel)
        self.dateOfBirthTitleLabel.anchorViewTop(top: self.surnameTextField.bottomAnchor, topC: 10,
                                                 leading: self.view.leadingAnchor, leadingC: 5,
                                                 trailing: self.view.trailingAnchor, trailingC: -5,
                                                 height: nil)
        
        self.view.addSubview(self.dateOfBirthIcon)
        self.dateOfBirthIcon.anchorViewTopLeft(top: self.dateOfBirthTitleLabel.bottomAnchor, topC: 0,
                                               leading: self.view.leadingAnchor, leadingC: 5,
                                               width: 30, height: 30)
        
        self.view.addSubview(self.dateOfBirthTextField)
        self.dateOfBirthTextField.anchorViewLeft(centerY: self.dateOfBirthIcon.centerYAnchor,
                                                 leading: self.dateOfBirthIcon.trailingAnchor, leadingC: 5,
                                                 trailing: self.view.trailingAnchor, trailingC: -5,
                                                 width: nil, height: 30)
        
        self.view.addSubview(self.dateOfAcquisitionTitleLabel)
        self.dateOfAcquisitionTitleLabel.anchorViewTop(top: self.dateOfBirthTextField.bottomAnchor, topC: 10,
                                                 leading: self.view.leadingAnchor, leadingC: 5,
                                                 trailing: self.view.trailingAnchor, trailingC: -5,
                                                 height: nil)
        
        self.view.addSubview(self.dateOfAcquisitionIcon)
        self.dateOfAcquisitionIcon.anchorViewTopLeft(top: self.dateOfAcquisitionTitleLabel.bottomAnchor, topC: 0,
                                               leading: self.view.leadingAnchor, leadingC: 5,
                                               width: 30, height: 30)
        
        self.view.addSubview(self.dateOfAcquisitionTextField)
        self.dateOfAcquisitionTextField.anchorViewLeft(centerY: self.dateOfAcquisitionIcon.centerYAnchor,
                                                 leading: self.dateOfAcquisitionIcon.trailingAnchor, leadingC: 5,
                                                 trailing: self.view.trailingAnchor, trailingC: -5,
                                                 width: nil, height: 30)
    }
    
    func getPatient() -> PatientReport {
        let name = self.nameTextField.text ?? ""
        let lastName = self.surnameTextField.text ?? ""
        let dateB = self.dateOfBirthTextField.text ?? ""
        let dateA = self.dateOfAcquisitionTextField.text ?? ""
        return PatientReport(name: name, lastName: lastName, dateOfBirth: dateB, dateOfAcquisition: dateA)
    }
    
    // MARK: Actions
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    var activeTextField: UITextField?
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        self.activeTextField?.text = formatter.string(from: self.datePicker.date)
        return true
    }
}
