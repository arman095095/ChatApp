//
//  BlackListViewCell.swift
//  diffibleData
//
//  Created by Arman Davidoff on 25.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit

class BlackListViewCell: UITableViewCell {
    
    static let idCell = "BlackListViewCell"
    private let userImageView = UIImageView()
    private let userNameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupContraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(user: MUser) {
        userImageView.sd_setImage(with: URL(string: user.photoURL))
        userNameLabel.text = user.name
    }
}

private extension BlackListViewCell {
    
    func setupViews() {
        contentView.backgroundColor = .systemGray6
        userNameLabel.numberOfLines = 1
        userImageView.layer.cornerRadius = BlackListConstants.heightImageView/2
        userImageView.layer.masksToBounds = true
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userImageView)
    }
    
    func setupContraints() {
        userImageView.heightAnchor.constraint(equalToConstant: BlackListConstants.heightImageView).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: BlackListConstants.heightImageView).isActive = true
        userImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        
        userNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 8).isActive = true
    }
}
