//
//  StartChat.swift
//  diffibleData
//
//  Created by Arman Davidoff on 24.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import SwiftUI
import SDWebImage
import RxCocoa
import RxSwift
import RxRelay

protocol ProfileViewDelegate: AnyObject {
    func update()
}

class ProfileViewController: UIViewController {
    
    weak var delegate: ProfileViewDelegate?
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "settings2"), for: .normal)
        button.tintColor = UIColor.mainApp()
        return button
    }()
    private let menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "menu2"), for: .normal)
        button.tintColor = UIColor.mainApp()
        return button
    }()
    private let imageView: UIImageView = {
        let view =  UIImageView()
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 30
        view.backgroundColor = .systemGray6
        return view
    }()
    private let nameLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = UIFont.avenir24()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let userInfoLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.avenir17()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let countryCityLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.avenir20()
        view.numberOfLines = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let messageTextField = SendMessageTextField()
    private let buttonsView = ButtonsView(firstButtonTitle: "Посты", secondButtonTitle: "Показать")
    private let profileViewModel: ProfileViewModel
    private var constreint: NSLayoutConstraint!
    private let dispose = DisposeBag()
    
    init(profileViewModel: ProfileViewModel) {
        self.profileViewModel = profileViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        delegate?.update()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        setupViews()
        setupNavigationBar()
        setupConstraints()
        addKeyboardObservers()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = profileViewModel.tabBarHidden
        profileViewModel.updateProfileInfo()
    }
    
    
    @objc func sendMessege() {
        messageTextField.sendButton.isEnabled = false
        profileViewModel.sendMessage(messageText: messageTextField.text)
    }
    
    private func config() {
        navigationItem.title = profileViewModel.title
        imageView.sd_setImage(with: profileViewModel.imageURL, completed: nil)
        nameLabel.text = profileViewModel.name
        countryCityLabel.text = profileViewModel.countryCity
        userInfoLabel.text = profileViewModel.info
        buttonsView.setupCount(count: profileViewModel.postsCount)
        messageTextField.sendButton.isHidden = !profileViewModel.allowedWrite
        messageTextField.isEnabled = profileViewModel.allowedWrite
        messageTextField.placeholder = profileViewModel.placeholder
    }
}

//MARK: Setup Binding
private extension ProfileViewController {
    
    func setupBinding() {
        profileViewModel.updatedUser.asDriver().drive(onNext: { [weak self] update in
            if update { self?.config() }
        }).disposed(by: dispose)
        
        profileViewModel.successBlocking.asDriver().drive(onNext: { [weak self] success in
            guard let self = self else { return }
            if success {
                Alert.present(type: .success, title: self.profileViewModel.titleForBlockingResult)
            }
        }).disposed(by: dispose)
        
        profileViewModel.iamBlocked.asDriver().drive(onNext: { [weak self] blocked in
            guard let blocked = blocked else { return }
            self?.messageTextField.text = ""
            if blocked {
                Alert.present(type: .error, title: "Пользователь Вас заблокировал")
            } else {
                Alert.present(type: .success, title: "Сообщение отправлено")
            }
        }).disposed(by: dispose)
        
        profileViewModel.sendingError.asDriver().drive(onNext: { [weak self] error in
            if let error = error {
                self?.messageTextField.sendButton.isEnabled = true
                if let _ = error as? ConnectionError {
                    Alert.present(type: .connection)
                } else {
                    Alert.present(type: .error,title: error.localizedDescription)
                }
            }
        }).disposed(by: dispose)
    }
}


//MARK: Setup UI
private extension ProfileViewController {
    
