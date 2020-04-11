//
//  TotalsView.swift
//  Covid-19DiagnosisSupport
//
//  Created by Luca Gasparetto on 04/04/2020.
//  Copyright © 2020 Luca Gasparetto. All rights reserved.
//

import UIKit

class TotalsView: UIView {

    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)
        label.text = "Totals"
        
        return label
    }()
    
    let subLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Pathological areas:"
        return label
    }()

    let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .fillEqually
        view.alignment = .leading
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.DynamicColors.whiteBlack
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.FlatColors.borderGray.cgColor
        
        self.addSubview(self.label)
        self.label.anchorViewTopLeft(top: self.topAnchor, topC: 5,
                                     leading: self.leadingAnchor, leadingC: 5,
                                     width: nil, height: nil)
        
        self.addSubview(self.subLabel)
        self.subLabel.anchorViewTopLeft(top: self.label.bottomAnchor, topC: 7,
                                        leading: self.leadingAnchor, leadingC: 5,
                                        width: nil, height: nil)
        
        self.addSubview(self.stackView)
        self.stackView.anchorView(top: self.subLabel.bottomAnchor, topC: 5,
                                  leading: self.leadingAnchor, leadingC: 5,
                                  trailing: self.trailingAnchor, trailingC: -5,
                                  bottom: self.bottomAnchor, bottomC: -5)
        
        self.totalsSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func totalsSetup(){
        let colors: [UIColor] = [.white,
                                 UIColor.FlatColors.yellow,
                                 UIColor.FlatColors.brown,
                                 UIColor.FlatColors.red,
                                 UIColor.FlatColors.darkGray]
        for i in 0...3 {
            let row = LegendaRowView()
            row.viewSetup(color: colors[i], text: "0")
            row.label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
            self.stackView.addArrangedSubview(row)
        }
    }
    
    func setAreas(decided: [Int]) {
        for (index, view) in self.stackView.arrangedSubviews.enumerated() {
            if let legend = view as? LegendaRowView {
                legend.label.text = "\(decided[index])"
            }
        }
    }

    func blockColors(){
        self.backgroundColor = UIColor.FlatColors.totalsGray
        self.label.textColor = .black
        self.subLabel.textColor = .black
        
        for view in self.stackView.arrangedSubviews {
            (view as! LegendaRowView).blockColors()
        }
    }
    
}