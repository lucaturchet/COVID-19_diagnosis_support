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
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.DynamicColors.blackWhite
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24)
        label.text = "COVID-19 Diagnosis Support"
        
        return label
    }()
    
    let lungsSVGView: SVGView = {
        let view = SVGView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemGray6
        view.fileName = "lungs_areas"
        
        return view
    }()
    
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
        
        self.randomizeButton.addTarget(self, action: #selector(generateNewReport), for: .touchUpInside)
        self.shareButton.addTarget(self, action: #selector(renderPDF), for: .touchUpInside)
        
        self.view.addSubview(self.titleLabel)
        self.titleLabel.anchorViewTop(top: self.view.topAnchor, topC: 40,
                                      leading: self.view.leadingAnchor, leadingC: 40,
                                      trailing: self.view.trailingAnchor, trailingC: -40,
                                      height: nil)
        
        self.view.addSubview(self.randomizeButton)
        self.randomizeButton.anchorViewBottomCenter(bottom: self.view.bottomAnchor, bottomC: -40,
                                                    centerX: self.view.centerXAnchor, centerY: nil,
                                                    width: 200, height: 50)
        
        self.view.addSubview(self.shareButton)
        self.shareButton.anchorViewLeft(centerY: self.randomizeButton.centerYAnchor,
                                        leading: self.randomizeButton.trailingAnchor, leadingC: 50,
                                        trailing: nil, trailingC: nil,
                                        width: 50, height: 50)
        
        self.view.addSubview(self.lungsSVGView)
        self.lungsSVGView.anchorView(top: self.titleLabel.bottomAnchor, topC: 40,
                                     leading: self.view.leadingAnchor, leadingC: 40,
                                     trailing: self.view.trailingAnchor, trailingC: -40,
                                     bottom: self.randomizeButton.topAnchor, bottomC: -40)
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
        let filePath = self.createPDF()
        
        // view pdf
        let pdfVC = PDFViewController()
        pdfVC.viewSetup(pdfPath: filePath)
        self.present(pdfVC, animated: true, completion: nil)
    }
    
    // MARK: Utils
    func changeNodeColor(nodeTag : String, nodeColor: Color) {
        let nodeShape = self.lungsSVGView.node.nodeBy(tag: nodeTag) as! Shape
        nodeShape.fill = nodeColor
    }
    
//    func createPDF() -> String? {
//        guard let filePath = Bundle.main.path(forResource: self.pdfTemplate, ofType: "pdf") else { return nil }
//
//        let pdf = PDFDocument(url: URL(fileURLWithPath: filePath))
//        guard let contents = pdf?.string else {
//            print("could not get string from pdf: \(String(describing: pdf))")
//            exit(1)
//        }
//
//        let footNote = contents.components(separatedBy: "Name: ")[1] // get all the text after the first foot note
//
//        print(footNote.components(separatedBy: "\n")[0])
//
//        return ""
//    }
    
    func createPDF() -> String {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = (documentsDirectory as NSString).appendingPathComponent("foo.pdf") as String
        print(filePath) // TODO:: remove
        
        let pdfTitle = "Covid-19 Diagnosis Support"
        let pdfMetadata = [
            // The name of the application creating the PDF.
            kCGPDFContextCreator: "Covid-19 Diagnosis Support",

            // The name of the PDF's author.
            kCGPDFContextAuthor: "Covid-19 Diagnosis Support",

            // The title of the PDF.
            kCGPDFContextTitle: "Covid-19 Diagnosis Support",

            // Encrypts the document with the value as the owner password. Used to enable/disable different permissions.
//            kCGPDFContextOwnerPassword: "myPassword123"
        ]

        // Creates a new PDF file at the specified path.
        UIGraphicsBeginPDFContextToFile(filePath, CGRect.zero, pdfMetadata)
        
        // Creates a new page in the current PDF context.
        UIGraphicsBeginPDFPage()

        // Default size of the page is 612x72.
        let pageSize = UIGraphicsGetPDFContextBounds().size
        let font = UIFont.preferredFont(forTextStyle: .largeTitle)

        // Let's draw the title of the PDF on top of the page.
        let attributedPDFTitle = NSAttributedString(string: pdfTitle, attributes: [NSAttributedString.Key.font: font])
        let stringSize = attributedPDFTitle.size()
        let stringRect = CGRect(x: (pageSize.width / 2 - stringSize.width / 2), y: 20, width: stringSize.width, height: stringSize.height)
        attributedPDFTitle.draw(in: stringRect)
        
        // Closes the current PDF context and ends writing to the file.
        UIGraphicsEndPDFContext()
        
        return filePath
    }
}

