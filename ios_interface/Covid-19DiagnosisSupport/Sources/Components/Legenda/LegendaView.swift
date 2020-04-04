//
//  LegendaView.swift
//  Covid-19DiagnosisSupport
//
//  Created by Luca Gasparetto on 04/04/2020.
//  Copyright © 2020 Luca Gasparetto. All rights reserved.
//

import UIKit

class LegendaView: UIView {
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)
        label.text = "Legenda"
        
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
        self.backgroundColor = UIColor.systemGray4
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.FlatColors.borderGray.cgColor
        
        self.addSubview(self.label)
        self.label.anchorViewTopLeft(top: self.topAnchor, topC: 5,
                                     leading: self.leadingAnchor, leadingC: 5,
                                     width: nil, height: nil)
        self.addSubview(self.stackView)
        self.stackView.anchorView(top: self.label.bottomAnchor, topC: 5,
                                  leading: self.leadingAnchor, leadingC: 5,
                                  trailing: self.trailingAnchor, trailingC: -5,
                                  bottom: self.bottomAnchor, bottomC: -5)
        
        self.legendaSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func legendaSetup(){
        let colors: [UIColor] = [.white,
                                 UIColor.FlatColors.yellow,
                                 UIColor.FlatColors.brown,
                                 UIColor.FlatColors.red,
                                 UIColor.FlatColors.darkGray]
        for i in 0...3 {
            let row = LegendaRowView()
            row.viewSetup(color: colors[i], text: "Score \(i)")
            self.stackView.addArrangedSubview(row)
        }
        
        let last = LegendaRowView()
        last.viewSetup(color: colors.last!, text: "Not measured")
        self.stackView.addArrangedSubview(last)
    }
    
    func blockColors(){
        self.backgroundColor = .white
        self.label.textColor = .black
        
        for view in self.stackView.arrangedSubviews {
            (view as! LegendaRowView).blockColors()
        }
    }
}

class LegendaRowView: UIView {
    
    let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.FlatColors.borderGray.cgColor
        
        return view
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.colorView)
        self.colorView.anchorViewLeft(centerY: self.centerYAnchor,
                                      leading: self.leadingAnchor, leadingC: 0,
                                      trailing: nil, trailingC: nil,
                                      width: 40, height: 20)
        
        self.addSubview(self.label)
        self.label.anchorViewLeft(centerY: self.colorView.centerYAnchor,
                                  leading: self.colorView.trailingAnchor, leadingC: 5,
                                  trailing: self.trailingAnchor, trailingC: 0,
                                  width: nil, height: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewSetup(color: UIColor, text: String) {
        self.colorView.backgroundColor = color
        self.label.text = text
    }
    
    func blockColors(){
        self.label.textColor = .black
    }
}
