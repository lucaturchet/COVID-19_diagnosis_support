//
//  HomeViewController.swift
//  Covid-19DiagnosisSupport
//
//  Created by Luca Gasparetto on 04/04/2020.
//  Copyright © 2020 Luca Gasparetto. All rights reserved.
//

import UIKit
import Macaw

struct PatientReport {
    var name: String
    var lastName: String
    var dateOfBirth: String
    var dateOfAcquisition: String
}

class HomeViewController: UIViewController, UITextViewDelegate {

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.clipsToBounds = false
        scrollView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    let container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        
        return view
    }()
    
    let grayContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemGray4
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.FlatColors.borderGray.cgColor
        return view
    }()
    
    let lungsSVGView: SVGView = {
        let view = SVGView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.fileName = "lungs_areas"
        
        return view
    }()
    
    let form = FillableUserForm()
    let legenda = LegendaView()
    let totals = TotalsView()
    
    let generateReportButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("GENERATE REPORT", for: .normal)
        button.backgroundColor = UIColor.systemGray4
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.setTitleColor(UIColor.DynamicColors.blackWhite, for: .normal)
        
        return button
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
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.FlatColors.borderGray.cgColor
        view.layer.borderWidth = 1
//        view.text = "Here the clinician can add a general comment on the findings..."
        
        return view
    }()
    
    var scrollViewBottomAnchor: NSLayoutConstraint?
    
    var colors: [Color] = []
    var nodes: [String] = []
    var onOpenPDF: ((_ patient: PatientReport, _ areas: [Int], _ notes: String) -> ())?
    var onColorDecided: ((_ nodeTag: String, _ color: Color) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.systemGray6
        
        self.notesTextView.delegate = self
        
        // keyboard management
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(adjustForKeyboard(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(adjustForKeyboard(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

        self.generateReportButton.addTarget(self, action: #selector(generateNewReport), for: .touchUpInside)
        
        self.view.addSubview(self.scrollView)
        self.scrollView.anchorViewTop(top: self.view.safeAreaLayoutGuide.topAnchor, topC: 0,
                                      leading: self.view.leadingAnchor, leadingC: 40,
                                      trailing: self.view.trailingAnchor, trailingC: -40,
                                      height: nil)
        self.scrollViewBottomAnchor = self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        self.scrollViewBottomAnchor?.isActive = true
        
        self.addChild(self.form)
        self.scrollView.addSubview(self.form.view)
        self.form.view.anchorViewTopLeft(top: self.scrollView.topAnchor, topC: 0,
                                         leading: self.scrollView.leadingAnchor, leadingC: 0,
                                         width: 180, height: 260)
        self.form.didMove(toParent: self)
        
        self.scrollView.addSubview(self.legenda)
        self.legenda.anchorViewTopLeft(top: self.form.view.bottomAnchor, topC: 10,
                                       leading: self.scrollView.leadingAnchor, leadingC: 0,
                                       width: 180, height: 220)
        
        self.scrollView.addSubview(self.totals)
        self.totals.anchorViewTopLeft(top: self.legenda.bottomAnchor, topC: 10,
                                       leading: self.scrollView.leadingAnchor, leadingC: 0,
                                       width: 180, height: 190)
        
        self.scrollView.addSubview(self.container)
        self.container.anchorViewTop(top: self.scrollView.topAnchor, topC: 0,
                                     leading: self.legenda.trailingAnchor, leadingC: 10,
                                     trailing: self.scrollView.trailingAnchor, trailingC: 0,
                                     height: 490)
        self.container.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor, constant: -190).isActive = true
        
        self.container.addSubview(self.grayContainer)
        self.grayContainer.topAnchor.constraint(equalTo: self.container.topAnchor, constant: 0).isActive = true
        self.grayContainer.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 0).isActive = true
        self.grayContainer.trailingAnchor.constraint(lessThanOrEqualTo: self.container.trailingAnchor, constant: 0).isActive = true
        self.grayContainer.bottomAnchor.constraint(equalTo: self.container.bottomAnchor, constant: 0).isActive = true
        
        self.grayContainer.addSubview(self.lungsSVGView)
        self.lungsSVGView.anchorView(top: self.grayContainer.topAnchor, topC: 5,
                                     leading: self.grayContainer.leadingAnchor, leadingC: 40,
                                     trailing: self.grayContainer.trailingAnchor, trailingC: -40,
                                     bottom: self.grayContainer.bottomAnchor, bottomC: -5)

        self.scrollView.addSubview(self.generateReportButton)
        self.generateReportButton.anchorViewTopLeft(top: self.totals.bottomAnchor, topC: 10,
                                                    leading: self.scrollView.leadingAnchor, leadingC: 0,
                                                    width: 180, height: 40)
        
        self.scrollView.addSubview(self.notesTitle)
        self.notesTitle.anchorViewTop(top: self.totals.topAnchor, topC: 0,
                                      leading: self.totals.trailingAnchor, leadingC: 10,
                                      trailing: self.scrollView.trailingAnchor, trailingC: -10,
                                      height: nil)
        
        self.scrollView.addSubview(self.notesTextView)
        self.notesTextView.anchorView(top: self.notesTitle.bottomAnchor, topC: 5,
                                      leading: self.totals.trailingAnchor, leadingC: 10,
                                      trailing: self.grayContainer.trailingAnchor, trailingC: 0,
                                      bottom: self.generateReportButton.bottomAnchor, bottomC: 0)
        
        self.generateReportButton.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
    }

    // MARK: Actions
    @objc func generateNewReport(){
        var decided: [Int] = Array.init(repeating: 0, count: self.colors.count - 1)
        for node in self.nodes {
            let index = Int.random(in: 0..<self.colors.count)
            if index != 4 {
                decided[index] += 1
            }
            let color = self.colors[index]
            //Change node color
            self.lungsSVGView.changeNodeColor(nodeTag: node, nodeColor: color)
            self.onColorDecided?(node, color)
        }
        
        self.totals.setAreas(decided: decided)
        self.onOpenPDF?(self.form.getPatient(), decided, self.notesTextView.text)
    }
    
    // MARK: TextViewDelegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.activeTextView = textView
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.activeTextView = nil
    }
    
    var activeTextView: UITextView?
    // MARK: Keyboard management
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewHeight = keyboardScreenEndFrame.height
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            self.scrollView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 40, right: 0)
            self.scrollViewBottomAnchor?.constant = -keyboardViewHeight
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            if let active = self.activeTextView {
                self.scrollView.scrollRectToVisible(self.view.convert(active.frame, to: self.view),
                                                    animated: true)
            }else{
                self.scrollView.scrollRectToVisible(self.scrollView.convert(self.form.view.frame, to: self.scrollView),
                                                    animated: true)
            }
        }else{
            self.scrollView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
            self.scrollViewBottomAnchor?.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
