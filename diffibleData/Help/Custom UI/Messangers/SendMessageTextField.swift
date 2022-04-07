//
//  CustomTextField.swift
//  diffibleData
//
//  Created by Arman Davidoff on 25.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import SwiftUI
import RxSwift
import RxCocoa
import RxRelay
    
class SendMessageTextField: UITextField {
    
    var sendButton: UIButton!
    private let dispose = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        costomize()
        setupBinding()
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
       
        rect.origin.x += -12
        return rect
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += 12
        return rect
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 36, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 36, dy: 0)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 36, dy: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rightView?.addGradientInView(cornerRadius: (rightView?.layer.frame.height)!/2)
    }
}

private extension SendMessageTextField {
    
    func setupBinding() {
        self.rx.text.orEmpty.asDriver().drive(onNext: { [weak self] text in
            self?.sendButton.isEnabled = !(text == "" || text.isEmpty)
        }).disposed(by: dispose)
    }
    
    func costomize() {
        backgroundColor = .white
        placeholder = "Write something..."
        font = UIFont.systemFont(ofSize: 14)
        borderStyle = .none
        layer.cornerRadius = 18
        layer.masksToBounds = true
        
        let smileImage = UIImage(systemName: "smiley")
        let smileImageView = UIImageView(image: smileImage)
        smileImageView.setupForSystemImageColor(color: .gray)
        leftView = smileImageView
        leftViewMode = .always
        
        let sendImage = UIImage(named: "sender")
        sendButton = UIButton(type: .system)
        sendButton.isEnabled = false
        sendButton.setImage(sendImage, for: .normal)
        
        sendButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 3, bottom: 2, right: 2)
        sendButton.heightAnchor.constraint(equalToConstant: 27).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 27).isActive = true
        
        sendButton.setupForSystemImageColor(color: .white)
        rightView = sendButton
        rightViewMode = .always
    }
}

