//
//  MainViewController.swift
//  Covid-19DiagnosisSupport
//
//  Created by Luca Gasparetto on 22/03/2020.
//  Copyright © 2020 Luca Gasparetto. All rights reserved.
//

import UIKit
import Macaw
import PDFKit

class MainViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    
    let viewToRenderAsPDF = PDFTemplateView()
    
    let home = HomeViewController()
    
    let documentInteractionController = UIDocumentInteractionController()
    
    // colors for the SVG fill
    static let red = Color.init(val: 0xBA170D)
    static let brown = Color.init(val: 0xB66726)
    static let yellow = Color.init(val: 0xFFE23B)
    static let gray = Color.init(val: 0x7D7C7C)
    let colors = [Color.white,
                  MainViewController.yellow,
                  MainViewController.brown,
                  MainViewController.red,
                  MainViewController.gray]
    
    // nodes IDs of each SVG path // (the associated color is mocked for demonstration)
    let nodes: [String] = [
        "lung_area_1",
        "lung_area_2",
        "lung_area_3",
        "lung_area_4",
        "lung_area_5",
        "lung_area_6",
        "lung_area_7",
        "lung_area_8",
        "lung_area_9",
        "lung_area_10",
        "lung_area_11",
        "lung_area_12",
        "lung_area_13",
        "lung_area_14"
    ]
    
    let pdfTemplate = "report_template"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.documentInteractionController.delegate = self
        
        self.home.colors = self.colors
        self.home.nodes = self.nodes
        self.home.onOpenPDF = {patient, areas, notes in
            self.viewToRenderAsPDF.setData(patient: patient, decidedAreas: areas, notes: notes)
            self.renderPDF()
        }
        self.home.onColorDecided = {nodeTag, color in
            self.viewToRenderAsPDF.lungsSVGView.changeNodeColor(nodeTag: nodeTag, nodeColor: color)
        }
        
        // creating the view to render on the pdf with paper sheet proportions
        self.view.addSubview(self.viewToRenderAsPDF)
        self.viewToRenderAsPDF.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        // using the width as device is in potrait (not landscape) position
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        self.viewToRenderAsPDF.widthAnchor.constraint(
            equalToConstant: screenWidth < screenHeight ? screenWidth : screenHeight
        ).isActive = true
        self.viewToRenderAsPDF.heightAnchor.constraint(equalTo: self.viewToRenderAsPDF.widthAnchor,
                                                       multiplier: 1.5).isActive = true
        
        // now add the actual HomePage UI
        self.addChild(self.home)
        self.view.addSubview(self.home.view)
        self.home.view.anchorViewTo(superView: self.view)
        self.home.didMove(toParent: self)
    }

    // MARK: Actions
    @objc func renderPDF(){
        // create pdf
        let filePath = self.viewToRenderAsPDF.exportAsPdfFromView()
        
        // view pdf
        let url = URL(fileURLWithPath: filePath)
        self.documentInteractionController.url = url
        self.documentInteractionController.name = "Preview"//url.localizedName ?? url.lastPathComponent
        self.documentInteractionController.presentPreview(animated: true)
    }
    
    // MARK: document interaction controller delegate
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let navVC = self.navigationController else {
            return self
        }
        return navVC
    }
}

// MARK: SVG Utils
extension SVGView {
    func changeNodeColor(nodeTag : String, nodeColor: Color) {
        let nodeShape = self.node.nodeBy(tag: nodeTag) as! Shape
        nodeShape.fill = nodeColor
    }
}
