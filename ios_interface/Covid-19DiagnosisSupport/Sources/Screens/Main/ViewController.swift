//
//  MainViewController.swift
//  Covid-19DiagnosisSupport
//
//  Created by Luca Gasparetto on 22/03/2020.
//  Copyright © 2020 Luca Gasparetto. All rights reserved.
//

import UIKit
import Macaw

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
    
    let nodes: [(String, Color)] = [
        ("lung_area_1", Color.red),
        ("lung_area_2", Color.white),
        ("lung_area_3", Color.yellow),
        ("lung_area_4", Color.olive),
        ("lung_area_5", Color.red),
        ("lung_area_6", Color.red),
        ("lung_area_7", Color.red),
        ("lung_area_8", Color.yellow),
        ("lung_area_9", Color.red),
        ("lung_area_10", Color.white),
        ("lung_area_11", Color.red),
        ("lung_area_12", Color.white),
        ("lung_area_13", Color.red),
        ("lung_area_14", Color.white)
    ]
    
    let lungsSVGView: SVGView = {
        let view = SVGView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemGray6
        view.fileName = "lungs_areas"
        
        return view
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
        
        self.view.addSubview(self.lungsSVGView)
        self.lungsSVGView.anchorView(top: self.titleLabel.bottomAnchor, topC: 40,
                                     leading: self.view.leadingAnchor, leadingC: 40,
                                     trailing: self.view.trailingAnchor, trailingC: -40,
                                     bottom: self.view.bottomAnchor, bottomC: -40)
        
        for nodeValues in self.nodes {
            self.lungsSVGView.node.nodeBy(tag: nodeValues.0)?.onTouchPressed({ (touch) in
                //Add an action to execute when specific node was touched
                //Change node color
                self.changeNodeColor(nodeTag: nodeValues.0, nodeColor: nodeValues.1)
            })
        }
    }

    func changeNodeColor(nodeTag : String, nodeColor: Color) {
        let nodeShape = self.lungsSVGView.node.nodeBy(tag: nodeTag) as! Shape
        nodeShape.fill = nodeColor
    }
}

