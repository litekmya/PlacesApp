//
//  PlaceListViewController.swift
//  Places
//
//  Created by Владимир Ли on 09.05.2021.
//

import UIKit
import RealmSwift

class PlaceListViewController: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var ratingButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Private properties
    private var places: Results<Place>!
    private var currentPlaces: Results<Place>!
    
    private var heightOfRows: CGFloat = 0
    private var spacing: CGFloat = 32
    
    private var searchController = UISearchController(searchResultsController: nil)
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        
        return text.isEmpty
    }
    
    private var filtered: Bool {
        if searchController.isActive && searchBarIsEmpty != true {
            return true
        } else {
            return false
        }
    }
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataForPlaces()
        setup(tableView: tableView)
        setup(searchController: searchController)
    }
    
    //MARK:- Navigations
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "descriptionCell" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            let descriptionVC = segue.destination as! DescriptionTableViewController
            let place = places[indexPath.row]
            
            descriptionVC.currentPlace = place
            descriptionVC.title = place.name
        }
    }
    @IBAction func unwindsegue(for unwindSegue: UIStoryboardSegue) {
            let descriptionVC = unwindSegue.source as? DescriptionTableViewController
            descriptionVC?.saveData()
            
            tableView.reloadData()
        }

    //MARK:- Private Methods
    private func setup(tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func getDataForPlaces() {
        places = StorageManager.shared.realm.objects(Place.self)
    }
    
    //MARK:- IBOutlets
    @IBAction func sortWithSegmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date")
        } else {
            places = places.sorted(byKeyPath: "name")
        }
        
        tableView.reloadData()
    }
    
    @IBAction func sortWithRating(_ sender: Any) {
    }
    
    
}

    //  MARK:- UITableViewDelegate, UITableViewDataSource
extension PlaceListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filtered {
            return currentPlaces.count
        } else {
            return places.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeListCell", for: indexPath) as! PlaceListTableViewCell
        let place = filtered == true ? currentPlaces[indexPath.row] : places[indexPath.row]
        
        cell.nameLabel.text = place.name
        cell.addressLabel.text = place.address
        cell.typeLabel.text = place.type
        cell.ratingDisplay.rating = place.rating
        
        cell.placeImageView.getDataFor(imageView: cell.placeImageView, from: place)
        
        heightOfRows = cell.placeImageView.frame.height + spacing
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        heightOfRows
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let place = places[indexPath.row]
            StorageManager.shared.delete(place: place)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
    
    //MARK:- UISearchResultsUpdating
extension PlaceListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterBy(searchController.searchBar.text!)
    }
    
    private func setup(searchController: UISearchController) {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func filterBy(_ searchText: String) {
        currentPlaces = places.filter("name CONTAINS[c] %@ OR address CONTAINS[c] %@ OR type CONTAINS[c] %@",
                                      searchText,
                                      searchText,
                                      searchText)
        tableView.reloadData()
    }
}

