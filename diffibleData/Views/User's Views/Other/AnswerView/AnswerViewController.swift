//
//  AcceptOrDeny.swift
//  diffibleData
//
//  Created by Arman Davidoff on 24.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import SwiftUI
import SDWebImage

class AnswerViewController :UIViewController {
    
    let imageView =  UIImageView()
    let containerView = UIView()
    let nameLabel = UILabel()
    let infoLabel = UILabel()
    let acceptButton = UIButton(title: "Принять", backgroundColor: .mainWhite(), titleColor: .mainWhite(), font: UIFont.avenir26(), shadow: false, cornerRaduis: 13, google: false, height: 60)
    let denyButton = UIButton(title: "Отклонить", backgroundColor: .mainWhite(), titleColor: .buttonRed(), font: UIFont.avenir26(), shadow: false, cornerRaduis: 13, google: false, height: 60)
    var buttonsStackView: UIStackView!
    
    private let answerViewModel: AnswerViewModel
    weak var delegate: ChatsOperationsDelegate?
    
    init(chat: MChat) {
        self.answerViewModel = AnswerViewModel(chat: chat)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        config()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        acceptButton.addGradientInView(cornerRadius: 13)
    }
    
    @objc func removeChat() {
        dismiss(animated: true) {
            self.delegate?.removeWaitingChat(chat: self.answerViewModel.currentChat)
        }
    }
    
    @objc func acceptChat() {
        dismiss(animated: true) {
            self.delegate?.changeChatStatus(chat: self.answerViewModel.currentChat)
        }
    }
    
    private func config() {
        imageView.sd_setImage(with: answerViewModel.imageURL, completed: nil)
        nameLabel.text = answerViewModel.name
        infoLabel.text = "Хочет с Вами пообщаться"
    }
}

//MARK: Setup UI
private extension AnswerViewController {
    
    func setupViews() {
        view.backgroundColor = .systemGray6
        imageView.contentMode = .scaleAspectFill
        nameLabel.font = UIFont.avenir26()
        infoLabel.font = UIFont.avenir20()
        infoLabel.numberOfLines = 0
        
        containerView.layer.cornerRadius = 30
        containerView.backgroundColor = .systemGray6
        denyButton.layer.borderWidth = 1.3
        denyButton.layer.borderColor = UIColor.buttonRed().cgColor
        
        buttonsStackView = UIStackView(arrangedSubviews: [acceptButton,denyButton], spacing: 8, axis: .horizontal)
        buttonsStackView.distribution = .fillEqually
        self.view.addSubview(imageView)
        self.view.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(infoLabel)
        containerView.addSubview(buttonsStackView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupConstraints() {
        imageView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 260).isActive = true
        
        nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 30).isActive = true
        nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor,constant: 30).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -30).isActive = true
        
        infoLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 30).isActive = true
        infoLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,constant: 20).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -20).isActive = true
        
        buttonsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 20).isActive = true
        buttonsStackView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor,constant: 20).isActive = true
        buttonsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -20).isActive = true
       
        buttonsStackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor,constant: -25).isActive = true
        
        imageView.bottomAnchor.constraint(equalTo: containerView.topAnchor,constant: 35).isActive = true
    }
    
    func setupActions() {
        denyButton.addTarget(self, action: #selector(removeChat), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(acceptChat), for: .touchUpInside)
    }
}


