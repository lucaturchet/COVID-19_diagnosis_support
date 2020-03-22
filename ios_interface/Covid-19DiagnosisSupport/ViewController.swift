//
//  MainViewController.swift
//  Covid-19DiagnosisSupport
//
//  Created by Luca Gasparetto on 22/03/2020.
//  Copyright © 2020 Luca Gasparetto. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.DynamicColors.blackWhite
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24)
        label.text = "COVID-19 Diagnosis Support"
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.systemGray6
        
        
        self.view.addSubview(self.titleLabel)
        self.titleLabel.anchorViewTop(top: self.view.topAnchor, topC: 40,
                                      leading: self.view.leadingAnchor, leadingC: 40,
                                      trailing: self.view.trailingAnchor, trailingC: -40,
                                      height: nil)
    }

}

