//
//  SettingsViewController.swift
//  diffibleData
//
//  Created by Arman Davidoff on 25.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import RxSwift

class SettingsViewController: UIViewController {
    
    private let titleLabel = UILabel(text: "Настройки", font: UIFont.avenir26())
    private let editInfoButton = UIButton(title: "Редактировать информацию", backgroundColor: .white, titleColor: #colorLiteral(red: 0.4174995422, green: 0.2606979012, blue: 0.7359834313, alpha: 1), font: UIFont.avenir19(), shadow: true, cornerRaduis: 4, google: false, height: 60, shadowColor: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))
    private let blackListButton = UIButton(title: "Заблокированные пользователи", backgroundColor: .white, titleColor: #colorLiteral(red: 0.4174995422, green: 0.2606979012, blue: 0.7359834313, alpha: 1), font: UIFont.avenir19(), shadow: true, cornerRaduis: 4, google: false, height: 60, shadowColor: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))
    private let removeProfileButton = LoadButton(title: "Удалить профиль", backgroundColor: .white, titleColor: .buttonRed(), font: UIFont.avenir19(), shadow: true, cornerRaduis: 4, google: false, height: 60, activityColor: .black, shadowColor: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))
    private let exitButton = LoadButton(title: "Выйти", backgroundColor: .white, titleColor: .buttonRed(), font: UIFont.avenir19(), shadow: true, cornerRaduis: 4, google: false, height: 60, activityColor: .black, shadowColor: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))
    private let settingsViewModel: SettingsViewModel
    
    private let dispose = DisposeBag()
    
    init(settingsViewModel: SettingsViewModel) {
        self.settingsViewModel = settingsViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = settingsViewModel.title
        tabBarController?.tabBar.isHidden = true
        setupViews()
        setupConstreints()
        setupActions()
        setupBinding()
    }
    
    @objc private func editProfileTapped() {
        let vc = Builder.shared.editInfoVC(currentUser: settingsViewModel.currentUser, firestoreManager: settingsViewModel.managers.firestoreManager)
        if let navigationController = navigationController {
            navigationController.pushViewController(vc, animated: true)
        } else {
            present(vc, animated: true, completion: nil)
        }
    }
    
    @objc private func showBlackListTapped() {
        let vc = Builder.shared.blackListVC(managers: settingsViewModel.managers)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func removeProfileTapped() {
        let alert = UIAlertController(title: "Вы уверены?", message: "Удалив Ваш профиль, его можно будет восстановить в течение месяца", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive, handler: { [weak self] _ in
            self?.removeProfileButton.loading()
            self?.settingsViewModel.removeProfile()
        })
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func exitTapped() {
        exitButton.loading()
        settingsViewModel.logout()
    }
}

//MARK: Setup Binding
private extension SettingsViewController {
    
    func setupBinding() {
        settingsViewModel.error.asDriver().drive(onNext: { [weak self] error in
            if let error = error {
                if let _ = error as? ConnectionError {
                    Alert.present(type: .connection)
                } else {
                    Alert.present(type: .error,title: error.localizedDescription)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.exitButton.stop()
                    self?.removeProfileButton.stop()
                }
            }
        }).disposed(by: dispose)
        
        settingsViewModel.successRemoved.asDriver().drive(onNext: { [weak self] success in
            if success {
                Alert.present(type: .success, title: "Профиль удален")
                self?.removeProfileButton.stop()
                UIApplication.shared.keyWindow?.rootViewController = Builder.shared.mainAuthVC()
            }
        }).disposed(by: dispose)
        
        settingsViewModel.successLogout.asDriver().drive(onNext: { [weak self] success in
            if success {
                self?.exitButton.stop()
                UIApplication.shared.keyWindow?.rootViewController = Builder.shared.mainAuthVC()
            }
        }).disposed(by: dispose)
    }
}

//MARK: Setup UI
private extension SettingsViewController {
    
    func setupViews() {
        view.backgroundColor = .systemGray6
        view.addSubview(titleLabel)
        view.addSubview(editInfoButton)
        view.addSubview(blackListButton)
        view.addSubview(removeProfileButton)
        view.addSubview(exitButton)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        editInfoButton.translatesAutoresizingMaskIntoConstraints = false
        blackListButton.translatesAutoresizingMaskIntoConstraints = false
        removeProfileButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupActions() {
        editInfoButton.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        blackListButton.addTarget(self, action: #selector(showBlackListTapped), for: .touchUpInside)
        removeProfileButton.addTarget(self, action: #selector(removeProfileTapped), for: .touchUpInside)
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
    }
    
    func setupConstreints() {
        
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        editInfoButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40).isActive = true
        editInfoButton.widthAnchor.constraint(equalTo: view.widthAnchor,constant: -50).isActive = true
        editInfoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        blackListButton.topAnchor.constraint(equalTo: editInfoButton.bottomAnchor, constant: 30).isActive = true
        blackListButton.widthAnchor.constraint(equalTo: editInfoButton.widthAnchor).isActive = true
        blackListButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        removeProfileButton.topAnchor.constraint(equalTo: blackListButton.bottomAnchor, constant: 30).isActive = true
        removeProfileButton.widthAnchor.constraint(equalTo: editInfoButton.widthAnchor).isActive = true
        removeProfileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        exitButton.widthAnchor.constraint(equalTo: editInfoButton.widthAnchor).isActive = true
        exitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        exitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
    }
}
