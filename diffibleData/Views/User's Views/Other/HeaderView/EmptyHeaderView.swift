//
//  EmptyHeader.swift
//  diffibleData
//
//  Created by Arman Davidoff on 23.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit

class EmptyHeaderView: UICollectionReusableView {
    
    enum InfoType: String {
        case emptyPeople = "Пользователей нет"
        case emptyActiveChats = "Активных чатов нет"
        case emptyBlackList = "Заблокированных пользователей нет"
        case emptyPosts = "Постов пока нет"
    }
    
    static let idHeader = "EmptyView"
    private var title = UILabel()
    private var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        title.numberOfLines = 0
        title.textColor = .systemGray2
        title.font = UIFont.avenir20()
        title.textAlignment = .center
        imageView.tintColor = .systemGray3
        title.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        removeAllConstraints()
        imageView.image = nil
    }
    
    func config(type: InfoType, text: String? = nil) {
        if let text = text {
            title.text = text
        } else {
            title.text = type.rawValue
        }
        switch type {
        case .emptyPeople:
            imageView.image = UIImage(systemName: "person.2")
            setupConstraintsPeopleView()
        case .emptyActiveChats:
            imageView.image = UIImage(systemName: "message")
            setupConstraintsActiveChatsView()
        case .emptyBlackList:
            imageView.image = UIImage(systemName: "person.2")
            setupConstraintsPeopleView()
        case .emptyPosts:
            imageView.image = UIImage(systemName: "rectangle.stack.person.crop")
            setupConstraintsPeopleView()
        }
    }
    
    private func setupConstraintsPeopleView() {
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: UIScreen.main.bounds.height/5).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        title.topAnchor.constraint(equalTo: imageView.bottomAnchor,constant: 12).isActive = true
    }
    
    private func setupConstraintsActiveChatsView() {
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: UIScreen.main.bounds.height/12).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        title.topAnchor.constraint(equalTo: imageView.bottomAnchor,constant: 12).isActive = true
    }
}
