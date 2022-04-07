//
//  PostCreateViewController.swift
//  diffibleData
//
//  Created by Arman Davidoff on 24.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxRelay
import InputBarAccessoryView

class PostCreateViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.contentMode = .scaleToFill
        return view
    }()
    private let removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Cancel"), for: .normal)
        button.tintColor = UIColor.mainApp()
        button.addTarget(self, action: #selector(removeImageTapped), for: .touchUpInside)
        return button
    }()
    private let textView: InputTextView = {
        let inputTextView = InputTextView()
        inputTextView.backgroundColor = .systemBackground
        inputTextView.isScrollEnabled = true
        inputTextView.placeholderTextColor = .gray
        inputTextView.placeholder = "Что у Вас нового?"
        inputTextView.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 21, right: 36)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 14, left: 15, bottom: 14, right: 36)
        inputTextView.layer.borderColor = UIColor.gray.cgColor
        inputTextView.layer.borderWidth = 0.2
        inputTextView.layer.cornerRadius = 18.0
        inputTextView.layer.masksToBounds = true
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        return inputTextView
    }()
    private let scrollView = UIScrollView()
    
    private let activity: CustomActivityIndicator = {
        let view = CustomActivityIndicator()
        view.strokeColor = UIColor.mainApp()
        view.lineWidth = 3.5
        view.bounds.size = CGSize(width: 43, height: 43)
        return view
    }()
    private let postCreateViewModel: PostCreateViewModel
    private var keyboardHeight: CGFloat?
    private let dispose = DisposeBag()
    
    override func viewDidLoad() {
        tabBarController?.tabBar.isHidden = true
        setupNavigationBar()
        setupKeyboardObservers()
        setupViews()
        setupInputViewForTextView()
        setupBinding()
    }
    
    init(postCreateViewModel: PostCreateViewModel) {
        self.postCreateViewModel = postCreateViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textView.becomeFirstResponder()
    }
    
    @objc private func createPostTapped() {
        activity.startLoading()
        activity.isHidden = false
        blockUI()
        scrollView.scrollToBottom(animated: true)
        postCreateViewModel.createPost(text: textView.text!, image: imageView.image)
    }
}

//MARK: ImagePicker
extension PostCreateViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let photo = (info[.originalImage] as! UIImage)

        setupChangedFrames(photoSize: photo.size)
        self.imageView.image = photo
        picker.dismiss(animated: true) {
            self.postCreateViewModel.imageAvailable.accept(true)
            self.postCreateViewModel.imageSize = photo.size
            self.reloadViews()
        }
    }
    
    private func reloadViews() {
        scrollView.contentSize.height = imageView.frame.height + 5 + textView.frame.height + (keyboardHeight ?? 0)
        self.scrollView.scrollToBottom(animated: true)
    }
    
    private func setupStartFrames() {
        imageView.image = nil
        scrollView.frame = view.bounds
        imageView.frame = .zero
        textView.frame = view.bounds
        textView.frame.size.height = keyboardHeight == nil ? view.bounds.height : view.bounds.height - keyboardHeight! - topBarHeight
        removeButton.frame = .zero
        scrollView.contentSize = .zero
        activity.frame.origin.y = view.frame.maxY - activity.bounds.height - topBarHeight - (keyboardHeight ?? 0)
        activity.frame.origin.x = view.center.x - activity.bounds.width/2
    }
    
    private func setupChangedFrames(photoSize: CGSize) {
        scrollView.contentOffset.y = 0
        if photoSize.height > photoSize.width && photoSize.height > view.bounds.height - (keyboardHeight ?? 0) - topBarHeight {
            let height = view.bounds.height - (keyboardHeight ?? 0) - topBarHeight
            let ratio = photoSize.height/height
            let width = photoSize.width/ratio
            self.imageView.frame = CGRect(x: view.frame.midX - width/2, y: 0, width: width, height: height)
        } else {
            let ratio = photoSize.width/view.bounds.width
            let height = photoSize.height/ratio
            self.imageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: height)
        }
        textView.frame = CGRect(x: 0, y: imageView.frame.maxY + 5, width: view.bounds.width, height: 130)
        removeButton.frame = CGRect(x: imageView.frame.width - 46, y: 10, width: 36, height: 36)
        activity.frame.origin.y = imageView.frame.maxY
        activity.frame.origin.x = view.center.x - activity.bounds.width/2
    }
    
    @objc private func chooseImageTapped() {
        ImagePicker.present(viewController: self)
    }
}

//MARK: Setup UI
private extension PostCreateViewController {
    
    func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        let sendButton = UIBarButtonItem(image: UIImage(named: "sent"), style: .done, target: self, action: #selector(createPostTapped))
        let template = sendButton.image?.withRenderingMode(.alwaysTemplate)
        sendButton.image = template
        sendButton.tintColor = UIColor.mainApp()
        navigationItem.setRightBarButton(sendButton, animated: true)
    }
    
    func setupInputViewForTextView() {
        let button = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(chooseImageTapped))
        button.tintColor = UIColor.mainApp()
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.setItems([button], animated: false)
        textView.inputAccessoryView = toolBar
    }
    
    func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(textView)
        imageView.addSubview(removeButton)
        scrollView.addSubview(activity)
        setupStartFrames()
    }
    
    func blockUI() {
        textView.isEditable = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        removeButton.isEnabled = false
    }
    
    func unlockUI() {
        activity.completeLoading(success: true)
        activity.isHidden = true
        textView.isEditable = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        removeButton.isEnabled = true
        textView.becomeFirstResponder()
    }
    
    @objc func removeImageTapped() {
        postCreateViewModel.imageAvailable.accept(false)
        setupStartFrames()
    }
}

//MARK: Keyboard
private extension PostCreateViewController {
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard),name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    @objc func keyboard(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
        if notification.name == UIResponder.keyboardDidShowNotification {
            if self.keyboardHeight == nil {
                self.keyboardHeight = keyboardHeight
                self.setupStartFrames()
            }
        }
    }
}

//MARK: Setup Binding
private extension PostCreateViewController {
    
    func setupBinding() {
        postCreateViewModel.sendingAvailable.asDriver().drive(navigationItem.rightBarButtonItem!.rx.isEnabled).disposed(by: dispose)
        
        textView.rx.text.orEmpty.asDriver().drive(onNext: { [weak self] text in
            self?.postCreateViewModel.textAvailable.accept(!(text.isEmpty || text == ""))
        }).disposed(by: dispose)
        
        postCreateViewModel.sendingSuccess.asDriver().drive(onNext: { [weak self] success in
            if let success = success {
                if success {
                    Alert.present(type: .success, title: "Пост опубликован")
                    self?.navigationController?.popViewController(animated: true)
                }
                else {
                    self?.unlockUI()
                    Alert.present(type: .error, title: "Не удалось опубликовать пост")
                }
            }
        }).disposed(by: dispose)
        
        postCreateViewModel.sendingError.asDriver().drive(onNext: { error in
            if let error = error {
                if let _ = error as? ConnectionError {
                    Alert.present(type: .connection)
                } else {
                    Alert.present(type: .error,title: error.localizedDescription)
                }
            }
        }).disposed(by: dispose)
    }
}


