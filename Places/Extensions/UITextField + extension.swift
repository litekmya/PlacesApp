//
//  Extension + UITextField.swift
//  Places
//
//  Created by Владимир Ли on 11.05.2021.
//

import UIKit

extension UITextField {
    
    func setup(fontSize: CGFloat, weight: UIFont.Weight, holder: String) {
        font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        placeholder = holder
        autocapitalizationType = .sentences
    }
}
