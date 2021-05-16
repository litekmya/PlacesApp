//
//  RatingControl.swift
//  Places
//
//  Created by Владимир Ли on 14.05.2021.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    //MARK:- Public properties
    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
    //MARK:- Private properties
    private var ratingButtons = [UIButton]()
    
    @IBInspectable private var starSize: CGSize = CGSize(width: 40, height: 40) {
        didSet {
            createButtons()
        }
    }
    @IBInspectable private var starCount: Int = 5 {
        didSet {
            createButtons()
        }
    }
    
    //MARK:- Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        createButtons()
    }
    
    //MARK:- Private Methods
    private func createButtons() {
        
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        
        for _ in 1...starCount {
            let button = UIButton()
           
            setup(button: button)
            
            button.addTarget(self, action: #selector(buttonPressed(button:)), for: .touchUpInside)
            addArrangedSubview(button)
            
            ratingButtons.append(button)
        }
        
        updateButtonSelectionState()
    }
    
    @objc private func buttonPressed(button: UIButton) {
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
        
    }
    
    private func setup(button: UIButton) {
        let bundle = Bundle(for: type(of: self))
        
        let fillStar = UIImage(named: "fillStar", in: bundle, compatibleWith: self.traitCollection)
        let star = UIImage(named: "star", in: bundle, compatibleWith: self.traitCollection)
        
        button.setImage(star, for: .normal)
        button.setImage(fillStar, for: .selected)
        button.setImage(fillStar, for: .highlighted)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
        button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
    }
    
    private func updateButtonSelectionState() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
}
