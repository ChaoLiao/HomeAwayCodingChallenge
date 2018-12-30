//
//  SearchViewController.swift
//  HomeAway
//
//  Created by YIN CHAO LIAO on 12/21/18.
//  Copyright © 2018 CHAO LIAO. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    private var eventCellViewModels = [EventCellViewModel]()
    let seatGeekAPI = SeatGeekAPI()
    
    // MARK: Subviews
    private let searchBar: UISearchBar = {
        let bar = UISearchBar(frame: .zero)
        bar.placeholder = "Texas Ranger"
        bar.searchBarStyle = .minimal
        bar.showsCancelButton = true
        
        let textField = bar.value(forKey: "searchField") as? UITextField
        textField?.textColor = .white
        
        return bar
    }()
    
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero)
        view.register(EventCell.self, forCellReuseIdentifier: EventCell.cellId)
        view.backgroundColor = UIColor.white
        view.keyboardDismissMode = .onDrag
        return view
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = .lightGray
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = searchBar
        
        /*
           The nav bar here has the search bar inside and therefore is taller than
           the nav bar on the detail view. Setting this property fixes the transient gap
           below the navigation bar when psuhing on the detail view controller.
        */
        extendedLayoutIncludesOpaqueBars = true
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        searchBar.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
        
        installConstraints()
    }
    
    private func installConstraints() {
        Layout.disableAutoresizingMaskConstrains(views: [searchBar, tableView, loadingIndicator])
        let views = [
            "searchBar": searchBar,
            "tableView": tableView
        ]
        
        let constraints = [
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[searchBar]|", options: [], metrics: nil, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[searchBar]|", options: [], metrics: nil, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: nil, views: views),
            [loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)],
            [loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)]
        ].flatMap { $0 }
        NSLayoutConstraint.activate(constraints)
    }
    
    private func search(_ searchText: String) {
        guard !searchText.isEmpty else {
            return
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        loadingIndicator.startAnimating()
        
        let favoritedEventIds = FavoritedEventStore.shared.favoritedEventIds()
        seatGeekAPI.search(with: searchText, favoritedEventIds: favoritedEventIds) { [weak self] (error, events) in
            guard let `self` = self else {
                return
            }
            if let error = error {
                print(error.localizedDescription)
            }

            self.eventCellViewModels = EventCellViewModel.viewModelsFromDataModels(events)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.loadingIndicator.stopAnimating()
            }
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventCellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventCell.cellId) as! EventCell
        let cellViewModel = eventCellViewModels[indexPath.row]
        cell.configure(with: cellViewModel)
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewModel = eventCellViewModels[indexPath.row]
        let eventDetailViewController = EventDetailViewController(viewModel: viewModel)
        eventDetailViewController.delegate = self
        navigationController?.pushViewController(eventDetailViewController, animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(searchText)
    }
}

extension SearchViewController: EventDetailViewControllerDelegate {
    func eventDetailViewController(_ viewController: EventDetailViewController, didToggleFavoriteWithEventId eventId: Int) {
        for (i, eventCellModel) in eventCellViewModels.enumerated() {
            if eventCellModel.id == eventId {
                eventCellModel.isFavorited = !eventCellModel.isFavorited
                let indexPath = IndexPath(row: i, section: 0)
                tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                
                let favoritedEventStore = FavoritedEventStore.shared
                if eventCellModel.isFavorited {
                    favoritedEventStore.favoriteEvent(for: eventId)
                } else {
                    favoritedEventStore.unfavoriteEvent(for: eventId)
                }
            }
        }
    }
}

