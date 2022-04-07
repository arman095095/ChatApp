//
//  ContentView.swift
//  diffibleData
//
//  Created by Arman Davidoff on 19.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//
import UIKit
import RxCocoa
import RxSwift
import RxRelay


class ChatsViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Sections, MChat>!
    private var layout: UICollectionViewCompositionalLayout!
    private var chatsViewModel: ChatsViewModel
    private let dispose = DisposeBag()
    
    init(chatsViewModel: ChatsViewModel) {
        self.chatsViewModel = chatsViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupLayout()
        setupCollectionView()
        setupDataSource()
        DispatchQueue.main.async {
            self.reloadData()
            self.setupBinding()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}

//MARK: Setup UI
private extension ChatsViewController {
    
}

//MARK: Setup Binding
private extension ChatsViewController {
    
    func setupBinding() {
        
        chatsViewModel.chatChangedFromWaitingToActive.asDriver().drive(onNext: { [weak self] chat in
            if let chat = chat {
                self?.reloadDataChangeChatStatus(chat: chat)
            }
            }).disposed(by: dispose)
        
        chatsViewModel.newMessageInActiveChat.asDriver().drive(onNext: { [weak self] chat in
            if let chat = chat {
                self?.reloadDataNewMessageActiveChat(chat: chat)
            }
        }).disposed(by: dispose)
        
        chatsViewModel.info.asDriver().drive(onNext: { inf in
            if let inf = inf {
                Alert.present(type: .success, title: "\(inf.0) \(inf.1)")
            }
        }).disposed(by: dispose)
        
        chatsViewModel.newWaitingChatRequest.asDriver().drive(onNext: { [weak self] chat in
            guard let self = self else { return }
            if let chat = chat {
                self.reloadDataNewWaitingChat(chat: chat)
                let answerVC = Builder.shared.answerVC(chat: chat, delegate: self)
                self.present(answerVC, animated: true, completion: nil)
            }
        }).disposed(by: dispose)
        
        chatsViewModel.chatsChangedUpdate.asDriver().drive(onNext: { [weak self] chats in
            if chats.isEmpty { return }
            self?.reloadDataEditedChats(chats: chats)
        }).disposed(by: dispose)
        
        chatsViewModel.sendingError.asDriver().drive(onNext: { error in
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

//MARK: ChatsOperationsDelegate
extension ChatsViewController: ChatsOperationsDelegate {
    
    func removeActiveChat(chat: MChat) {
        reloadDataRemoveActiveChat(chat: chat)
        chatsViewModel.removeActiveChat(chat: chat)
    }
    
    func removeWaitingChat(chat: MChat) {
        reloadDataRemoveWaitingChat(chat: chat)
        chatsViewModel.removeWaitingChat(chat: chat)
    }
    
    func changeChatStatus(chat: MChat) {
        reloadDataChangeChatStatus(chat: chat)
        chatsViewModel.changeChatStatus(chat: chat)
    }
}

//MARK: Setup SearchController
extension ChatsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        reloadData(with: text)
    }
    
    private func setupSearchBar() {
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        navigationItem.title = chatsViewModel.title
        navigationController?.navigationBar.barTintColor = .systemGray6
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController?.searchBar.placeholder = "Поиск"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController!.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController!.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController!.searchResultsUpdater = self
        definesPresentationContext = true
    }
}

//MARK: CollectionViewDelegate
extension ChatsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let chat = self.dataSource.itemIdentifier(for: indexPath) else { return }
        guard let section = Sections(rawValue: indexPath.section) else { return }
        switch section {
        case .activeChats:
            let cell = collectionView.cellForItem(at: indexPath) as! ActiveChatCell
            cell.animateSelect()
            let messangerVC = Builder.shared.messengerVC(delegate: self, chat: chat, managers: chatsViewModel.managers)
            navigationController?.pushViewController(messangerVC, animated: true)
        case .waitingChats:
            let answerVC = Builder.shared.answerVC(chat: chat, delegate: self)
            self.present(answerVC, animated: true, completion: nil)
        default:
            break
        }
    }
}

//MARK: Setup CollectionView
private extension ChatsViewController {
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        self.view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        collectionView.backgroundColor = .systemGray6
        collectionView.delegate = self
        collectionView.allowsSelection = true
        collectionView.register(ActiveChatCell.self, forCellWithReuseIdentifier: ActiveChatCell.idCell)
        collectionView.register(WaitingChatCell.self, forCellWithReuseIdentifier: WaitingChatCell.idCell)
        collectionView.register(HeaderItem.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderItem.idHeader)
        collectionView.register(EmptyHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmptyHeaderView.idHeader)
    }
}

//MARK: Setup CollectionView DataSource
private extension ChatsViewController {
    
    enum Sections: Int, CaseIterable {
        case waitingChats
        case activeChats
        case activeChatsEmpty
        
        func description() -> String {
            switch self {
            case .activeChats:
                return "Чаты"
            case .waitingChats:
                return "Запросы"
            case .activeChatsEmpty:
                return ""
            }
        }
    }
    
