//
//  MessengerTitleView.swift
//  diffibleData
//
//  Created by Arman Davidoff on 03.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit

class MessengerTitleView: UIView {
    
    var titleLabel: UILabel = {
        var view = UILabel()
        view.textAlignment = .center
        view.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var descriptionInfoLabel: UILabel = {
        var view = UILabel()
        view.textAlignment = .center
        view.textColor = .gray
        view.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var avatarImageView: UIImageView = {
        var view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    weak var delegate: MessengerTitleViewDelegate?
    private var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        UIView.layoutFittingExpandedSize
    }
    
    func set(title: String?, imageURL: URL?, description: String?) {
        timer?.invalidate()
        timer = nil
        titleLabel.text = title
        descriptionInfoLabel.text = description
        avatarImageView.sd_setImage(with: imageURL)
        if description == "печатает" {
            startAnimateTyping(description: description!)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.layer.frame.height / 2
        avatarImageView.clipsToBounds = true
    }
}

private extension MessengerTitleView {
    
    func setupViews() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.backgroundColor = .white
        avatarImageView.isUserInteractionEnabled = true
        addSubview(titleLabel)
        addSubview(avatarImageView)
        addSubview(descriptionInfoLabel)
    }
    
    func setupConstraints() {
        avatarImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        avatarImageView.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -10).isActive = true
        avatarImageView.heightAnchor.constraint(equalTo: heightAnchor, constant: -8).isActive = true
        avatarImageView.widthAnchor.constraint(equalTo: heightAnchor, constant: -8).isActive = true
        
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 10).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: titleLabel.font.lineHeight).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: avatarImageView.leadingAnchor,constant: -10).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        descriptionInfoLabel.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 10).isActive = true
        descriptionInfoLabel.heightAnchor.constraint(equalToConstant: descriptionInfoLabel.font.lineHeight).isActive = true
        descriptionInfoLabel.trailingAnchor.constraint(equalTo: avatarImageView.leadingAnchor,constant: -10).isActive = true
        descriptionInfoLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7).isActive = true
    }
    
    func setupActions() {
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openProfile)))
    }
    
    func startAnimateTyping(description: String) {
        let count = description.count + 3
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] (_) in
            guard let self = self else { return }
            if self.descriptionInfoLabel.text?.count == count {
                self.descriptionInfoLabel.text = description
            } else {
                self.descriptionInfoLabel.text = self.descriptionInfoLabel.text! + "."
            }
        }
        self.timer = timer
        RunLoop.current.add(self.timer!, forMode: .common)
    }
    
    @objc func openProfile() {
        delegate?.presentProfile()
    }
}
