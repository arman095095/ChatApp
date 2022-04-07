//
//  UIDevice + Extension.swift
//  diffibleData
//
//  Created by Arman Davidoff on 07.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import AudioToolbox

extension UIDevice {
    
    func vibrate() {
        let feedbackSupportLevel = UIDevice.current.value(forKey: "_feedbackSupportLevel") as? Int
        if #available(iOS 10.0, *), let feedbackSupportLevel = feedbackSupportLevel, feedbackSupportLevel > 1 {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        } else {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}
