//
//  PlaceListTableViewCell.swift
//  Places
//
//  Created by Владимир Ли on 09.05.2021.
//

import UIKit

class PlaceListTableViewCell: UITableViewCell {
    
    //MARK:- IBOutlets
    @IBOutlet weak var placeImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    //MARK:- Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLabels()
        setupImageView()
    }

    //MARK:- Public Methods
    func setupHeightOfRows(_ name: UILabel, _ address: UILabel, _ type: UILabel, spacing: CGFloat) -> CGFloat {
        let heightOfLabels = name.frame.height + address.frame.height + type.frame.height
        let heightOfRows = heightOfLabels + spacing
        
        return heightOfRows
    }
    
    //MARK:- Private Methods
    private func setupLabels() {
        nameLabel.setup(label: nameLabel, fontsize: 21, weight: .medium)
        addressLabel.setup(label: addressLabel, fontsize: 19, weight: .regular)
        typeLabel.setup(label: typeLabel, fontsize: 19, weight: .regular)
    }
    
    private func setupImageView() {
        placeImageView.setup(imageView: placeImageView)
    }
}
