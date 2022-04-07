//
//  WaitingChatCell.swift
//  diffibleData
//
//  Created by Arman Davidoff on 20.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//
import SwiftUI
import UIKit
import SDWebImage

class WaitingChatCell: UICollectionViewCell {
    
    static var idCell: String = "WaitingChatsId"
    private var userImageView = UIImageView()
    
    func config<T>(value: T) where T : Hashable {
        guard let value = value as? MChat else { return }
        userImageView.sd_setImage(with: URL(string: value.friendUser!.imageUrl), completed: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: Setup UI
private extension WaitingChatCell {
    
    func setupViews() {
        addSubview(userImageView)
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        
        userImageView.layer.cornerRadius = ChatsConstants.waitingChatHeight/2
        userImageView.clipsToBounds = true
        userImageView.sizeToFit()
        userImageView.contentMode = .scaleAspectFill
    }
    
    func setupConstraints() {
        userImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        userImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        userImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        userImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        userImageView.heightAnchor.constraint(equalToConstant: ChatsConstants.waitingChatHeight).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: ChatsConstants.waitingChatHeight).isActive = true
    }
}






