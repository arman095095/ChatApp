//
//  MPost + CellModel.swift
//  diffibleData
//
//  Created by Arman Davidoff on 21.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit

//MARK: PostCellModelType
extension MPost: PostCellModelType {
    
    var currentUserOwnerButtonWidth: CGFloat {
        if currentUserOwner {
            return PostCellConstants.menuButtonHeight
        }
        return 0
    }
    
    var userName: String {
        owner!.userName
    }
    
    var liked: Bool {
        return likedByMe
    }
    
    var likesCount: String {
        return PostCellConstants.setupCountableItemPresentation(countOf: likersIds.count)
    }
    
    var likesCountAfterLike: String {
        let newLikesCount = liked ? likersIds.count - 1 : likersIds.count + 1
        return PostCellConstants.setupCountableItemPresentation(countOf: newLikesCount)
    }
    
    var postDate: String {
        return DateFormatManager().convertDate(from: date)
    }
    
    var userImageURL: URL? {
        URL(string: owner!.imageUrl)
    }
    
    var postImageURL: URL? {
        if let url = urlImage {
            return URL(string: url)
        }
        return nil
    }
    
    var textContentFrame: CGRect {
        if showedFullText { return realFrames?.textContentFrame ?? .zero }
        return frames?.textContentFrame ?? .zero
    }
    
    var postImageFrame: CGRect {
        if showedFullText { return realFrames?.postImageFrame ?? .zero }
        return frames?.postImageFrame ?? .zero
    }
    
    var height: CGFloat {
        if showedFullText { return realFrames?.height ?? 0 }
        return frames?.height ?? 0
    }
    
    var buttonFrame: CGRect {
        if showedFullText { return .zero }
        return frames?.buttonFrame ?? .zero
    }
    
    var online: Bool {
        return owner!.online
    }
}
