//
//  Extension + UITextField.swift
//  Places
//
//  Created by Владимир Ли on 11.05.2021.
//

import UIKit

extension UITextField {
    
    func setup(textField: UITextField,
               fontSize: CGFloat,
               weight: UIFont.Weight,
               placeholder: String) {
        textField.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        textField.placeholder = placeholder
        textField.autocapitalizationType = .sentences
    }
}
