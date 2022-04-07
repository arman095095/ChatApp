//
//  navigation.swift
//  diffibleData
//
//  Created by Arman Davidoff on 20.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//


import UIKit
import RxSwift
import FirebaseAuth

class MainTabBarController: UITabBarController {
    
    private var peopleVC: PeopleViewController
    private var chatsVC: ChatsViewController
    private var postsVC: PostsViewController
    private var profileVC: ProfileViewController
    private let mainTabBarViewModel: MainTabBarViewModel
    private let dispose = DisposeBag()
    
    init(viewModel: MainTabBarViewModel) {
        mainTabBarViewModel = viewModel
        peopleVC = Builder.shared.peopleVC(managers: viewModel.managers)
        chatsVC = Builder.shared.chatsVC(managers: viewModel.managers)
        postsVC = Builder.shared.allPostsVC(managers: viewModel.managers)
        profileVC = Builder.shared.rootProfileVC(managers: viewModel.managers)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupVCs()
        setupBinding()
    }
}

//MARK: Setup TabBarController
private extension MainTabBarController {
    
    func setupTabBar() {
        tabBar.barTintColor = .systemGray6
        tabBar.layer.borderWidth = 0
        tabBar.clipsToBounds = true
        tabBar.unselectedItemTintColor = #colorLiteral(red: 0.5450980392, green: 0.4509803922, blue: 0.937254902, alpha: 1)
        tabBar.tintColor = #colorLiteral(red: 0.7772225649, green: 0.1716628475, blue: 1, alpha: 1)
        tabBarItem.setTitleTextAttributes(mainTabBarViewModel.atributesFont as [NSAttributedString.Key : Any], for: .normal)
    }
    
    func navigationVC(rootVC: UIViewController,title: String, image: UIImage) -> UINavigationController {
        let navigationVC = UINavigationController(rootViewController: rootVC)
        navigationVC.tabBarItem.image = image
        navigationVC.tabBarItem.title = title
        return navigationVC
    }
    
    func setupVCs() {
        let peopleNC = navigationVC(rootVC: peopleVC, title: mainTabBarViewModel.peopleTitle, image: mainTabBarViewModel.peopleImage)
        let chatsNC = navigationVC(rootVC: chatsVC, title: mainTabBarViewModel.communicationTitle, image: mainTabBarViewModel.communicationImage)
        let postsNC = navigationVC(rootVC: postsVC, title: mainTabBarViewModel.postsTitle, image: mainTabBarViewModel.postsImage)
        let profileNC = navigationVC(rootVC: profileVC, title: mainTabBarViewModel.profileTitle, image: mainTabBarViewModel.profileImage)
        viewControllers = [ peopleNC, postsNC, chatsNC, profileNC ]
    }
}

//MARK: Setup Binding
private extension MainTabBarController {
    
    func setupBinding() {
        mainTabBarViewModel.updatedBadge.asDriver().drive(onNext: { [weak self] _ in
            self?.setupBadges()
        }).disposed(by: dispose)
        
        mainTabBarViewModel.sendingError.asDriver().drive(onNext: { error in
            if let error = error {
                if let _ = error as? ConnectionError {
                    Alert.present(type: .connection)
                } else {
                    Alert.present(type: .error,title: error.localizedDescription)
                }
            }
        }).disposed(by: dispose)
    }
    
    func setupBadges() {
        if let chatsItem = tabBar.items?.first(where: { $0.title == self.mainTabBarViewModel.communicationTitle }) {
            chatsItem.badgeValue = self.mainTabBarViewModel.badgeValueForChats
        }
    }
}
