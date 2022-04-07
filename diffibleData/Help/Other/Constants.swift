
//
//  Constants.swift
//  diffibleData
//
//  Created by Arman Davidoff on 25.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit

struct PostCellConstants {
    static let userImageHeight: CGFloat = 47
    
    static let cardViewBottonInset: CGFloat = 11
    static let cardViewSideInset : CGFloat = 12
    
    static let heightTopView: CGFloat = 63
    
    static var postsTextFont: UIFont {
        return UIFont.systemFont(ofSize: 15)
    }
    static var buttonFont: UIFont {
        return UIFont.systemFont(ofSize: 15, weight: .medium)
    }
    
    static let contentInset : CGFloat = 11
    static var topBarHeight: CGFloat?
    static var bottonBarHeight: CGFloat?
    static let titleViewHeight: CGFloat = 60
    static let menuButtonHeight: CGFloat = 22
    
    static let imageAndTextInset: CGFloat = 4
    static let heightButtonView: CGFloat = 43
    
    static var totalHeight: CGFloat {
        return UIScreen.main.bounds.height - heightButtonView - heightTopView - titleViewHeight - imageAndTextInset - cardViewBottonInset - (bottonBarHeight ?? 0) - (topBarHeight ?? 0)
    }
    
    static var maxLines: Int {
        return 5
    }
    
    static var maxTextHeight: CGFloat {
        return CGFloat(maxLines) * postsTextFont.lineHeight
    }
    
    static var textWidth: CGFloat {
        return UIScreen.main.bounds.width - 2*cardViewSideInset - 2*contentInset
    }
    
    static let buttonWidth = "показать полностью...".width(font: buttonFont)
    
    static func setupCountableItemPresentation(countOf: Int?) -> String {
        guard let count = countOf else { return "" }
        if count == 0 { return "" }
        
        let countDouble = Double(count)
        if count > 999 && count < 1000000 {
            let str = String(format: "%.1f", countDouble/1000)
            if str.last != "0" {
                return String(format: "%.1f", countDouble/1000) + "K" }
            else {
                return "\(Int(countDouble/1000))" + "K"
            }
        }
        else if count >= 1000000 {
            let str = String(format: "%.1f", countDouble/1000000)
            if str.last != "0" {
                return String(format: "%.1f", countDouble/1000000) + "M" }
            else {
                return "\(Int(countDouble/1000000))" + "M"
            }
        } else {
            return "\(count)"
        }
    }
}

struct ChatsConstants {
    static var badgeTextFont: UIFont {
        return UIFont.systemFont(ofSize: 17)
    }
    static let badgeHeight: CGFloat = 20
    static let badgeInset: CGFloat = 10
    static let activeChatHeight: CGFloat = 75
    static let waitingChatHeight: CGFloat = 65
    static let imageChatHeight: CGFloat = 65
}

struct BlackListConstants {
    static let heightRow: CGFloat = 50
    static let heightImageView: CGFloat = 40
}

struct LimitsConstants {
    static let posts = 20
    static let users = 15
    static let messages = 35
}

