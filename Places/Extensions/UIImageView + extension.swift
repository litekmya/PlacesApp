//
//  Extension + UIImageView.swift
//  Places
//
//  Created by Владимир Ли on 09.05.2021.
//

import UIKit

extension UIImageView {
    
    func setup() {
        clipsToBounds = true
        layer.cornerRadius = frame.height / 2
        layer.borderWidth = 1
    }
    
    func getData(from place: Place) {
        guard let imageData = place.imageData else { return }
        let image = UIImage(data: imageData)
        
        self.image = image
    }
}
