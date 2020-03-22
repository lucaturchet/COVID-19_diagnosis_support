//
//  UserForm.swift
//  Covid-19DiagnosisSupport
//
//  Created by Luca Gasparetto on 22/03/2020.
//  Copyright © 2020 Luca Gasparetto. All rights reserved.
//

import UIKit

class UserForm: UIView {

    let titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .vertical
        return stackView
    }()
    
    let fieldStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .vertical
        return stackView
    }()
    
    let dateTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)
        label.text = "Date of aquisition:"
        return label
    }()
    
    let dateField: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let dateF = DateFormatter()
        dateF.dateFormat = "dd MMM YYYY"
        label.text = dateF.string(from: Date())
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.createTitles()
        self.createFields()
        
        self.addSubview(self.titleStackView)
        self.titleStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.titleStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.titleStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.titleStackView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        self.addSubview(self.fieldStackView)
        self.fieldStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.fieldStackView.leadingAnchor.constraint(equalTo: self.titleStackView.trailingAnchor, constant: 10).isActive = true
        self.fieldStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.fieldStackView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        self.addSubview(self.dateField)
        self.dateField.anchorViewTopRight(top: self.topAnchor, topC: 0,
                                          trailing: self.trailingAnchor, trailingC: 0,
                                          width: nil, height: nil)
        
        self.addSubview(self.dateTitle)
        self.dateTitle.anchorViewRight(centerY: self.dateField.centerYAnchor,
                                       trailing: self.dateField.leadingAnchor, trailingC: -10,
                                       width: nil, height: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createTitles(){
        var currentLabel = UILabel()
        currentLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)
        currentLabel.text = "Name:"
        self.titleStackView.addArrangedSubview(currentLabel)
        
        currentLabel = UILabel()
        currentLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)
        currentLabel.text = "Last Name:"
        self.titleStackView.addArrangedSubview(currentLabel)
        
        currentLabel = UILabel()
        currentLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)
        currentLabel.text = "Date of Birth:"
        self.titleStackView.addArrangedSubview(currentLabel)
    }
    
    private func createFields(){
        var currentLabel = UILabel()
        currentLabel.text = "Mario"
        self.fieldStackView.addArrangedSubview(currentLabel)
        
        currentLabel = UILabel()
        currentLabel.text = "Rossi"
        self.fieldStackView.addArrangedSubview(currentLabel)
        
        currentLabel = UILabel()
        currentLabel.text = "21 Oct 1962"
        self.fieldStackView.addArrangedSubview(currentLabel)
    }
}
