//
//  ResultViewCell.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 15.01.2021.
//

import UIKit
import CoreLocation

class ResultViewCell: UITableViewCell {
    
    override func prepareForReuse() {
        textLabel?.text = nil
        detailTextLabel?.text = nil
    }
    
    func configureWith(place: CLPlacemark) {
        textLabel?.text = place.name
        detailTextLabel?.text = "\(place.country ?? "-") \(place.administrativeArea ?? "") \(place.postalCode ?? "-")"
    }
}
