//
//  LoadButton.swift
//  diffibleData
//
//  Created by Arman Davidoff on 22.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit

class LoadButton: UIButton {
    
    private let activity: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.hidesWhenStopped = true
        return view
    }()
    let label = UILabel()
    
    init(title: String, backgroundColor: UIColor, titleColor: UIColor, font: UIFont? = UIFont.avenir20(), shadow: Bool = false, cornerRaduis: CGFloat = 4, google: Bool = false, height: CGFloat? = nil, activityColor: UIColor, shadowColor: UIColor? = nil) {
        super.init(frame: .zero)
        self.label.text = title
        self.activity.color = activityColor
        self.label.font = font
        self.label.textColor = titleColor
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRaduis

        if shadow {
            setupShadow()
        }
        if google {
            setupGoogleLogo()
        }
        if let height = height  {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        setupLabel()
        if shadowColor != nil {
            self.layer.shadowColor = shadowColor!.cgColor
        }
    }
    
    override func layoutSubviews() {
        setupActivity()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loading() {
        activity.isHidden = false
        label.isHidden = true
        activity.startAnimating()
    }
    
    func stop() {
        label.isHidden = false
        activity.stopAnimating()
    }
}

//MARK: Setup UI
private extension LoadButton {
    
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
    
    func setupActivity() {
        self.addSubview(activity)
        activity.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activity.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activity.heightAnchor.constraint(equalToConstant: frame.height).isActive = true
        activity.widthAnchor.constraint(equalToConstant: frame.height).isActive = true
    }
    
    func setupLabel() {
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
}
