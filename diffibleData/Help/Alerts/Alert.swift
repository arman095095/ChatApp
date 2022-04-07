//
//  Alert.swift
//  CustomAlerts
//
//  Created by Arman Davidoff on 21.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import SwiftEntryKit

class Alert {
    
    enum InfoType {
        case success
        case error
        case connection
    }
    
    static func present(type: InfoType, title: String = "") {
        if type == .connection {
            SwiftEntryKit.display(entry: InfoAlertView(title: "Отсутствует соединение с интернетом", type: type), using: attributes(type: type))
        } else{
            SwiftEntryKit.display(entry: InfoAlertView(title: title, type: type), using: attributes(type: type))
        }
    }
}

private extension Alert {
    
    static func attributes(type: InfoType) -> EKAttributes {
        
        var attributes = EKAttributes.statusBar // позиция размещения
        attributes.screenBackground = .clear
        attributes.entryInteraction = .absorbTouches // действие при касании на окно
        attributes.screenInteraction = .forward
        switch type {
        case .success:
            attributes.displayDuration = 1.5 //показ окна время
            attributes.entryBackground = .color(color: .init(#colorLiteral(red: 0, green: 0.4910250306, blue: 0, alpha: 1))) //фон алерта
        case .error:
            attributes.displayDuration = 1.5 //показ окна время
            attributes.entryBackground = .color(color: .init(.systemRed)) //фон алерта
        case .connection:
            attributes.displayDuration = 2
            attributes.entryBackground = .color(color: .init(.systemRed))
        }
        
        attributes.roundCorners = .all(radius: 25)
        attributes.shadow = .active(
            with: .init(
                color: .black,
                opacity: 0.3,
                radius: 8
            )
        ) // тени
        
        attributes.scroll = .enabled(
            swipeable: true,
            pullbackAnimation: .jolt
        ) //анимация если играться с окном
        
        attributes.entranceAnimation = .init(
            translate: .init(
                duration: 0.7,
                spring: .init(damping: 1, initialVelocity: 0)
            ),
            scale: .init(
                from: 1.05,
                to: 1,
                duration: 0.4,
                spring: .init(damping: 1, initialVelocity: 0)
            )
        ) //настройки анимации появления
        
        attributes.exitAnimation = .init(
            translate: .init(duration: 0.2)
        )
        attributes.popBehavior = .animated(
            animation: .init(
                translate: .init(duration: 0.2)
            )
        ) //настройки анимации ухода
        
        attributes.positionConstraints.verticalOffset = 40
        attributes.statusBar = .dark
        return attributes
    }
    
    class InfoAlertView: UIView {
        
        private var type: Alert.InfoType
        private var imageView: UIImageView = {
            let view = UIImageView()
            view.tintColor = .white
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        private let titleLabel: UILabel = {
            let view = UILabel()
            view.numberOfLines = 0
            view.translatesAutoresizingMaskIntoConstraints = false
            view.font = .systemFont(ofSize: 15, weight: .medium)
            view.textColor = .white
            return view
        }()
        
        init(title: String, type: Alert.InfoType) {
            self.type = type
            self.titleLabel.text = title
            super.init(frame: UIScreen.main.bounds)
            switch type {
            case .success:
                imageView.image = UIImage(systemName: "checkmark.shield.fill")
            case .error:
                imageView.image = UIImage(systemName: "xmark.shield.fill")
            case .connection:
                imageView.image = UIImage(systemName: "wifi.slash")
            }
            addSubview(titleLabel)
            addSubview(imageView)
            setupConstreints()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupConstreints() {
            layer.masksToBounds = true
            translatesAutoresizingMaskIntoConstraints = false
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 13).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8).isActive = true
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
            
            heightAnchor.constraint(equalToConstant: 70).isActive = true
            widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 20).isActive = true
        }
    }
}
