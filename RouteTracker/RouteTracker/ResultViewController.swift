//
//  ResultViewController.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 15.01.2021.
//

import UIKit
import CoreLocation

class ResultViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    // MARK: Properties
    weak var mapViewDelegate: MapViewControllerDelegate?
    var results: [CLPlacemark] = []
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Method
    func update() {
        tableView.reloadData()
    }

}

// MARK: UITableViewDelegate
extension ResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mapViewDelegate?.selectAddres(results[indexPath.row].location?.coordinate)
        dismiss(animated: true)
    }
}

// MARK: UITableViewDataSource
extension ResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as? ResultViewCell else {
            preconditionFailure()
        }
        
        cell.configureWith(place: results[indexPath.row])
        
        return cell
    }
    
}
