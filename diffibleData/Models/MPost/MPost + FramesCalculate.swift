//
//  MPost + FramesCalculate.swift
//  diffibleData
//
//  Created by Arman Davidoff on 25.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit

//MARK: Posts size calculator
extension MPost {
    
    struct Frames {
        
        var textContentFrame: CGRect
        
        var postImageFrame: CGRect
        
        var buttonFrame: CGRect
        
        var height: CGFloat
    }
    
    func framesCalculate() {
        let textHeightAndButtonFrame = getTextHeightWithButtonFrame()
        let textHeight = textHeightAndButtonFrame.0
        let buttonFrame = textHeightAndButtonFrame.1
        
        let textContentFrame = CGRect(x: PostCellConstants.contentInset, y: PostCellConstants.heightTopView, width: PostCellConstants.textWidth, height: textHeight)
        
        let postImageSize = getPostImageSize(from: imageSize, textHeight: textHeight, buttonHeight: buttonFrame.height)
        let postImageOriginX = getPostImageOriginX(from: postImageSize)
        let postImageOriginY = getPostImageOriginY(textHeight: textHeight, buttonHeight: buttonFrame.height)
        let postImageFrame = CGRect(x: postImageOriginX, y: postImageOriginY, width: postImageSize.width, height: postImageSize.height)
        
        let postHeight = PostCellConstants.heightTopView + textHeight + postImageSize.height + PostCellConstants.cardViewBottonInset + buttonFrame.height + PostCellConstants.heightButtonView
        let frames = MPost.Frames(textContentFrame: textContentFrame, postImageFrame: postImageFrame, buttonFrame: buttonFrame, height: postHeight)
        
        if buttonFrame != .zero {
            let realTextHeight = textContent.height(width: PostCellConstants.textWidth, font: PostCellConstants.postsTextFont)
            let realTextContentFrame = CGRect(x: PostCellConstants.contentInset, y: PostCellConstants.heightTopView, width: PostCellConstants.textWidth, height: realTextHeight)
            let realPostImageOriginY = getPostImageOriginY(textHeight: realTextHeight, buttonHeight: 0)
            let realPostImageFrame = CGRect(x: postImageOriginX, y: realPostImageOriginY, width: postImageSize.width, height: postImageSize.height)
            let realPostHeight = PostCellConstants.heightTopView + realTextHeight + postImageSize.height + PostCellConstants.cardViewBottonInset + PostCellConstants.heightButtonView
            let realFrames = MPost.Frames(textContentFrame: realTextContentFrame, postImageFrame: realPostImageFrame, buttonFrame: .zero, height: realPostHeight)
            self.realFrames = realFrames
        }
        self.frames = frames
    }
}

//MARK: Help Calculate
private extension MPost {
    
    func getTextHeightWithButtonFrame() -> (CGFloat,CGRect) {
        if textContent == "" {
            return (0,.zero)
        }
        let height = textContent.height(width: PostCellConstants.textWidth, font: PostCellConstants.postsTextFont)
        if height > PostCellConstants.maxTextHeight {
            let y = PostCellConstants.heightTopView + PostCellConstants.maxTextHeight
            return (PostCellConstants.maxTextHeight,CGRect(x: PostCellConstants.contentInset, y: y, width: PostCellConstants.buttonWidth, height: PostCellConstants.buttonFont.lineHeight))
        }
        return (height,.zero)
    }
    
    
    func getPostImageSize(from size: CGSize?, textHeight: CGFloat, buttonHeight: CGFloat) -> CGSize {
        let size = calculateFirstImageSize(from: size)
        let totalHeight = PostCellConstants.totalHeight - textHeight - buttonHeight
        if size.height > totalHeight  {
            let height = totalHeight
            let ratio = size.height/height
            let width = size.width/ratio
            return CGSize(width: width, height: height)
        } else {
            return size
        }
    }
    
    func calculateFirstImageSize(from size: CGSize?) -> CGSize {
        guard let size = size else { return .zero }
        if size.width > UIScreen.main.bounds.width - 2*PostCellConstants.cardViewSideInset {
            let width = UIScreen.main.bounds.width - 2*PostCellConstants.cardViewSideInset
            let ratio = size.width / width
            let height = size.height / ratio
            return CGSize(width: width, height: height)
        } else {
            return size
        }
    }
    
    func getPostImageOriginX(from size: CGSize) -> CGFloat {
        if size.width < UIScreen.main.bounds.width - 2*PostCellConstants.cardViewSideInset {
            return (UIScreen.main.bounds.width - size.width - 2*PostCellConstants.cardViewSideInset)/2
        } else {
            return 0
        }
    }
    
    func getPostImageOriginY(textHeight: CGFloat, buttonHeight: CGFloat) -> CGFloat {
        return PostCellConstants.heightTopView + textHeight + buttonHeight + PostCellConstants.imageAndTextInset
    }
}
