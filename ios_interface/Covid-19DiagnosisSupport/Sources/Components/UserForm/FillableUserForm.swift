//
//  FillableUserForm.swift
//  Covid-19DiagnosisSupport
//
//  Created by Luca Gasparetto on 04/04/2020.
//  Copyright © 2020 Luca Gasparetto. All rights reserved.
//

import UIKit

class FillableUserForm: UIView {

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
        
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.DynamicColors.whiteBlack
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.FlatColors.borderGray.cgColor
        
        self.addSubview(self.nameTitleLabel)
        self.nameTitleLabel.anchorViewTop(top: self.topAnchor, topC: 10,
                                          leading: self.leadingAnchor, leadingC: 5,
                                          trailing: self.trailingAnchor, trailingC: -5,
                                          height: nil)
        
        self.addSubview(self.nameTextField)
        self.nameTextField.anchorViewTop(top: self.nameTitleLabel.bottomAnchor, topC: 0,
                                         leading: self.leadingAnchor, leadingC: 5,
                                         trailing: self.trailingAnchor, trailingC: -5,
                                         height: 30)
        
        self.addSubview(self.surnameTitleLabel)
        self.surnameTitleLabel.anchorViewTop(top: self.nameTextField.bottomAnchor, topC: 10,
                                          leading: self.leadingAnchor, leadingC: 5,
                                          trailing: self.trailingAnchor, trailingC: -5,
                                          height: nil)
        
        self.addSubview(self.surnameTextField)
        self.surnameTextField.anchorViewTop(top: self.surnameTitleLabel.bottomAnchor, topC: 0,
                                         leading: self.leadingAnchor, leadingC: 5,
                                         trailing: self.trailingAnchor, trailingC: -5,
                                         height: 30)
        
        self.addSubview(self.dateOfBirthTitleLabel)
        self.dateOfBirthTitleLabel.anchorViewTop(top: self.surnameTextField.bottomAnchor, topC: 10,
                                                 leading: self.leadingAnchor, leadingC: 5,
                                                 trailing: self.trailingAnchor, trailingC: -5,
                                                 height: nil)
        
        self.addSubview(self.dateOfBirthIcon)
        self.dateOfBirthIcon.anchorViewTopLeft(top: self.dateOfBirthTitleLabel.bottomAnchor, topC: 0,
                                               leading: self.leadingAnchor, leadingC: 5,
                                               width: 30, height: 30)
        
        self.addSubview(self.dateOfBirthTextField)
        self.dateOfBirthTextField.anchorViewLeft(centerY: self.dateOfBirthIcon.centerYAnchor,
                                                 leading: self.dateOfBirthIcon.trailingAnchor, leadingC: 5,
                                                 trailing: self.trailingAnchor, trailingC: -5,
                                                 width: nil, height: 30)
        
        self.addSubview(self.dateOfAcquisitionTitleLabel)
        self.dateOfAcquisitionTitleLabel.anchorViewTop(top: self.dateOfBirthTextField.bottomAnchor, topC: 10,
                                                 leading: self.leadingAnchor, leadingC: 5,
                                                 trailing: self.trailingAnchor, trailingC: -5,
                                                 height: nil)
        
        self.addSubview(self.dateOfAcquisitionIcon)
        self.dateOfAcquisitionIcon.anchorViewTopLeft(top: self.dateOfAcquisitionTitleLabel.bottomAnchor, topC: 0,
                                               leading: self.leadingAnchor, leadingC: 5,
                                               width: 30, height: 30)
        
        self.addSubview(self.dateOfAcquisitionTextField)
        self.dateOfAcquisitionTextField.anchorViewLeft(centerY: self.dateOfAcquisitionIcon.centerYAnchor,
                                                 leading: self.dateOfAcquisitionIcon.trailingAnchor, leadingC: 5,
                                                 trailing: self.trailingAnchor, trailingC: -5,
                                                 width: nil, height: 30)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
