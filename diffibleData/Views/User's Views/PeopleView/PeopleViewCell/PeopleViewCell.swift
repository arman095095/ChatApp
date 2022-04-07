//
//  ImageCell.swift
//  diffibleData
//
//  Created by Arman Davidoff on 22.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import SwiftUI
import SDWebImage // Библиотека для правильной загрузки изображения по Url


class PeopleViewCell: UICollectionViewCell {
    
    static var idCell: String = "imageCell"
    private var userImage = UIImageView()
    private var onlineImageView = UIImageView()
    private var nameLabel = UILabel()
    private var container = UIView()
    private var nameLabelWidthConstraint: NSLayoutConstraint!
    
    func config<T>(value: T) where T : Hashable {
        guard let value = value as? MUser else { return }
        nameLabel.text = value.userName + ", " + DateFormatManager().getAge(date: value.birthday)
        userImage.sd_setImage(with: URL(string: value.imageUrl),completed: nil) //метод установки для ImageView вызывается
        onlineImageView.isHidden = !value.online
        nameLabelWidthConstraint.constant = nameLabel.text!.width(font: nameLabel.font)
        container.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupSubviews()
    }
    
    override func prepareForReuse() {
        userImage.image = nil
        onlineImageView.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: UI Setup
private extension PeopleViewCell {
    
    func setupView() {
        setupConstraints()
        backgroundColor = .white
        self.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.5
        self.layer.cornerRadius = 12
    }
    
    func setupSubviews() {
        userImage.sizeToFit()
        userImage.contentMode = .scaleAspectFill
        onlineImageView.image = UIImage(named: "online")
        onlineImageView.tintColor = UIColor.onlineColor()
        container.layer.cornerRadius = 12
        container.clipsToBounds = true
        userImage.clipsToBounds = true
    }
    
    func setupConstraints() {
        addSubview(container)
        container.addSubview(userImage)
        container.addSubview(nameLabel)
        container.addSubview(onlineImageView)
        container.translatesAutoresizingMaskIntoConstraints = false
        userImage.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        onlineImageView.translatesAutoresizingMaskIntoConstraints = false
        
        container.topAnchor.constraint(equalTo: topAnchor).isActive = true
        container.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        container.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        container.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        userImage.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        userImage.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        userImage.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        userImage.heightAnchor.constraint(equalTo: container.widthAnchor).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: userImage.bottomAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor,constant: 8).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        nameLabelWidthConstraint = nameLabel.widthAnchor.constraint(equalToConstant: 0)
        nameLabelWidthConstraint.isActive = true
        
        onlineImageView.heightAnchor.constraint(equalToConstant: 9).isActive = true
        onlineImageView.widthAnchor.constraint(equalToConstant: 9).isActive = true
        onlineImageView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor, constant: 1).isActive = true
        onlineImageView.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 6).isActive = true
    }   
}

