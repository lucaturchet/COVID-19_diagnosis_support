//
//  AnchorsExtensions.swift
//  Luca Gasparetto
//
//  Created by Luca Gasparetto on 09/09/2019.
//  Copyright © 2019 Luca Gasparetto. All rights reserved.
//

import UIKit

extension UIView {
    func anchorView(top: NSLayoutYAxisAnchor, topC: CGFloat,
                    leading: NSLayoutXAxisAnchor, leadingC: CGFloat,
                    trailing: NSLayoutXAxisAnchor, trailingC: CGFloat,
                    bottom: NSLayoutYAxisAnchor, bottomC: CGFloat, debugID: String? = nil)
    {
        let top = self.topAnchor.constraint(equalTo: top, constant: topC)
        top.isActive = true
        let lead = self.leadingAnchor.constraint(equalTo: leading, constant: leadingC)
        lead.isActive = true
        let trail = self.trailingAnchor.constraint(equalTo: trailing, constant: trailingC)
        trail.isActive = true
        let bottom = self.bottomAnchor.constraint(equalTo: bottom, constant: bottomC)
        bottom.isActive = true
        
        if let id = debugID {
            top.identifier = id + "_top"
            lead.identifier = id + "_lead"
            trail.identifier = id + "_trail"
            bottom.identifier = id + "_bottom"
        }
    }
    
    func anchorViewTo(superView: UIView){
        self.topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
    }
    
    func anchorViewLeft(centerY: NSLayoutYAxisAnchor,
                        centerYC: CGFloat = 0,
                        leading: NSLayoutXAxisAnchor,leadingC: CGFloat,
                        trailing: NSLayoutXAxisAnchor?, trailingC: CGFloat?,
                        width: CGFloat?, height: CGFloat?)
    {
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        self.centerYAnchor.constraint(equalTo: centerY, constant: centerYC).isActive = true
        self.leadingAnchor.constraint(equalTo: leading, constant: leadingC).isActive = true
        if let trailing = trailing {
            self.trailingAnchor.constraint(equalTo: trailing, constant: trailingC ?? 0).isActive = true
        }
    }
    
    func anchorViewRight(centerY: NSLayoutYAxisAnchor,
                         centerYC: CGFloat = 0,
                         trailing: NSLayoutXAxisAnchor, trailingC: CGFloat,
                         width: CGFloat?, height: CGFloat?)
    {
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        self.centerYAnchor.constraint(equalTo: centerY, constant: centerYC).isActive = true
        self.trailingAnchor.constraint(equalTo: trailing, constant: trailingC).isActive = true
    }
    
    func anchorViewTop(top: NSLayoutYAxisAnchor, topC: CGFloat?,
                       leading: NSLayoutXAxisAnchor, leadingC: CGFloat,
                       trailing: NSLayoutXAxisAnchor, trailingC: CGFloat,
                       height: CGFloat?)
    {
        self.topAnchor.constraint(equalTo: top, constant: topC ?? 0).isActive = true
        self.leadingAnchor.constraint(equalTo: leading, constant: leadingC).isActive = true
        self.trailingAnchor.constraint(equalTo: trailing, constant: trailingC).isActive = true
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func anchorViewTopCenter(top: NSLayoutYAxisAnchor, topC: CGFloat?,
                             centerX: NSLayoutXAxisAnchor?, centerXC: CGFloat = 0,
                             centerY: NSLayoutYAxisAnchor?,
                             width: CGFloat?, height: CGFloat?)
    {
        self.topAnchor.constraint(equalTo: top, constant: topC ?? 0).isActive = true
        if let centerX = centerX {
            self.centerXAnchor.constraint(equalTo: centerX, constant: centerXC).isActive = true
        }
        if let centerY = centerY {
            self.centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func anchorViewTopLeft(top: NSLayoutYAxisAnchor, topC: CGFloat,
                           leading: NSLayoutXAxisAnchor, leadingC: CGFloat,
                           width: CGFloat?, height: CGFloat?)
    {
        self.topAnchor.constraint(equalTo: top, constant: topC).isActive = true
        self.leadingAnchor.constraint(equalTo: leading, constant: leadingC).isActive = true
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func anchorViewTopRight(top: NSLayoutYAxisAnchor, topC: CGFloat,
                            trailing: NSLayoutXAxisAnchor, trailingC: CGFloat,
                            width: CGFloat?, height: CGFloat?)
    {
        self.topAnchor.constraint(equalTo: top, constant: topC).isActive = true
        self.trailingAnchor.constraint(equalTo: trailing, constant: trailingC).isActive = true
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func anchorViewBottom(bottom: NSLayoutYAxisAnchor, bottomC: CGFloat? = nil,
                          leading: NSLayoutXAxisAnchor, leadingC: CGFloat,
                          trailing: NSLayoutXAxisAnchor, trailingC: CGFloat,
                          height: CGFloat?)
    {
        self.bottomAnchor.constraint(equalTo: bottom, constant: bottomC ?? 0).isActive = true
        self.leadingAnchor.constraint(equalTo: leading, constant: leadingC).isActive = true
        self.trailingAnchor.constraint(equalTo: trailing, constant: trailingC).isActive = true
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func anchorViewBottomCenter(bottom: NSLayoutYAxisAnchor, bottomC: CGFloat?,
                                centerX: NSLayoutXAxisAnchor?, centerXC: CGFloat = 0,
                                centerY: NSLayoutYAxisAnchor?,
                                width: CGFloat?, height: CGFloat?)
    {
        self.bottomAnchor.constraint(equalTo: bottom, constant: bottomC ?? 0).isActive = true
        if let centerX = centerX {
            self.centerXAnchor.constraint(equalTo: centerX, constant: centerXC).isActive = true
        }
        if let centerY = centerY {
            self.centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func anchorViewBottomLeft(bottom: NSLayoutYAxisAnchor, bottomC: CGFloat? = nil,
                              leading: NSLayoutXAxisAnchor, leadingC: CGFloat,
                              height: CGFloat?, width: CGFloat?)
    {
        self.bottomAnchor.constraint(equalTo: bottom, constant: bottomC ?? 0).isActive = true
        self.leadingAnchor.constraint(equalTo: leading, constant: leadingC).isActive = true
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func anchorViewBottomRight(bottom: NSLayoutYAxisAnchor, bottomC: CGFloat? = nil,
                              trailing: NSLayoutXAxisAnchor, trailingC: CGFloat,
                              height: CGFloat?, width: CGFloat?)
    {
        self.bottomAnchor.constraint(equalTo: bottom, constant: bottomC ?? 0).isActive = true
        self.trailingAnchor.constraint(equalTo: trailing, constant: trailingC).isActive = true
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    }
    
    func anchorViewCenter(centerX: NSLayoutXAxisAnchor,
                             centerY: NSLayoutYAxisAnchor,
                             centerYC: CGFloat? = nil,
                             width: CGFloat?, height: CGFloat?)
    {
        
        self.centerXAnchor.constraint(equalTo: centerX).isActive = true
        self.centerYAnchor.constraint(equalTo: centerY, constant: centerYC ?? 0).isActive = true
        
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}
