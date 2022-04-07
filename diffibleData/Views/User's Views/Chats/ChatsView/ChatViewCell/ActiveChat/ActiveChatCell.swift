//
//  ActiveChatCell.swift
//  diffibleData
//
//  Created by Arman Davidoff on 20.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//
import UIKit
import SwiftUI
import SDWebImage

class ActiveChatCell: UICollectionViewCell {
    
    static var idCell: String = "ActiveChatsId"
    private var containerView = UIView()
    private var nameLabel = UILabel()
    private var dateLabel = UILabel()
    private var onlineImageView = UIImageView()
    private var markMessage = UIImageView()
    private var lastMessegeLabel = UILabel()
    private var userImageView = UIImageView()
    private var gradientView = Gradient()
    private var badge = Badge()
    private var deleteButton = UIButton(type: .system)
    private var containerLeadingAnchor: NSLayoutConstraint!
    private var deleteButtonWidthAnchor: NSLayoutConstraint!
    private var lastMessageTrailingAnchor: NSLayoutConstraint!
    private var badgeWidthConstreint: NSLayoutConstraint!
    private var deleteButtonHidden = true
    private var activeChatViewModel: ActiveChatViewModel! {
        didSet {
            setup()
        }
    }
    weak var chatDelegate: ChatsOperationsDelegate?
    
    func config<T>(value: T) where T : Hashable {
        guard let value = value as? MChat else { return }
        activeChatViewModel = ActiveChatViewModel(chat: value)
    }
    
    func animateSelect() {
        UIView.animate(withDuration: 1) {
            self.layer.backgroundColor = UIColor.systemGray5.cgColor
            UIView.animate(withDuration: 1) {
                self.layer.backgroundColor = UIColor.systemGray6.cgColor
            }
        }
    }
    
    private func setup() {
        nameLabel.text = activeChatViewModel.userName
        userImageView.sd_setImage(with: activeChatViewModel.imageURL, completed: nil)
        lastMessegeLabel.text = activeChatViewModel.lastMessageContent
        dateLabel.text = activeChatViewModel.lastMessageDate
        markMessage.image = activeChatViewModel.lastMessageMarkedImage
        onlineImageView.isHidden = !activeChatViewModel.online
        badgeLabelSetup()
    }
   
