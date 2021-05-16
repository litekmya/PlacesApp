//
//  RatingDisplay.swift
//  Places
//
//  Created by Владимир Ли on 15.05.2021.
//

import UIKit

@IBDesignable class RatingDisplay: UIStackView {
    
    //MARK:- Public properties
    var rating = 0 {
        didSet {
            getRating()
        }
    }
    
    //MARK:- Private properties
    private var starImageViews = [UIImageView]()
    
    //MARK:- Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createImageViews()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        createImageViews()
    }
    
    //MARK:- Private Methods
    private func createImageViews() {
        
        for _ in 1...5 {
            let imageView = UIImageView()
            
            setup(imageView: imageView)
            addArrangedSubview(imageView)
            
            starImageViews.append(imageView)
            
            getRating()
        }
    }
    
    private func setup(imageView: UIImageView) {
        let bundle = Bundle(for: type(of: self))
        let starImage = UIImage(named: "star", in: bundle, compatibleWith: self.traitCollection)
        
        imageView.image = starImage
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
    }
    
    private func getRating() {
        
        
        for (index, imageView) in starImageViews.enumerated() {
            imageView.image = UIImage(named: "star")
            
            if rating > index {
                imageView.image = UIImage(named: "fillStar")
            }
        }
    }

}
