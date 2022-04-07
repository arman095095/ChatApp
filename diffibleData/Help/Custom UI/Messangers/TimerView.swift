//
//  TimerView.swift
//  diffibleData
//
//  Created by Arman Davidoff on 07.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit

class TimerView: UIView {
    
    private let label = UILabel()
    private let recordImageView = UIImageView()
    private let basketImageView = UIImageView()
    private var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstreints()
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAlpha(alpha: CGFloat) {
        basketImageView.alpha = alpha
        label.alpha = 1 - alpha
    }
    
    func begin() {
        timer?.invalidate()
        timer = nil
        label.alpha = 1
        basketImageView.alpha = 0
        let startDate = Date()
        recordImageView.layer.add(opacity(), forKey: "animateOpacity")
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] (timer) in
            self?.label.text = DateFormatManager().getTimerString(timeInterval:         timer.fireDate.timeIntervalSince(startDate))
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        recordImageView.layer.removeAnimation(forKey: "animateOpacity")
    }
}

private extension TimerView {
    
    func opacity() -> CABasicAnimation {
        let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 1
        pulseAnimation.toValue = 0.3
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        return pulseAnimation
    }
    
    func setupSubviews() {
        recordImageView.image = UIImage(named: "recordImage")
        basketImageView.image = UIImage(named: "delete1")
        basketImageView.setupForSystemImageColor(color: .systemRed)
        label.text = "00:00.00"
        label.font = UIFont.systemFont(ofSize: 15)
        self.addSubview(label)
        self.addSubview(recordImageView)
        self.addSubview(basketImageView)
        basketImageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        recordImageView.translatesAutoresizingMaskIntoConstraints = false
        basketImageView.alpha = 0
    }
    
    func setupConstreints() {
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        basketImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        basketImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        basketImageView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        basketImageView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        recordImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        recordImageView.leadingAnchor.constraint(equalTo: basketImageView.trailingAnchor,constant: 10).isActive = true
        recordImageView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        recordImageView.widthAnchor.constraint(equalToConstant: 10).isActive = true
        label.leadingAnchor.constraint(equalTo: recordImageView.trailingAnchor, constant: 10).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
