//
//  HomeViewController.swift
//  Covid-19DiagnosisSupport
//
//  Created by Luca Gasparetto on 04/04/2020.
//  Copyright © 2020 Luca Gasparetto. All rights reserved.
//

import UIKit
import Macaw

class HomeViewController: UIViewController {

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.clipsToBounds = false
        scrollView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
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
    
    let legenda = LegendaView()
    let totals = TotalsView()
    
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
    
    var colors: [Color] = []
    var nodes: [String] = []
    var onOpenPDF: (() -> ())?
    var onColorDecided: ((_ nodeTag: String, _ color: Color) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        self.shareButton.addTarget(self, action: #selector(openPDF), for: .touchUpInside)
        
        self.view.addSubview(self.scrollView)
        self.scrollView.anchorView(top: self.view.safeAreaLayoutGuide.topAnchor, topC: 0,
                                   leading: self.view.leadingAnchor, leadingC: 40,
                                   trailing: self.view.trailingAnchor, trailingC: -40,
                                   bottom: self.view.safeAreaLayoutGuide.bottomAnchor, bottomC: 0)
        
        self.scrollView.addSubview(self.legenda)
        self.legenda.anchorViewTopLeft(top: self.scrollView.topAnchor, topC: 0,
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
                                     height: 450)
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
        
        self.scrollView.addSubview(self.randomizeButton)
        self.randomizeButton.anchorViewTopCenter(top: self.grayContainer.bottomAnchor, topC: 40,
                                                 centerX: self.scrollView.centerXAnchor,
                                                 centerY: nil,
                                                 width: 200, height: 50)
        self.randomizeButton.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant: -40).isActive = true

        self.scrollView.addSubview(self.shareButton)
        self.shareButton.anchorViewLeft(centerY: self.randomizeButton.centerYAnchor,
                                        leading: self.randomizeButton.trailingAnchor, leadingC: 50,
                                        trailing: nil, trailingC: nil,
                                        width: 50, height: 50)
    }

    // MARK: Actions
    @objc func openPDF(){
        self.onOpenPDF?()
    }
    
    @objc func generateNewReport(){
        for node in self.nodes {
            let color = self.colors[Int.random(in: 0..<self.colors.count)]
            //Change node color
            self.lungsSVGView.changeNodeColor(nodeTag: node, nodeColor: color)
            self.onColorDecided?(node, color)
        }
        
        if self.shareButton.alpha == 0 {
            // once first generation is completed show the share button to render PDF
            UIView.animate(withDuration: 0.3) {
                self.shareButton.alpha = 1
            }
        }
    }
    
    // MARK: Keyboard management
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = keyboardScreenEndFrame
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.size.height, right: 0)
            let bottomOffset = CGPoint(x: 0, y: keyboardViewEndFrame.size.height - (self.view.frame.maxY - (self.randomizeButton.frame.maxY + 40)))
            self.scrollView.setContentOffset(bottomOffset, animated: true)
        }else{
            UIView.animate(withDuration: 0.3) {
                self.scrollView.contentInset = .zero
            }
        }
    }
}
