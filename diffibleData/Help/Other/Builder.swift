//
//  Builder.swift
//  diffibleData
//
//  Created by Arman Davidoff on 15.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import FirebaseAuth
import MessageKit

class Builder {
    
    static let shared = Builder()
    private init() { }
    
    func mainWindow(scene: UIWindowScene) -> UIWindow {
        let authManager = FirebaseAuthManager()
        
        let window = UIWindow(windowScene: scene)
        guard let user = Auth.auth().currentUser else {
            window.rootViewController = mainAuthVC(authManager: authManager)
            window.makeKeyAndVisible()
            return window
        }
        authManager.getUserProfile(userID: user.uid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let muser):
                window.rootViewController = self.mainTabBarController(currentUser: muser)
            case .failure(_):
                window.rootViewController = self.mainAuthVC(authManager: authManager)
            }
        }
        window.makeKeyAndVisible()
        return window
    }
    
    func mainAuthVC(authManager: FirebaseAuthManager) -> MainAuthViewConroller {
        let googleAuthManager = GoogleAuthManager(authManager: authManager)
        let authManagers = AuthManagersContainer(authManager: authManager, googleAuthManager: googleAuthManager)
        let mainAuthViewModel = MainAuthViewModel(authManagers: authManagers)
        return MainAuthViewConroller(mainAuthViewModel: mainAuthViewModel)
    }
    
    func mainAuthVC() -> MainAuthViewConroller {
        let authManager = FirebaseAuthManager()
        let googleAuthManager = GoogleAuthManager(authManager: authManager)
        let authManagers = AuthManagersContainer(authManager: authManager, googleAuthManager: googleAuthManager)
        let mainAuthViewModel = MainAuthViewModel(authManagers: authManagers)
        return MainAuthViewConroller(mainAuthViewModel: mainAuthViewModel)
    }
    
    func signUpVC(delegate: AuthDelegate, authManagers: AuthManagersContainerProtocol) -> SignUpViewController {
        let signUpViewModel = SignUpViewModel(authManagers: authManagers)
        let vc = SignUpViewController(signInViewModel: signUpViewModel)
        vc.delegate = delegate
        return vc
    }
    
    func loginVC(delegate: AuthDelegate, authManagers: AuthManagersContainerProtocol) -> LoginViewController {
        let loginViewModel = LoginViewModel(authManagers: authManagers)
        let vc = LoginViewController(loginViewModel: loginViewModel)
        vc.delegate = delegate
        return vc
    }
    
    func firstAddInfoVC(currentUser: User, authManager: FirebaseAuthManager) -> SetupProfileViewController {
        let infoManager = InfoManagersContainer(firestoreManager: nil, authManager: authManager)
        let setupProfileViewModel = SetupProfileViewModel(currentUser: currentUser, editedUser: nil, infoManagers: infoManager)
        let vc = SetupProfileViewController(setupProfileViewModel: setupProfileViewModel)
        return vc
    }
}

//MARK: Profile
extension Builder {
    
