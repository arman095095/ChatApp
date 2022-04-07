//
//  File3.swift
//  diffibleData
//
//  Created by Arman Davidoff on 23.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import SwiftUI

class SignUpViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var signUpStack: UIStackView!
    private let helloLabel = UILabel(text: "Добро пожаловать!", font: UIFont.avenir26())
    private let signUpButton = LoadButton(title: "Зарегистрироваться", backgroundColor: .buttonDark(), titleColor: .white,height: 60, activityColor: .white)
    private let emailTextField = UITextField()
    private let emailLabel = UILabel(text: "Email")
    private let passwordTextField = UITextField()
    private let passwordLabel = UILabel(text: "Пароль")
    private let confirmPasswordTextField = UITextField()
    private let confirmPasswordLabel = UILabel(text: "Подтверждение пароля")
    private let loginLabel = UILabel(text: "Есть аккаунт?")
    private let loginButton = UIButton(title: "Login", backgroundColor: .white, titleColor: UIColor.red, font: UIFont.avenir20(), shadow: false, cornerRaduis: 0, google: false)
    
    weak var delegate: AuthDelegate?
    private let signInViewModel: SignUpViewModel
    
    init(signInViewModel: SignUpViewModel) {
        self.signInViewModel = signInViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupScrollView()
        setupViews()
        setupActions()
        addKeyboardObservers()
        addGesture()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func loginTapped() {
        dismiss(animated: true) {
            self.delegate?.goToLoginVC()
        }
    }
    
    @objc private func registerTapped() {
        signUpButton.loading()
        signInViewModel.register(email: emailTextField.text, password: passwordTextField.text, confirmPassword: confirmPasswordTextField.text)
    }
}

//MARK: Setup ViewModel
private extension SignUpViewController {
    
    func setupViewModel() {
        signInViewModel.successSignUpHandler = { [weak self] user in
            guard let self = self else { return }
            Alert.present(type: .success, title: "Вы успешно зарегистрировались")
            self.signUpButton.stop()
            let setupVC = Builder.shared.firstAddInfoVC(currentUser: user, authManager: self.signInViewModel.authManagers.authManager)
            self.present(setupVC, animated: true, completion: nil)
        }
        
        signInViewModel.failureSignUpHandler = { [weak self] error in
            guard let self = self else { return }
            
            if let _ = error as? ConnectionError {
                Alert.present(type: .connection)
            } else {
                Alert.present(type: .error,title: error.localizedDescription)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.signUpButton.stop()
            }
        }
    }
}

//MARK: Setup UI
private extension SignUpViewController {
    
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
            let offset = signUpStack.frame.minY + helloLabel.frame.maxY
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
        contentView.backgroundColor = .white
        scrollView.backgroundColor = .white
        helloLabel.textAlignment = .center
        helloLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let emailView = UIView(textField: emailTextField, label: emailLabel, spacing: 12)
        let passwordView = UIView(textField: passwordTextField, label: passwordLabel, spacing: 12)
        let confirmPasswordView = UIView(textField: confirmPasswordTextField, label: confirmPasswordLabel, spacing: 12)
        let loginView = UIView(button: loginButton, label: loginLabel)
        signUpStack = UIStackView(arrangedSubviews: [helloLabel,emailView,passwordView,confirmPasswordView,signUpButton], spacing: 25, axis: .vertical)
        
        self.contentView.addSubview(signUpStack)
        self.contentView.addSubview(loginView)
        
        signUpStack.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 20).isActive = true
        signUpStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        signUpStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        signUpStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40).isActive = true
        signUpStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
        
        loginView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40).isActive = true
        loginView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15).isActive = true
    }
    
    func setupActions() {
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        signUpButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }
}
