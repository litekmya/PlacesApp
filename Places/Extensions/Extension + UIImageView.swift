//
//  Extension + UIImageView.swift
//  Places
//
//  Created by Владимир Ли on 09.05.2021.
//

import UIKit

extension UIImageView {
    
    func setup(imageView: UIImageView) {
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.layer.borderWidth = 1
    }
    
    func getDataFor(imageView: UIImageView, from place: Place) {
        guard let imageData = place.imageData else { return }
        let image = UIImage(data: imageData)
        
        imageView.image = image
    }
}
