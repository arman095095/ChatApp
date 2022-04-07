//
//  ButtonsView.swift
//  diffibleData
//
//  Created by Arman Davidoff on 27.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit

class ButtonsView: UIView {
    
    var firstButton: UIButton =  {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = PostCellConstants.buttonFont
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    private var countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var secondButton: UIButton =  {
        let button = UIButton(type: .system)
        button.titleLabel?.font = PostCellConstants.buttonFont
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.mainApp(), for: .normal)
        return button
    }()
    private let firstButtonWidth: CGFloat
    private let secondButtonWidth: CGFloat
    private let height: CGFloat = PostCellConstants.buttonFont.lineHeight
    
    init(firstButtonTitle: String, secondButtonTitle: String) {
        firstButtonWidth = firstButtonTitle.width(font: PostCellConstants.buttonFont)
        secondButtonWidth = secondButtonTitle.width(font: PostCellConstants.buttonFont)
        super.init(frame: .zero)
        firstButton.setTitle(firstButtonTitle, for: .normal)
        secondButton.setTitle(secondButtonTitle, for: .normal)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCount(count: Int) {
        countLabel.text = "\(count)"
    }
}

private extension ButtonsView {
    
    func setupViews() {
        addSubview(firstButton)
        addSubview(countLabel)
        addSubview(secondButton)
    }
    
    func setupConstraints() {
        firstButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        firstButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        firstButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        firstButton.widthAnchor.constraint(equalToConstant: firstButtonWidth).isActive = true
        firstButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        countLabel.leadingAnchor.constraint(equalTo: firstButton.trailingAnchor,constant: 10).isActive = true
        countLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        countLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        countLabel.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        secondButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        secondButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        secondButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        secondButton.leadingAnchor.constraint(equalTo: countLabel.trailingAnchor,constant: -10).isActive = true
        secondButton.widthAnchor.constraint(equalToConstant: secondButtonWidth).isActive = true
        secondButton.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}
