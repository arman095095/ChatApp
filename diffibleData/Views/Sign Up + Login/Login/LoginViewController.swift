//
//  File2.swift
//  diffibleData
//
//  Created by Arman Davidoff on 23.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import SwiftUI
import GoogleSignIn

class LoginViewController:UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var loginStack: UIStackView!
    private let helloLabel = UILabel(text: "Мы рады Вас видеть!",font: UIFont.avenir26())
    private let googleButton = LoadButton(title: "Google", backgroundColor: .white, titleColor: .black, shadow: true,google: true,height: 60, activityColor: .black)
    private let googleLabel = UILabel(text: "Выполнить вход с помощью")
    private let loginButton = LoadButton(title: "Login", backgroundColor: .buttonDark(), titleColor: .white,height: 60, activityColor: .white)
    private let orLabel = UILabel(text: "или")
    private let emailTextField = UITextField()
    private let emailLabel = UILabel(text: "Email")
    private let passwordTextField = UITextField()
    private let passwordLabel = UILabel(text: "Пароль")
    private let signInLabel = UILabel(text: "Нет аккаунта?")
    private let signInButton = UIButton(title: "Создать", backgroundColor: .white, titleColor: UIColor.red, font: UIFont.avenir20(), shadow: false, cornerRaduis: 0, google: false)
    
    weak var delegate: AuthDelegate?
    private let loginViewModel: LoginViewModel
    
    init(loginViewModel: LoginViewModel) {
        self.loginViewModel = loginViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupViews()
        setupActions()
        addKeyboardObservers()
        addGesture()
        setupViewModel()
    }
    
    deinit {
        delegate?.updateViewModel()
        NotificationCenter.default.removeObserver(self)
    }
        
    @objc private func googleTapped() {
        googleButton.loading()
        loginViewModel.signInWithGoogle(present: self)
    }
        
    @objc private func signInTapped() {
        dismiss(animated: true) {
            self.delegate?.goToSignInVC()
        }
    }
    
    @objc private func loginTapped() {
        loginButton.loading()
        loginViewModel.login(with: emailTextField.text, password: passwordTextField.text)
    }
}

//MARK: Setup ViewModel
private extension LoginViewController {
    
    func setupViewModel() {
        loginViewModel.failureSignUpHandler = { [weak self] error in
            guard let self = self else { return }
            if let _ = error as? ConnectionError {
                Alert.present(type: .connection)
            } else {
                Alert.present(type: .error,title: error.localizedDescription)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.loginButton.stop()
                self.googleButton.stop()
            }
        }
        
        loginViewModel.successFullLoginHandler = { [weak self] muser in
            guard let self = self else { return }
            Alert.present(type: .success, title: "Вы успешно авторизованы")
            self.googleButton.stop()
            self.loginButton.stop()
            let tabVC = Builder.shared.mainTabBarController(currentUser: muser)
            self.present(tabVC, animated: true, completion: nil)
        }
        
        loginViewModel.successPartLoginHandler = { [weak self] user in
            guard let self = self else { return }
            self.loginButton.stop()
            self.googleButton.stop()
            let setupVC = Builder.shared.firstAddInfoVC(currentUser: user, authManager: self.loginViewModel.authManagers.authManager)
            self.present(setupVC, animated: true, completion: nil)
        }
        
        loginViewModel.removedUserHandler = { [weak self] user, error in
            guard let self = self else { return }
            self.createAlertForRecover(error: error as! GetUserInfoError) {
                self.loginViewModel.recoverProfile(user: user)
            } complitionDeny: {
                self.loginViewModel.cancelRecover()
                self.loginButton.stop()
                self.googleButton.stop()
            }
        }
        loginViewModel.successRecoverHandler = { [weak self] user in
            guard let self = self else { return }
            Alert.present(type: .success, title: "Ваш профиль восстановлен")
            self.loginButton.stop()
            self.googleButton.stop()
            let tabVC = Builder.shared.mainTabBarController(currentUser: user)
            self.present(tabVC, animated: true, completion: nil)
        }
        
        loginViewModel.failureRecoverHandler = { [weak self] error in
            guard let self = self else { return }
            if let _ = error as? ConnectionError {
                Alert.present(type: .connection)
            } else {
                Alert.present(type: .error, title: "Ошибка восстановления профиля")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.loginButton.stop()
                self.googleButton.stop()
            }
        }
    }
}

//MARK: Setup UI
private extension LoginViewController {
    
    func addGesture() {
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboard(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
        scrollView.contentSize = .zero
        if notification.name == UIResponder.keyboardWillShowNotification {
            let contentSize = view.safeAreaLayoutGuide.layoutFrame.height + keyboardHeight
            let offset = helloLabel.frame.maxY + googleButton.frame.maxY
            scrollView.contentOffset.y = offset
            scrollView.contentSize.height = contentSize
        }
    }
    
    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        scrollView.contentSize = .zero
    }
    
    func setupViews() {
        view.backgroundColor = .white
        helloLabel.textAlignment = .center
        helloLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let googleView = UIView(button: googleButton, label: googleLabel, spacing: 12)
        let emailView = UIView(textField: emailTextField, label: emailLabel, spacing: 12)
        let passwordView = UIView(textField: passwordTextField, label: passwordLabel, spacing: 12)
        let signView = UIView(button: signInButton, label: signInLabel)
        
        loginStack = UIStackView(arrangedSubviews: [googleView,orLabel,emailView,passwordView,loginButton], spacing: 15, axis: .vertical)
        
        self.contentView.addSubview(loginStack)
        self.contentView.addSubview(helloLabel)
        self.contentView.addSubview(signView)
        
        helloLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        helloLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor,constant: 20).isActive = true
        
        loginStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40).isActive = true
        loginStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
        loginStack.topAnchor.constraint(greaterThanOrEqualTo: helloLabel.bottomAnchor, constant: 20).isActive = true
        loginStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        loginStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        signView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40).isActive = true
        signView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15).isActive = true
    }
    
    func setupActions() {
        passwordTextField.isSecureTextEntry = true
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleTapped), for: .touchUpInside)
    }
}
