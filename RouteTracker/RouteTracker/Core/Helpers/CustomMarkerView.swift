//
//  CustomMarkerView.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 10.02.2021.
//

import UIKit

class CustomMarkerView: UIView {
    
    var image: UIImage?
    var borderColor: UIColor?
    var borderWidth: CGFloat?
    var radius: CGFloat?
    
    init(frame: CGRect, image: UIImage, borderColor: UIColor, borderWidth: CGFloat, radius: CGFloat) {
        super.init(frame: frame)
        self.image = image
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.radius = radius
        setupViews()
    }
    
    func setupViews() {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imgView)
        imgView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imgView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imgView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imgView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imgView.layer.cornerRadius = radius ?? 0
        imgView.layer.borderColor = borderColor?.cgColor
        imgView.contentMode = .scaleAspectFill
        imgView.layer.borderWidth = borderWidth ?? 0
        imgView.clipsToBounds = true
        imgView.image = image
        UIView.animate(withDuration: 0.8) {
            imgView.alpha = 0.8
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
