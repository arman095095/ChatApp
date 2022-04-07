//
//  BlackListViewController.swift
//  diffibleData
//
//  Created by Arman Davidoff on 25.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import RxSwift

class BlackListViewController: UIViewController {
    
    private let tableView = UITableView()
    private let activityIndicator: CustomActivityIndicator = {
        let view = CustomActivityIndicator()
        view.strokeColor = UIColor.mainApp()
        view.lineWidth = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var blackListViewModel: BlackListViewModel
    private let dispose = DisposeBag()
    
    init(blackListViewModel: BlackListViewModel) {
        self.blackListViewModel = blackListViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = blackListViewModel.title
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        setupTableView()
        setupActivity()
        setupBinding()
    }
}

//MARK: UI Setup
private extension BlackListViewController {
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGray6
        tableView.separatorStyle = .none
        tableView.fillSuperview()
        tableView.register(BlackListViewCell.self, forCellReuseIdentifier: BlackListViewCell.idCell)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setupActivity() {
        tableView.addSubview(activityIndicator)
        activityIndicator.topAnchor.constraint(equalTo: self.view.topAnchor, constant: UIScreen.main.bounds.height/2).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activityIndicator.constraint(equalTo: CGSize(width: 40, height: 40))
        activityIndicator.startLoading()
    }
    
    func infoLabel() -> UIView {
        let view = EmptyHeaderView()
        view.config(type: .emptyBlackList)
        return view
    }
}

//MARK: Setup Binding
private extension BlackListViewController {
    
    func setupBinding() {
        blackListViewModel.updated.asDriver().drive(onNext: { [weak self] updated in
            if updated {
                self?.tableView.reloadData()
                self?.activityIndicator.completeLoading(success: true)
                self?.activityIndicator.isHidden = true
            }
        }).disposed(by: dispose)
        
        blackListViewModel.error.asDriver().drive(onNext: { [weak self] error in
            if let error = error {
                if let _ = error as? ConnectionError {
                    Alert.present(type: .connection)
                } else {
                    Alert.present(type: .error,title: error.localizedDescription)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.activityIndicator.completeLoading(success: true)
                    self?.activityIndicator.isHidden = true
                }
            }
        }).disposed(by: dispose)
        
        blackListViewModel.unlocked.asDriver().drive(onNext: { unlocked in
            if unlocked {
                Alert.present(type: .success, title: "Пользователь разблокирован")
            }
        }).disposed(by: dispose)
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension BlackListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blackListViewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BlackListViewCell.idCell, for: indexPath) as! BlackListViewCell
        let user = blackListViewModel.user(at: indexPath)
        cell.config(user: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return blackListViewModel.rowHeight
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] (_, _, _) in
            self?.blackListViewModel.unblockUser(at: indexPath)
            self?.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = blackListViewModel.user(at: indexPath)
        let vc = Builder.shared.profileVC(friend: user, managers: blackListViewModel.managers)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return infoLabel()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return blackListViewModel.headerHeight
    }
}

//MARK: ProfileViewDelegate
extension BlackListViewController: ProfileViewDelegate {
    func update() {
        blackListViewModel.getBlockedUsers()
    }
}