    func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Sections, MChat>(collectionView: collectionView, cellProvider: { [weak self]
            (collectionView, indexpath, chat) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            guard let section = Sections(rawValue: indexpath.section) else { fatalError("section not found") }
            switch section {
            case .activeChats :
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActiveChatCell.idCell, for: indexpath) as! ActiveChatCell
                cell.config(value: chat)
                cell.chatDelegate = self
                return cell
            case .waitingChats :
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WaitingChatCell.idCell, for: indexpath) as! WaitingChatCell
                cell.config(value: chat)
                return cell
            default:
                return nil
            }
        })
        
        dataSource!.supplementaryViewProvider = { collectionView, kind, indexpath -> UICollectionReusableView? in
            guard let section = Sections(rawValue: indexpath.section) else { fatalError("section not found") }
            switch section {
            case .activeChats :
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderItem.idHeader, for: indexpath) as! HeaderItem
                header.config(text: section.description(), textColor: .systemGray,fontSize: 22)
                return header
            case .waitingChats :
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderItem.idHeader, for: indexpath) as! HeaderItem
                header.config(text: section.description(), textColor: .systemGray, fontSize: 22)
                return header
            case .activeChatsEmpty:
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EmptyHeaderView.idHeader, for: indexpath) as! EmptyHeaderView
                header.config(type: .emptyActiveChats)
                return header
            }
        }
    }
    
    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Sections,MChat>()
        snapshot.appendSections([.waitingChats])
        snapshot.appendItems(chatsViewModel.waitingChats, toSection: .waitingChats)
        snapshot.appendSections([.activeChats])
        snapshot.appendItems(chatsViewModel.activeChats, toSection: .activeChats)
        snapshot.appendSections([.activeChatsEmpty])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func reloadDataEditedChats(chats: [MChat]) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(chats)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func reloadData(with searchedText: String) {
        var snapshot = NSDiffableDataSourceSnapshot<Sections,MChat>()
        let filtered = chatsViewModel.filteredActiveChats(with: searchedText)
        snapshot.appendSections([.waitingChats])
        snapshot.appendItems(chatsViewModel.waitingChats, toSection: .waitingChats)
        snapshot.appendSections([.activeChats])
        snapshot.appendItems(filtered, toSection: .activeChats)
        snapshot.appendSections([.activeChatsEmpty])
        dataSource.apply(snapshot,animatingDifferences: true)
    }
    
    func reloadDataNewMessageActiveChat(chat: MChat) {
        var snapshot = self.dataSource.snapshot()
        if let destination = snapshot.itemIdentifiers(inSection: .activeChats).first {
            if destination == chat {
                snapshot.reloadItems([chat])
            } else {
                snapshot.moveItem(chat, beforeItem: destination)
                snapshot.reloadItems([chat])
            }
        } else {
            snapshot.appendItems([chat], toSection: .activeChats)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func reloadDataRemoveWaitingChat(chat: MChat) {
        var snapshot = self.dataSource.snapshot()
        snapshot.deleteItems([chat])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func reloadDataChangeChatStatus(chat: MChat) {
        var snapshot = self.dataSource.snapshot()
        snapshot.deleteItems([chat])
        if let destination = snapshot.itemIdentifiers(inSection: .activeChats).first {
            snapshot.insertItems([chat], beforeItem: destination)
        } else {
            snapshot.appendItems([chat], toSection: .activeChats)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func reloadDataNewWaitingChat(chat: MChat) {
        var snapshot = self.dataSource.snapshot()
        if let destination = snapshot.itemIdentifiers(inSection: .waitingChats).first {
            if destination.id == chat.id { return }
            snapshot.insertItems([chat], beforeItem: destination)
            dataSource.apply(snapshot, animatingDifferences: true)
        } else {
            snapshot.appendItems([chat], toSection: .waitingChats)
            dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    func reloadDataRemoveActiveChat(chat: MChat) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([chat])
        dataSource.apply(snapshot, animatingDifferences: true)
        
    }
}

//MARK: Setup CollectionView Layout
private extension ChatsViewController {
    
    func setupLayout() {
        layout =  UICollectionViewCompositionalLayout { [weak self] (section, _) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            guard let section = Sections(rawValue: section) else { return nil }
            switch section {
            case .activeChats:
                return self.compositionalVerticalLayoutSection()
            case .waitingChats:
                if self.dataSource.snapshot().itemIdentifiers(inSection: section).isEmpty { return nil }
                return self.compositionalHorizontalLayoutSection()
            case .activeChatsEmpty:
                if !self.dataSource.snapshot().itemIdentifiers(inSection: .activeChats).isEmpty { return nil }
                return self.compositionalVerticalLayoutSection()
            }
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 15
        layout.configuration = config
    }
    
    //MARK: Vertical Section Layout
    func compositionalVerticalLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(ChatsConstants.activeChatHeight))
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        section.boundarySupplementaryItems = [header]
        section.contentInsets = NSDirectionalEdgeInsets(top: 15
                                                        , leading: 16, bottom: 15, trailing: 16)
        section.interGroupSpacing = 2
        
        return section
    }
    
    //MARK: Horizontal Section Layout
    func compositionalHorizontalLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(ChatsConstants.waitingChatHeight), heightDimension: .absolute(ChatsConstants.waitingChatHeight))
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        section.boundarySupplementaryItems = [header]
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 15
        section.contentInsets = NSDirectionalEdgeInsets(top: 15
                                                        , leading: 16, bottom: 0, trailing: 0)
        
        return section
    }
}

//MARK: Cell reload while Dismiss MessangerViewController
extension ChatsViewController: CellReloaderProtocol {
    func reloadCell(with chat: MChat) {
        reloadDataEditedChats(chats: [chat])
    }
}
