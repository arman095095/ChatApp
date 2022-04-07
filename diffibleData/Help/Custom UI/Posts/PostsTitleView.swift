//
//  CustomNavigationBarView.swift
//
//  Created by Алексей Пархоменко on 07/04/2019.
//  Copyright © 2019 Алексей Пархоменко. All rights reserved.
//

import Foundation
import UIKit

class PostsTitleView: UIView {
    
    private var textViewButton: UIButton = {
        let view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        view.setTitle("Поделитесь, что у Вас нового...", for: .normal)
        view.contentHorizontalAlignment = .leading
        view.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        view.setTitleColor(.gray, for: .normal)
        view.layer.cornerRadius = 9
        return view
    }()
    
    weak var delegate: OpenCreatePostViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGray6
        addSubview(textViewButton)
        textViewButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension PostsTitleView {
    
    @objc func buttonTapped() {
        delegate?.presentCreatePostViewController()
    }
    
    func setupConstraints() {
        textViewButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        textViewButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        textViewButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        textViewButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
    }
}