    func mainTabBarController(currentUser: MUser) -> MainTabBarController {
        let managers = initializeManagers(currentUser: currentUser)
        let viewModel = MainTabBarViewModel(managers: managers)
        let vc = MainTabBarController(viewModel: viewModel)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    func editInfoVC(currentUser: MUser, firestoreManager: FirestoreManager) -> SetupProfileViewController {
        let infoManager = InfoManagersContainer(firestoreManager: firestoreManager, authManager: nil)
        let setupProfileViewModel = SetupProfileViewModel(currentUser: nil, editedUser: currentUser, infoManagers: infoManager)
        let vc = SetupProfileViewController(setupProfileViewModel: setupProfileViewModel)
        return vc
    }
    
    func settingsVC(currentUser: MUser, managers: ProfileManagersContainerProtocol) -> SettingsViewController {
        let viewModel = SettingsViewModel(currentUser: currentUser, managers: managers)
        let vc = SettingsViewController(settingsViewModel: viewModel)
        return vc
    }
    
    func userPostsVC(filter: MUser, managers: ProfileManagersContainerProtocol) -> PostsViewController {
        let postsViewModel = PostsViewModel(filterUser: filter, managers: managers)
        return PostsViewController(postsViewModel: postsViewModel)
    }
    
    func allPostsVC(managers: ProfileManagersContainerProtocol) -> PostsViewController {
        let postsViewModel = PostsViewModel(filterUser: nil, managers: managers)
        return PostsViewController(postsViewModel: postsViewModel)
    }
    
    func postCreateVC(managers: ProfileManagersContainerProtocol) -> PostCreateViewController {
        let viewModel = PostCreateViewModel(managers: managers)
        let vc = PostCreateViewController(postCreateViewModel: viewModel)
        return vc
    }
    
    //Your Profile and tabbarHidden = false
    func rootProfileVC(managers: ProfileManagersContainerProtocol) -> ProfileViewController {
        let profileViewModel = ProfileViewModel(friend: nil, root: true, managers: managers)
        return ProfileViewController(profileViewModel: profileViewModel)
    }
    
    //Friend = nil if your profile && tabbarHidden = true
    func profileVC(friend: MUser?, managers: ProfileManagersContainerProtocol) -> ProfileViewController {
        let profileViewModel = ProfileViewModel(friend: friend, root: false, managers: managers)
        return ProfileViewController(profileViewModel: profileViewModel)
    }
    
    func messengerVC(delegate: CellReloaderProtocol, chat: MChat, managers: ProfileManagersContainerProtocol) -> MessangerViewController {
        let messageCollectionView = MessagesCollectionView()
        let audioRecorder = AudioMessageRecorder()
        let audioPlayer = AudioMessagePlayer(messageCollectionView: messageCollectionView)
        let audioManagers = AudioManagersContainer(recorder: audioRecorder, player: audioPlayer)
        let messangerViewModel = MessangerViewModel(chat: chat, managers: managers, audioManagers: audioManagers)
        let vc = MessangerViewController(messangerViewModel: messangerViewModel)
        vc.messagesCollectionView = messageCollectionView
        vc.delegate = delegate
        return vc
    }
    
    func answerVC(chat: MChat, delegate: ChatsOperationsDelegate) -> AnswerViewController {
        let answerVC = AnswerViewController(chat: chat)
        answerVC.delegate = delegate
        return answerVC
    }
    
    func chatsVC(managers: ProfileManagersContainerProtocol) -> ChatsViewController {
        let chatsViewModel = ChatsViewModel(managers: managers)
        let vc = ChatsViewController(chatsViewModel: chatsViewModel)
        return vc
    }
    
    func peopleVC(managers: ProfileManagersContainerProtocol) -> PeopleViewController {
        let peopleViewModel = PeopleViewModel(managers: managers)
        let vc = PeopleViewController(peopleViewModel: peopleViewModel)
        return vc
    }
    
    func blackListVC(managers: ProfileManagersContainerProtocol) -> BlackListViewController {
        let viewModel = BlackListViewModel(managers: managers)
        let vc = BlackListViewController(blackListViewModel: viewModel)
        return vc
    }
}

//MARK: Help
extension Builder {
    
    private func initializeManagers(currentUser: MUser) -> ProfileManagersContainerProtocol {
        RealmManager.initiate(userID: currentUser.id!)
        let firestoreManager = FirestoreManager(currentUser: currentUser)
        let managerModel = ManagerModelContainer(currentUser: currentUser, firestoreManager: firestoreManager)
        let chatManager = ChatsManager(managerModel: managerModel)
        let usersManager = UsersManager(managerModel: managerModel)
        let postsManager = PostsManager(managerModel: managerModel)
        
        return ProfileManagersContainer(currentUser: currentUser, chatsManager: chatManager, postsManager: postsManager, firestoreManager: firestoreManager, usersManager: usersManager)
    }
    
    func countryListVC() -> CountryCityViewController {
        let viewModel = CountryCityViewModel()
        let vc = CountryCityViewController(countryCityViewModel: viewModel)
        return vc
    }
    
    func cityListVC(model: AreaType) -> CountryCityViewController {
        let viewModel = CountryCityViewModel(selectedItem: model)
        let vc = CountryCityViewController(countryCityViewModel: viewModel)
        return vc
    }
    
    func imageVC(image: UIImage) -> UIViewController {
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let vc = UIViewController()
        vc.view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        return vc
    }
}
