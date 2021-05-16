//
//  Extension + UILabel.swift
//  Places
//
//  Created by Владимир Ли on 09.05.2021.
//

import UIKit

extension UILabel {
    
    func setup(label: UILabel, fontsize: CGFloat, weight: UIFont.Weight) {
        label.font = UIFont.systemFont(ofSize: fontsize, weight: weight)
    }
}

