//
//  PDFViewController.swift
//  Covid-19DiagnosisSupport
//
//  Created by Luca Gasparetto on 22/03/2020.
//  Copyright © 2020 Luca Gasparetto. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewerViewController: UIViewController {

    let pdfView: PDFView = {
        let view = PDFView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.DynamicColors.whiteBlack
        
        self.view.addSubview(self.pdfView)
        self.pdfView.anchorViewTo(superView: self.view)
    }
    
    func viewSetup(pdfPath: String){
        // load pdf
        if let pdfDocument = PDFDocument(url: URL(fileURLWithPath: pdfPath)) {
            self.pdfView.displayMode = .singlePageContinuous
            self.pdfView.autoScales = true
            self.pdfView.displayDirection = .vertical
            self.pdfView.document = pdfDocument
        }
    }
}
