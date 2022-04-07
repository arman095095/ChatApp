//
//  PeopleViewController.swift
//  diffibleData
//
//  Created by Arman Davidoff on 20.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxRelay

class PeopleViewController: UIViewController {
    
    private let activityIndicator: CustomActivityIndicator = {
        let view = CustomActivityIndicator()
        view.strokeColor = UIColor.mainApp()
        view.lineWidth = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var collectionView: UICollectionView!
    private let refreshControl = UIRefreshControl()
    fileprivate var dataSource: UICollectionViewDiffableDataSource<Sections,MUser>!
    private var peopleViewModel: PeopleViewModel
    private var dispose = DisposeBag()
    
    init(peopleViewModel: PeopleViewModel) {
        self.peopleViewModel = peopleViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        overrideUserInterfaceStyle = .light
        navigationItem.title = peopleViewModel.title
        setupSearchBar()
        setupCollectionView()
        setupDataSource()
        setupActivity()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    @objc private func updatePeople() {
        peopleViewModel.getUsers()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomHeight = buttonBarHeight
        let offsetY = collectionView.contentOffset.y
        let contentHeight = collectionView.contentSize.height - collectionView.frame.size.height + collectionView.contentInset.bottom + bottomHeight
        
        if offsetY >= contentHeight/2 && peopleViewModel.allowMoreLoad && peopleViewModel.usersCountOverLimit {
            peopleViewModel.loadMore()
        }
    }
}

//MARK: SetupUI
private extension PeopleViewController {
    
    func setupActivity() {
        collectionView.addSubview(activityIndicator)
        activityIndicator.topAnchor.constraint(equalTo: self.view.topAnchor, constant: UIScreen.main.bounds.height/2).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activityIndicator.constraint(equalTo: CGSize(width: 40, height: 40))
        activityIndicator.startLoading()
    }
}

//MARK: Setup Binding
private extension PeopleViewController {
    
    func setupBinding() {
        peopleViewModel.usersUpdated.asDriver().drive(onNext: { [weak self] updated in
            if updated {
                self?.reloadData()
                self?.completionAfterLoad()
            }
        }).disposed(by: dispose)
        
        peopleViewModel.sendingError.asDriver().drive(onNext: { [weak self] error in
            if let error = error {
                self?.completionAfterLoad()
                if let _ = error as? ConnectionError {
                    Alert.present(type: .connection)
                } else {
                    Alert.present(type: .error,title: error.localizedDescription)
                }
            }
        }).disposed(by: dispose)
    }
    
    func completionAfterLoad() {
        activityIndicator.completeLoading(success: true)
        activityIndicator.isHidden = true
        peopleViewModel.allowMoreLoad = true
        if refreshControl.isRefreshing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.refreshControl.endRefreshing()
            }
        }
    }
}

//MARK: CollectionViewDelegate
extension PeopleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = self.dataSource.itemIdentifier(for: indexPath) else { return }
        let profileVC = Builder.shared.profileVC(friend: user, managers: peopleViewModel.managers)
        self.present(profileVC, animated: true, completion: nil)
    }
}

//MARK: Setup NavigationBar
private extension PeopleViewController {
    
    func setupSearchBar() {
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        navigationController?.navigationBar.barTintColor = .systemGray6
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
}

//MARK: Setup CollectionView
private extension PeopleViewController {
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: setupLayout())
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        collectionView.backgroundColor = .systemGray6
        collectionView.delegate = self
        collectionView.addSubview(refreshControl)
        collectionView.register(PeopleViewCell.self, forCellWithReuseIdentifier: PeopleViewCell.idCell)
        collectionView.register(EmptyHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmptyHeaderView.idHeader)
        refreshControl.addTarget(self, action: #selector(updatePeople), for: .valueChanged)
        refreshControl.tintColor = UIColor.mainApp()
    }
}

//MARK: Setup CollectionView DataSource
fileprivate extension PeopleViewController {
    
    enum Sections: Int, CaseIterable {
        case people
        case empty
    }
    
    func setupDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<Sections, MUser>(collectionView: collectionView, cellProvider: {
            (collectionView, indexpath, user) -> UICollectionViewCell? in
            guard let section = Sections(rawValue: indexpath.section) else { fatalError("section not found") }
            switch section {
            case .people :
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PeopleViewCell.idCell, for: indexpath) as! PeopleViewCell
                cell.config(value: user)
                return cell
            case .empty:
                return nil
            }
        })
        
        dataSource!.supplementaryViewProvider = { collectionView, kind, indexpath -> UICollectionReusableView? in
            guard let section = Sections(rawValue: indexpath.section) else { fatalError("section not found") }
            switch section {
            case .people:
                return nil
            case .empty:
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EmptyHeaderView.idHeader, for: indexpath) as! EmptyHeaderView
                header.config(type: .emptyPeople)
                return header
            }
        }
    }
    
    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Sections,MUser>()
        snapshot.appendSections([.people])
        snapshot.appendItems(peopleViewModel.people, toSection: .people)
        snapshot.appendSections([.empty])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

//MARK: Setup CollectionView Layout
private extension PeopleViewController {
    
    func setupLayout() -> UICollectionViewCompositionalLayout {
        let layout =  UICollectionViewCompositionalLayout { [weak self] (section, _) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            guard let section = Sections(rawValue: section) else { return nil }
            switch section {
            case .people:
                return self.compositionalHorizontalLayoutSectionWithoutHeader()
            case .empty:
                if !self.dataSource.snapshot().itemIdentifiers(inSection: .people).isEmpty { return nil }
                return self.compositionalHorizontalLayoutSectionWithHeader()
            }
        }
        return layout
    }
    
    func compositionalHorizontalLayoutSectionWithHeader() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(0), heightDimension: .absolute(0))
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(0), heightDimension: .absolute(0))
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.boundarySupplementaryItems = [header]
        section.orthogonalScrollingBehavior = .none
        section.contentInsets = NSDirectionalEdgeInsets(top: 15
                                                        , leading: 16, bottom: 15, trailing: 16)
        return section
    }
    
    func compositionalHorizontalLayoutSectionWithoutHeader() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.6))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(15)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .none
        section.interGroupSpacing = 10
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 15
                                                        , leading: 16, bottom: 15, trailing: 16)
        return section
    }
}