    func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = .systemGray6
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setupViews() {
        view.backgroundColor = .systemGray6
        self.view.addSubview(imageView)
        self.view.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(countryCityLabel)
        containerView.addSubview(userInfoLabel)
        containerView.addSubview(messageTextField)
        containerView.addSubview(buttonsView)
        containerView.addSubview(settingsButton)
        containerView.addSubview(menuButton)
        
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupConstraints() {
        
        imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        constreint = containerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        constreint.isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 30).isActive = true
        nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor,constant: 30).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: settingsButton.leadingAnchor,constant: -20).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: nameLabel.font.lineHeight).isActive = true
        
        menuButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        menuButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -30).isActive = true
        
        settingsButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        settingsButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -30).isActive = true
        
        countryCityLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 30).isActive = true
        countryCityLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,constant: 15).isActive = true
        countryCityLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -30).isActive = true
        countryCityLabel.heightAnchor.constraint(equalToConstant: countryCityLabel.font.lineHeight).isActive = true
        
        userInfoLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 30).isActive = true
        userInfoLabel.topAnchor.constraint(equalTo: countryCityLabel.bottomAnchor,constant: 15).isActive = true
        userInfoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -30).isActive = true
        //userInfoLabel.heightAnchor.constraint(equalToConstant: userInfoLabel.font.lineHeight).isActive = true
        
        buttonsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 30).isActive = true
        buttonsView.topAnchor.constraint(equalTo: userInfoLabel.bottomAnchor,constant: 20).isActive = true
        buttonsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -30).isActive = true
        buttonsView.heightAnchor.constraint(equalToConstant: PostCellConstants.buttonFont.lineHeight).isActive = true
        
        messageTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -30).isActive = true
        messageTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 30).isActive = true
        messageTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,constant: -28).isActive = true
        
        if profileViewModel.yourProfile {
            constreintsForYourProfile()
        } else {
            constreintsForFriendProfile()
        }
        imageView.bottomAnchor.constraint(equalTo: self.containerView.topAnchor,constant: 100).isActive = true
    }
    
    func constreintsForYourProfile() {
        menuButton.heightAnchor.constraint(equalToConstant: 0).isActive = true
        menuButton.widthAnchor.constraint(equalToConstant: 0).isActive = true
        messageTextField.heightAnchor.constraint(equalToConstant: 0).isActive = true
        settingsButton.heightAnchor.constraint(equalToConstant: 28).isActive = true
        settingsButton.widthAnchor.constraint(equalToConstant: 28).isActive = true
        buttonsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,constant: -28).isActive = true
    }
    
    func constreintsForFriendProfile() {
        messageTextField.topAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: 20).isActive = true
        messageTextField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        settingsButton.heightAnchor.constraint(equalToConstant: 0).isActive = true
        settingsButton.widthAnchor.constraint(equalToConstant: 0).isActive = true
        menuButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        menuButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    func setupActions() {
        buttonsView.firstButton.addTarget(self, action: #selector(showPostsTapped), for: .touchUpInside)
        buttonsView.secondButton.addTarget(self, action: #selector(showPostsTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(setupProfileTapped), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(menuOpenTapped), for: .touchUpInside)
        if let sendButton = messageTextField.rightView as? UIButton {
            sendButton.addTarget(self, action: #selector(sendMessege), for: .touchUpInside)
        }
    }
}

//MARK: Actions
private extension ProfileViewController {
    
    @objc func menuOpenTapped() {
        let title = profileViewModel.titleForBlocking
        let alert = UIAlertController(title: profileViewModel.name, message: "Вы уверены, что хотите \(title.lowercased()) пользователя?", preferredStyle: .actionSheet)
        let blockAction = UIAlertAction(title: title, style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            self.profileViewModel.blockingAction()
        })
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil )
        alert.addAction(blockAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func setupProfileTapped() {
        let vc = Builder.shared.settingsVC(currentUser: profileViewModel.userCurrent, managers: profileViewModel.managers)
        if let navigationController = navigationController {
            navigationController.pushViewController(vc, animated: true)
        } else {
            let nc = UINavigationController(rootViewController: vc)
            present(nc, animated: true, completion: nil)
        }
    }
    
    @objc func showPostsTapped() {
        let vc = Builder.shared.userPostsVC(filter: profileViewModel.user, managers: profileViewModel.managers)
        if navigationController == nil {
            let nc = UINavigationController(rootViewController: vc)
            self.present(nc, animated: true, completion: nil)
        } else {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: Keyboard
private extension ProfileViewController {
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboard(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
        if notification.name == UIResponder.keyboardWillShowNotification {
            constreint.constant -= keyboardHeight - 25 - view.safeAreaInsets.bottom
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else if notification.name == UIResponder.keyboardWillHideNotification {
            constreint.constant = 0
            view.layoutIfNeeded()
        } else { return }
    }
}
