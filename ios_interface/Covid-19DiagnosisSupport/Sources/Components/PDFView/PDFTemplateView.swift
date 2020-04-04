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
    
    let userForm = UserForm()
    
    let grayContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.FlatColors.borderGray.cgColor
        view.backgroundColor = UIColor.FlatColors.containerGray
        return view
    }()

    let lungsSVGView: SVGView = {
        let view = SVGView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.fileName = "lungs_areas"
        
        return view
    }()
    
    let legenda = LegendaView()
    
    let totals = TotalsView()
    
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
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.FlatColors.borderGray.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        
        // block colors to white theme
        self.notesTitle.textColor = .black
        self.notesTextView.textColor = .black
        
        self.userForm.blockColors()
        self.legenda.blockColors()
        self.totals.blockColors()
        
        self.addSubview(self.userForm)
        self.userForm.anchorViewTop(top: self.topAnchor, topC: 40,
                                    leading: self.leadingAnchor, leadingC: 40,
                                    trailing: self.trailingAnchor, trailingC: -40,
                                    height: 120)
        
        self.addSubview(self.grayContainer)
        self.grayContainer.anchorViewTop(top: self.userForm.bottomAnchor, topC: 40,
                                         leading: self.leadingAnchor, leadingC: 40,
                                         trailing: self.trailingAnchor, trailingC: -40,
                                         height: 470)
        
        self.grayContainer.addSubview(self.lungsSVGView)
        self.lungsSVGView.anchorViewTop(top: self.grayContainer.topAnchor, topC: 10,
                                        leading: self.grayContainer.leadingAnchor, leadingC: 20,
                                        trailing: self.grayContainer.trailingAnchor, trailingC: -260,
                                        height: 450)
        
        self.grayContainer.addSubview(self.legenda)
        self.legenda.anchorViewTopRight(top: self.grayContainer.topAnchor, topC: 5,
                                        trailing: self.grayContainer.trailingAnchor, trailingC: -5,
                                        width: 180, height: 220)
        
        self.grayContainer.addSubview(self.totals)
        self.totals.anchorViewBottomRight(bottom: self.grayContainer.bottomAnchor, bottomC: -5,
                                          trailing: self.grayContainer.trailingAnchor, trailingC: -5,
                                          height: 190, width: 180)
        
        self.addSubview(self.notesTitle)
        self.notesTitle.anchorViewTop(top: self.lungsSVGView.bottomAnchor, topC: 40,
                                      leading: self.leadingAnchor, leadingC: 40,
                                      trailing: self.trailingAnchor, trailingC: -40,
                                      height: nil)
        
        self.addSubview(self.notesTextView)
        self.notesTextView.anchorViewTop(top: self.notesTitle.bottomAnchor, topC: 20,
                                         leading: self.leadingAnchor, leadingC: 40,
                                         trailing: self.trailingAnchor, trailingC: -40,
                                         height: 120)
//        self.notesTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -40).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PDFTemplateView {
    
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