    override func prepareForReuse() {
        userImageView.image = nil
        onlineImageView.isHidden = true
        containerLeadingAnchor.constant = 0
        deleteButtonWidthAnchor.constant = 0
        lastMessageTrailingAnchor.constant = -8
        markMessage.image = nil
        deleteButtonHidden = true
        badge.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstreints()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: Setup UI
private extension ActiveChatCell {
    
    func badgeLabelSetup() {
        if !activeChatViewModel.newMessagesEnable {
            badge.isHidden = true
            lastMessageTrailingAnchor.constant = -8
        }
        else {
            badge.isHidden = false
            badge.setBadgeCount(count: activeChatViewModel.newMessagesCount)
            badgeWidthConstreint.constant = activeChatViewModel.badgeWidth
            lastMessageTrailingAnchor.constant = -12 - ChatsConstants.badgeHeight
            layoutIfNeeded()
        }
    }
    
    func setupViews() {
        self.backgroundColor = .systemGray6
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        lastMessegeLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lastMessegeLabel.numberOfLines = 2
        lastMessegeLabel.textColor = .gray
        
        markMessage.tintColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        markMessage.contentMode = .scaleAspectFill
        
        onlineImageView.tintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        onlineImageView.image = UIImage(named: "online")
        onlineImageView.layer.cornerRadius = 9
        onlineImageView.layer.borderWidth = 4
        onlineImageView.layer.borderColor = self.backgroundColor?.cgColor
        onlineImageView.layer.masksToBounds = true
        
        dateLabel.textColor = .gray
        dateLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        deleteButton.backgroundColor = .systemRed
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.addTarget(self, action: #selector(removeChatTapped), for: .touchUpInside)
        
        userImageView.layer.cornerRadius = ChatsConstants.imageChatHeight/2
        userImageView.clipsToBounds = true
        userImageView.sizeToFit()
        userImageView.contentMode = .scaleAspectFill
        
        gradientView.layer.cornerRadius = 4
        
        addSubview(containerView)
        addSubview(deleteButton)
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(userImageView)
        containerView.addSubview(onlineImageView)
        containerView.addSubview(lastMessegeLabel)
        containerView.addSubview(gradientView)
        containerView.addSubview(badge)
        containerView.addSubview(dateLabel)
        containerView.addSubview(markMessage)
              
        onlineImageView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastMessegeLabel.translatesAutoresizingMaskIntoConstraints = false
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        badge.translatesAutoresizingMaskIntoConstraints = false
        markMessage.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupConstreints() {
        containerLeadingAnchor = containerView.leadingAnchor.constraint(equalTo: leadingAnchor)
        containerLeadingAnchor.isActive = true
        containerView.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        userImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor).isActive = true
        userImageView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor).isActive = true
        userImageView.heightAnchor.constraint(equalToConstant: ChatsConstants.imageChatHeight).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: ChatsConstants.imageChatHeight).isActive = true
        
        deleteButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: ChatsConstants.imageChatHeight).isActive = true
        deleteButtonWidthAnchor = deleteButton.widthAnchor.constraint(equalToConstant: 0)
        deleteButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        deleteButtonWidthAnchor.isActive = true
        
        gradientView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor).isActive = true
        gradientView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor).isActive = true
        gradientView.heightAnchor.constraint(equalToConstant: ChatsConstants.imageChatHeight).isActive = true
        gradientView.widthAnchor.constraint(equalToConstant: 6).isActive = true
        
        badge.topAnchor.constraint(equalTo: self.dateLabel.bottomAnchor,constant: 8).isActive = true
        badge.trailingAnchor.constraint(equalTo: self.gradientView.leadingAnchor, constant: -10).isActive = true
        badge.heightAnchor.constraint(equalToConstant: ChatsConstants.badgeHeight).isActive = true
        badgeWidthConstreint = badge.widthAnchor.constraint(equalToConstant: ChatsConstants.badgeHeight)
        badgeWidthConstreint.isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 15).isActive = true
        nameLabel.topAnchor.constraint(equalTo: self.userImageView.topAnchor).isActive = true
        
        lastMessegeLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 15).isActive = true
        lastMessageTrailingAnchor = lastMessegeLabel.trailingAnchor.constraint(equalTo: gradientView.leadingAnchor,constant: -8)
        lastMessageTrailingAnchor.isActive = true
        lastMessegeLabel.topAnchor.constraint(equalTo: self.containerView.centerYAnchor, constant: -UIFont.systemFont(ofSize: 15, weight: .regular).lineHeight/2).isActive = true
        
        dateLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: self.gradientView.leadingAnchor, constant: -10).isActive = true
        
        markMessage.heightAnchor.constraint(equalToConstant: 10).isActive = true
        markMessage.widthAnchor.constraint(equalToConstant: 13).isActive = true
        markMessage.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        markMessage.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -6.5).isActive = true
        
        onlineImageView.heightAnchor.constraint(equalToConstant: 18).isActive = true
        onlineImageView.widthAnchor.constraint(equalToConstant: 18).isActive = true
        onlineImageView.bottomAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 0).isActive = true
        onlineImageView.trailingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 0).isActive = true
        
    }
}

//MARK: DeleteButton
private extension ActiveChatCell {
    
    func setupGesture() {
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(deleteButtonShow)))
    }
    
    @objc func deleteButtonShow(gesture: UIPanGestureRecognizer) {
        let x = gesture.translation(in: self).x
        switch gesture.state {
        case .changed:
            animationDeleteButton(constant: x)
        case .ended:
            deleteButtonEnd(constant: x)
        default:
            break
        }
    }
    
    func deleteButtonEnd(constant: CGFloat) {
        if constant < 0 && deleteButtonHidden {
            if -constant > self.frame.width/10 {
                showDeleteButton()
            } else {
                hideDeleteButton()
            }
        } else if constant < 0 && !deleteButtonHidden {
            showDeleteButton()
        } else if constant > 0 && !deleteButtonHidden {
            if constant > self.frame.width/10 {
                hideDeleteButton()
            } else {
                showDeleteButton()
            }
        }
    }
    
    func animationDeleteButton(constant: CGFloat) {
        if deleteButtonHidden && constant < 0 {
            deleteButtonWidthAnchor.constant = -constant
            containerLeadingAnchor.constant = constant
            self.layoutIfNeeded()
        } else if !deleteButtonHidden && constant < self.frame.width/5 {
            deleteButtonWidthAnchor.constant = self.frame.width/5 - constant
            containerLeadingAnchor.constant = -self.frame.width/5 + constant
            self.layoutIfNeeded()
        } else {
            self.deleteButtonHidden = true
            self.deleteButtonWidthAnchor.constant = 0
            self.containerLeadingAnchor.constant = 0
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            }
            
        }
    }
    
    func showDeleteButton() {
        deleteButtonHidden = false
        deleteButtonWidthAnchor.constant = self.frame.width/5
        containerLeadingAnchor.constant = -self.frame.width/5
        UIView.animate(withDuration: 0.4) {
            self.layoutIfNeeded()
        }
    }
    
    func hideDeleteButton() {
        deleteButtonHidden = true
        deleteButtonWidthAnchor.constant = 0
        containerLeadingAnchor.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
    
    @objc func removeChatTapped() {
        chatDelegate?.removeActiveChat(chat: activeChatViewModel.chat)
    }
}

