//
//  PDFTemplateView.swift
//  Covid-19DiagnosisSupport
//
//  Created by Luca Gasparetto on 22/03/2020.
//  Copyright © 2020 Luca Gasparetto. All rights reserved.
//

import UIKit
import Macaw

class PDFTemplateView: UIView {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.DynamicColors.blackWhite
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.semibold)
        label.text = "COVID-19 Diagnosis Support"
        
        return label
    }()
    
    let userForm = UserForm()

    let lungsSVGView: SVGView = {
        let view = SVGView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemGray6
        view.fileName = "lungs_areas"
        
        return view
    }()
    
    let notesTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)
        label.text = "Notes of the clinician"
        return label
    }()
    
    let notesTextView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.DynamicColors.blackWhite.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.titleLabel)
        self.titleLabel.anchorViewTop(top: self.topAnchor, topC: 40,
                                      leading: self.leadingAnchor, leadingC: 40,
                                      trailing: self.trailingAnchor, trailingC: -40,
                                      height: nil)
        
        self.addSubview(self.userForm)
        self.userForm.anchorViewTop(top: self.titleLabel.bottomAnchor, topC: 40,
                                    leading: self.leadingAnchor, leadingC: 40,
                                    trailing: self.trailingAnchor, trailingC: -40,
                                    height: 120)
        
        self.addSubview(self.notesTextView)
        self.notesTextView.anchorViewBottom(bottom: self.bottomAnchor, bottomC: -40,
                                            leading: self.leadingAnchor, leadingC: 40,
                                            trailing: self.trailingAnchor, trailingC: -40,
                                            height: 120)
        
        self.addSubview(self.notesTitle)
        self.notesTitle.anchorViewBottom(bottom: self.notesTextView.topAnchor, bottomC: -20,
                                         leading: self.leadingAnchor, leadingC: 40,
                                         trailing: self.trailingAnchor, trailingC: -40,
                                         height: nil)
        
        self.addSubview(self.lungsSVGView)
        self.lungsSVGView.anchorView(top: self.userForm.bottomAnchor, topC: 40,
                                     leading: self.leadingAnchor, leadingC: 40,
                                     trailing: self.trailingAnchor, trailingC: -40,
                                     bottom: self.notesTitle.topAnchor, bottomC: -40)
        self.lungsSVGView.heightAnchor.constraint(equalToConstant: 400).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
