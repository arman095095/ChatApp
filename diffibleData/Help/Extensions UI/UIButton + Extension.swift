//
//  ButtonExtenshion.swift
//  diffibleData
//
//  Created by Arman Davidoff on 23.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import Foundation

extension UIButton {
    
    convenience init(title: String, backgroundColor: UIColor , titleColor: UIColor, font: UIFont? = UIFont.avenir20(), shadow: Bool = false, cornerRaduis: CGFloat = 4, google: Bool = false, height: CGFloat? = nil, shadowColor: UIColor? = nil) {
        self.init(type: .system)
        self.setTitle(title,for: .normal)
        self.setTitleColor(titleColor,for: .normal)
        self.backgroundColor = backgroundColor
        self.titleLabel?.font = font
        self.layer.cornerRadius = cornerRaduis
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if shadow {
            setupShadow()
        }
        if google {
            setupGoogleLogo()
        }
        if shadowColor != nil {
            self.layer.shadowColor = shadowColor!.cgColor
        }
    }
    
    convenience init(image: UIImage) {
        self.init(type: .system)
        self.setImage(image, for: .normal)
    }
    
    //Color for image(systemtype)
    func setupForSystemImageColor(color: UIColor) {
        let template = self.currentImage?.withRenderingMode(.alwaysTemplate)
        self.setImage(template, for: .normal)
        self.tintColor = color
    }
}

private extension UIButton {
    
    func setupShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.2
    }
    
    func setupGoogleLogo() {
        let googleIcon = UIImageView(image: #imageLiteral(resourceName: "google-icon"))
        self.addSubview(googleIcon)
        googleIcon.translatesAutoresizingMaskIntoConstraints = false
        googleIcon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        googleIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        googleIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        googleIcon.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
}
