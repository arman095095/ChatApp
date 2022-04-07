//
//  File.swift
//  diffibleData
//
//  Created by Arman Davidoff on 23.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit

extension UIFont {
    static func getAll() -> [String] {
        return familyNames
    }
}

class MainAuthViewConroller: UIViewController {
  
    private let googleLabel = UILabel(text: "Выполнить вход с помощью")
    private let emailLabel = UILabel(text: "Зарегистрироваться")
    private let loginLabel = UILabel(text: "Уже зарегистрировались?")
    private let googleButton = LoadButton(title: "Google", backgroundColor: .white, titleColor: .black, shadow: true,google: true, height: 60, activityColor: .black)
    private let emailButton = UIButton(title: "E-mail", backgroundColor: .buttonDark(), titleColor: .white, height: 60)
    private let loginButton = UIButton(title: "Login", backgroundColor: .white, titleColor: .buttonRed(), shadow: true, height: 60)
    private let logo = UIImageView(image: UIImage(named: "logotip"))
    
    private let mainAuthViewModel: MainAuthViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
    }
    
    init(mainAuthViewModel: MainAuthViewModel) {
        self.mainAuthViewModel = mainAuthViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupViewModel()
    }
    
    @objc private func googleTapped() {
        googleButton.loading()
        mainAuthViewModel.signInWithGoogle(present: self)
    }
    
    @objc private func emailTapped() {
        let signInVC = Builder.shared.signUpVC(delegate: self, authManagers: mainAuthViewModel.authManagers)
        present(signInVC, animated: true, completion: nil)
    }
    
    @objc private func loginTapped() {
        let loginVC = Builder.shared.loginVC(delegate: self, authManagers: mainAuthViewModel.authManagers)
        present(loginVC, animated: true, completion: nil)
    }
}

//MARK: Setup UI
private extension MainAuthViewConroller {
    
    func setupViews() {
        self.view.backgroundColor = .white
        logo.contentMode = .scaleAspectFit
        logo.translatesAutoresizingMaskIntoConstraints = false
        let googleView = UIView(button: googleButton , label: googleLabel, spacing: 20)
        let emailView = UIView(button: emailButton , label: emailLabel, spacing: 20)
        let loginView = UIView(button: loginButton, label: loginLabel, spacing: 20)
        let authStackView = UIStackView(arrangedSubviews: [logo,googleView,emailView,loginView],spacing: 40,axis: .vertical)
        view.addSubview(authStackView)
        authStackView.topAnchor.constraint(greaterThanOrEqualTo: self.view.topAnchor,constant: 15).isActive = true
        authStackView.bottomAnchor.constraint(lessThanOrEqualTo: self.view.bottomAnchor,constant: -15).isActive = true
        authStackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        authStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        authStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40).isActive = true
        authStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40).isActive = true
    }
    
    func setupActions() {
        emailButton.addTarget(self, action: #selector(emailTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleTapped), for: .touchUpInside)
    }
}

//MARK: Setup ViewModel
private extension MainAuthViewConroller {
    
    func setupViewModel() {
        mainAuthViewModel.successLoginHandler = { [weak self] muser in
            guard let self = self else { return }
            self.googleButton.stop()
            Alert.present(type: .success, title: "Вы успешно авторизованы")
            let tabVC = Builder.shared.mainTabBarController(currentUser: muser)
            self.present(tabVC, animated: true, completion: nil)
        }
        
        mainAuthViewModel.successSignUpHandler = { [weak self] user in
            guard let self = self else { return }
            self.googleButton.stop()
            Alert.present(type: .success, title: "Вы успешно зарегистрированы")
            let setupVC = Builder.shared.firstAddInfoVC(currentUser: user, authManager: self.mainAuthViewModel.authManagers.authManager)
            self.present(setupVC, animated: true, completion: nil)
        }
        
        mainAuthViewModel.failureSignUpHandler = { [weak self] error in
            guard let self = self else { return }
            if let _ = error as? ConnectionError {
                Alert.present(type: .connection)
            } else {
                Alert.present(type: .error,title: error.localizedDescription)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.googleButton.stop()
            }
        }
        
        mainAuthViewModel.removedUserHandler = { [weak self] user, error in
            guard let self = self else { return }
            self.createAlertForRecover(error: error as! GetUserInfoError) {
                self.mainAuthViewModel.recoverProfile(user: user)
            } complitionDeny: {
                self.mainAuthViewModel.cancelRecover()
                self.googleButton.stop()
            }
        }
        
        mainAuthViewModel.successRecoverHandler = { [weak self] user in
            guard let self = self else { return }
            Alert.present(type: .success, title: "Ваш профиль восстановлен")
            self.googleButton.stop()
            let tabVC = Builder.shared.mainTabBarController(currentUser: user)
            self.present(tabVC, animated: true, completion: nil)
        }
        
        mainAuthViewModel.failureRecoverHandler = { [weak self] error in
            guard let self = self else { return }
            self.googleButton.stop()
            if let _ = error as? ConnectionError {
                Alert.present(type: .connection)
            } else {
                Alert.present(type: .error, title: "Ошибка восстановления профиля")
            }
        }
    }
}

//MARK: AuthDelegate
extension MainAuthViewConroller: AuthDelegate {
    
    func updateViewModel() {
        setupViewModel()
    }
    
    func goToLoginVC() {
        loginTapped()
    }
      
    func goToSignInVC() {
        emailTapped()
    }
}
