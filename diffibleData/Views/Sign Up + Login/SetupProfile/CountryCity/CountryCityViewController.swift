//
//  CountryCityViewController.swift
//  diffibleData
//
//  Created by Arman Davidoff on 04.12.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit

class CountryCityViewController: UIViewController {
    
    private var tableView: UITableView!
    private var countryCityViewModel: CountryCityViewModel
    private let searchController = UISearchController(searchResultsController: nil)
    
    init(countryCityViewModel: CountryCityViewModel) {
        self.countryCityViewModel = countryCityViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearchBar()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds)
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset.bottom = 40
    }
}

extension CountryCityViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryCityViewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = countryCityViewModel.nameItem(at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = countryCityViewModel.selectItem(at: indexPath) else {
            navigationController?.dismiss(animated: true)
            return
        }
        let vc = Builder.shared.cityListVC(model: model)
        searchController.searchBar.text = nil
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CountryCityViewController: UISearchResultsUpdating {
    
    private func setupSearchBar() {
        navigationItem.title = countryCityViewModel.title
        navigationController?.navigationBar.barTintColor = .systemGray6
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController?.searchResultsUpdater = self
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        countryCityViewModel.search(text: searchController.searchBar.text)
        tableView.reloadData()
    }
}
