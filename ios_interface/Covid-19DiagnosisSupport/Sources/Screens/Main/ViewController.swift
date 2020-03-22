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

class MainViewController: UIViewController, PDFDocumentDelegate {
    
    let viewToRenderAsPDF = PDFTemplateView()
    
    let randomizeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Generate New", for: .normal)
        button.setTitleColor(UIColor.DynamicColors.blackWhite, for: .normal)
        return button
    }()
    
    let shareButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icon-share"), for: .normal)
        button.alpha = 0
        button.imageView?.tintColor = UIColor.DynamicColors.blackWhite
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return button
    }()
    
    // colors for the SVG fill
    static let red = Color.init(val: 0xBA170D)
    static let brown = Color.init(val: 0xB66726)
    static let yellow = Color.init(val: 0xFFE23B)
    static let gray = Color.init(val: 0x7D7C7C)
    let colors = [Color.white,
                  MainViewController.red,
                  MainViewController.yellow,
                  MainViewController.brown,
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
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.systemGray6
        
        // keyboard management
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(adjustForKeyboard(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(adjustForKeyboard(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        self.randomizeButton.addTarget(self, action: #selector(generateNewReport), for: .touchUpInside)
        self.shareButton.addTarget(self, action: #selector(renderPDF), for: .touchUpInside)
        
        self.view.addSubview(self.randomizeButton)
        self.randomizeButton.anchorViewBottomCenter(bottom: self.view.bottomAnchor, bottomC: -40,
                                                    centerX: self.view.centerXAnchor, centerY: nil,
                                                    width: 200, height: 50)
        
        self.view.addSubview(self.shareButton)
        self.shareButton.anchorViewLeft(centerY: self.randomizeButton.centerYAnchor,
                                        leading: self.randomizeButton.trailingAnchor, leadingC: 50,
                                        trailing: nil, trailingC: nil,
                                        width: 50, height: 50)
        
        self.view.addSubview(self.viewToRenderAsPDF)
        self.viewToRenderAsPDF.anchorView(top: self.view.topAnchor, topC: 0,
                                          leading: self.view.leadingAnchor, leadingC: 0,
                                          trailing: self.view.trailingAnchor, trailingC: 0,
                                          bottom: self.randomizeButton.topAnchor, bottomC: 0)
    }

    // MARK: Actions
    @objc func generateNewReport(){
        for node in self.nodes {
            let color = self.colors[Int.random(in: 0..<self.colors.count)]
            //Change node color
            self.changeNodeColor(nodeTag: node, nodeColor: color)
        }
        
        if self.shareButton.alpha == 0 {
            // once first generation is completed show the share button to render PDF
            UIView.animate(withDuration: 0.3) {
                self.shareButton.alpha = 1
            }
        }
    }
    
    @objc func renderPDF(){
        // create pdf
        let filePath = self.viewToRenderAsPDF.exportAsPdfFromView()
        
        // view pdf
        let pdfVC = PDFViewerViewController()
        pdfVC.viewSetup(pdfPath: filePath)
        self.present(pdfVC, animated: true, completion: nil)
    }
    
    // MARK: Keyboard management
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = keyboardScreenEndFrame
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            UIView.animate(withDuration: 0.3) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardViewEndFrame.size.height)
            }
        }else{
            UIView.animate(withDuration: 0.3) {
                self.view.transform = .identity
            }
        }
    }
    
    // MARK: Utils
    func changeNodeColor(nodeTag : String, nodeColor: Color) {
        let nodeShape = self.viewToRenderAsPDF.lungsSVGView.node.nodeBy(tag: nodeTag) as! Shape
        nodeShape.fill = nodeColor
    }
}

extension UIView {
    
    // Export pdf from Save pdf in drectory and return pdf file path
    func exportAsPdfFromView() -> String {
        
        let pdfPageFrame = self.bounds
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageFrame, nil)
        UIGraphicsBeginPDFPageWithInfo(pdfPageFrame, nil)
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return "" }
        self.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        return self.saveViewPdf(data: pdfData)
        
    }
    
    // Save pdf file in document directory
    func saveViewPdf(data: NSMutableData) -> String {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDirectoryPath = paths[0]
        let pdfPath = docDirectoryPath.appendingPathComponent("foo.pdf")
        if data.write(to: pdfPath, atomically: true) {
            return pdfPath.path
        } else {
            return ""
        }
    }
}
