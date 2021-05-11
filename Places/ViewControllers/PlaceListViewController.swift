//
//  PlaceListViewController.swift
//  Places
//
//  Created by Владимир Ли on 09.05.2021.
//

import UIKit

class PlaceListViewController: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var ratingButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Private properties
    let places: [Place] = [Place(name: "A1", address: "Ростов", type: "Магазин",
                                 imageData: nil, date: Date(), rating: 0.0),
                            Place(name: "B2", address: "Таганрог", type: "Клуб",
                                  imageData: nil, date: Date(), rating: 0.0)]
    var heightOfRows: CGFloat = 0
    var spacing: CGFloat = 60
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup(tableView: tableView)
    }
    
    //MARK:- Private Methods
    private func setup(tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK:- IBOutlets
    @IBAction func sortWithSegmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            
        } else {
            
        }
    }
    @IBAction func sortWithRating(_ sender: Any) {
    }
}

    //  MARK:- UITableViewDelegate, UITableViewDataSource
extension PlaceListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeListCell", for: indexPath) as! PlaceListTableViewCell
        let place = places[indexPath.row]
        
        cell.nameLabel.text = place.name
        cell.addressLabel.text = place.address
        cell.typeLabel.text = place.type
        
        heightOfRows = cell.setupHeightOfRows(cell.nameLabel,
                                              cell.addressLabel,
                                              cell.typeLabel,
                                              spacing: spacing)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        heightOfRows
    }
}

