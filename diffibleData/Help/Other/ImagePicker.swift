//
//  ImagePicker.swift
//  diffibleData
//
//  Created by Arman Davidoff on 27.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit

class ImagePicker { //Создает Alert из камеры,галереи и отмены
    
    static func present(viewController: UIViewController & UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = viewController
        imagePicker.allowsEditing = true
        
        let alertImageSet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Камера", style: .default, handler: { _ in
            imagePicker.sourceType = .camera
            viewController.present(imagePicker, animated: true, completion: nil)
        })
        let galaryAction = UIAlertAction(title: "Фотографии", style: .default, handler: { _ in
            imagePicker.sourceType = .photoLibrary
            viewController.present(imagePicker, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertImageSet.addAction(cameraAction)
        alertImageSet.addAction(galaryAction)
        alertImageSet.addAction(cancelAction)
        viewController.present(alertImageSet, animated: true, completion: nil)
    }
}
