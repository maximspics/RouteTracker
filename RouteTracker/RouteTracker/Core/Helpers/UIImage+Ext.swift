//
//  UIImage+Ext.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 09.02.2021.
//

import UIKit

extension UIImage {
    func circularImage(_ radius: CGFloat) -> UIImage? {
        var imageView = UIImageView()
        
        if self.size.width > self.size.height {
            imageView.frame =  CGRect(x: 0, y: 0, width: self.size.width, height: self.size.width)
            imageView.image = self
            imageView.contentMode = .scaleAspectFit
        } else {
            imageView = UIImageView(image: self)
        }
        
        var layer: CALayer = CALayer()

        layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = radius
        layer.borderWidth = 5
        layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return roundedImage
    }
}
