//
//  MapViewController.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 15.01.2021.
//

import UIKit
import GoogleMaps
import CoreLocation

// MARK: - MapViewControllerDelegate implementation
protocol MapViewControllerDelegate: class {
    func selectAddres(_ coordinate: CLLocationCoordinate2D?)
}

class MapViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var mapType: UISegmentedControl!
    @IBOutlet weak var zoomIn: UIButton!
    @IBOutlet weak var zoomOut: UIButton!
    @IBOutlet weak var btnTrafficOnOff: UIButton!
    @IBOutlet weak var btnStartDetection: UIButton!
    @IBOutlet weak var btnMyCurrentLocation: UIButton!
    @IBOutlet var btnCollection: [UIButton]!
    
    // MARK: - Properties
    let coordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
    let geocoder = CLGeocoder()
    
    var locationManager: CLLocationManager?
    var searchController: UISearchController?
    
    var searchMarker: GMSMarker?
    var marker: GMSMarker?
    let infoMarker = GMSMarker()
    
    var currentZoomLevel: Float = 17
    let zoomLevelStep: Float = 1
    
    var isUpdateLocationStart = false
    var hasPermission: Bool = false
    var isSearchBarEmpty: Bool {
      return searchController?.searchBar.text?.isEmpty ?? true
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
        configureSearch()
        configureMap()
        configurLocationManager()
    }
    
    // MARK: - Methods
    func configureSearch() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let resultViewController = storyboard.instantiateViewController(identifier: "resultViewController") as? ResultViewController {
            searchController = UISearchController(searchResultsController: resultViewController)
            
            guard let searchController = searchController else {
                return
            }
            
            definesPresentationContext = true
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.searchResultsUpdater = self
            searchController.searchBar.placeholder = "Введите адрес для поиска"
            searchController.searchBar.setValue("Отменить", forKey: "cancelButtonText")
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = true
        }
    }
    
    func configurLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.requestWhenInUseAuthorization()
            locationManager?.delegate = self
            
            if let manager = locationManager {
                switch manager.authorizationStatus {
                case .restricted, .denied:
                    hasPermission = false
                default:
                    hasPermission = true
                }
            } 
        }
    }
    
    func configureMap() {
        let camera = GMSCameraPosition.init(target: coordinate, zoom: currentZoomLevel)
        
        mapView.camera = camera
        mapView.delegate = self
        
        mapView.mapType = .hybrid
        mapView.isTrafficEnabled = true
        mapView.isMyLocationEnabled = true
        mapView.settings.compassButton = true
        
        mapType.selectedSegmentIndex = 1
        
        for btn in btnCollection {
            
            btn.layer.cornerRadius = 25
            btn.layer.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.6392156863, blue: 1, alpha: 0.95)
            
        }
        mapType.layer.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.6392156863, blue: 1, alpha: 0.95)
        btnStartDetection.layer.cornerRadius = 8
        btnStartDetection.layer.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.6392156863, blue: 1, alpha: 0.95)
    }
    
    func addMarker() {
        locationManager?.requestLocation()
        let location = locationManager?.location?.coordinate ?? coordinate
        let marker = GMSMarker(position: location)
        marker.snippet = "Широта: \(location.latitude)\nДолгота: \(location.longitude)"
        marker.icon = GMSMarker.markerImage(with: .green)
        marker.map = mapView
        mapView.animate(toLocation: location)
        self.marker = marker
    }
    
    func removeMarker() {
        marker?.map = nil
        marker = nil
    }
    
    func startUpdatingLocation() {
        UIView.animate(withDuration: 0.29, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.btnStartDetection.setTitle("Остановить отслеживание", for: .normal)
            self.btnStartDetection.layer.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 0.95)
            self.locationManager?.startUpdatingLocation()
        }, completion: nil)
    }
    
    func stopUpdatingLocation() {
        UIView.animate(withDuration: 0.29, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.btnStartDetection.setTitle("Отслеживать моё местоположение", for: .normal)
            self.btnStartDetection.layer.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.6392156863, blue: 1, alpha: 0.95)
            self.locationManager?.stopUpdatingLocation()
        }, completion: nil)
    }

    // MARK: - Actions
    @IBAction func goHome(_ sender: Any) {
        isUpdateLocationStart = false
        stopUpdatingLocation()
        removeMarker()
        let marker = GMSMarker(position: coordinate)
        marker.title = "Home"
        marker.snippet = "Широта: \(coordinate.latitude)\nДолгота: \(coordinate.longitude)"
        marker.icon = GMSMarker.markerImage(with: .green)
        marker.map = mapView
        mapView.animate(toLocation: coordinate)
        self.marker = marker
    }
    
    @IBAction func mapTypeChanged(_ sender: Any) {
        if let segmented = sender as? UISegmentedControl {
            switch segmented.selectedSegmentIndex {
            case 0:
                mapView.mapType = .normal
            case 1:
                mapView.mapType = .hybrid
            case 2:
                mapView.mapType = .satellite
            case 3:
                mapView.mapType = .terrain
            default:
                mapView.mapType = .hybrid
            }
        }
    }
    
    @IBAction func zoomInClicked(_ sender: Any) {
        if mapView.maxZoom >= (currentZoomLevel + zoomLevelStep) {
            currentZoomLevel += zoomLevelStep
        } else {
            currentZoomLevel = mapView.maxZoom
        }
        
        mapView.animate(toZoom: currentZoomLevel)
    }
    
    @IBAction func zoomOutClicked(_ sender: Any) {
        if mapView.minZoom <= (currentZoomLevel - zoomLevelStep) {
            currentZoomLevel -= zoomLevelStep
        } else {
            currentZoomLevel = mapView.minZoom
        }
        
        mapView.animate(toZoom: currentZoomLevel)
    }
    
    @IBAction func trafficOnOffClicked(_ sender: Any) {
        mapView.isTrafficEnabled = !mapView.isTrafficEnabled
        UIView.animate(withDuration: 0.29, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.btnTrafficOnOff.backgroundColor = self.mapView.isTrafficEnabled == true ? #colorLiteral(red: 0.1803921569, green: 0.6392156863, blue: 1, alpha: 0.95) : nil
            self.btnTrafficOnOff.layer.borderWidth = self.mapView.isTrafficEnabled == true ? 0 : 2
            self.btnTrafficOnOff.layer.borderColor = self.mapView.isTrafficEnabled == true ? nil : #colorLiteral(red: 0.1803921569, green: 0.6392156863, blue: 1, alpha: 0.95)
        }, completion: nil)
        
    }
    
    @IBAction func btnAddMarkerClicked(_ sender: Any) {
        removeMarker()
        addMarker()
    }
    
    @IBAction func btnMyCurrentLocationClicked(_ sender: Any) {
        if hasPermission {
            locationManager?.requestLocation()
            let location = locationManager?.location
            mapView.animate(toLocation: location?.coordinate ?? coordinate)
        } else {
            showErrorMessage(message: "Для работы данной функции необходимо разрешить отслеживание местоположения")
        }
    }
    
    @IBAction func btnStartDetectionClicked(_ sender: Any) {
        if hasPermission {
            if isUpdateLocationStart {
                stopUpdatingLocation()
            } else {
                startUpdatingLocation()
            }
            
            isUpdateLocationStart = !isUpdateLocationStart
            
        } else {
            showErrorMessage(message: "Для работы данной функции необходимо разрешить отслеживание местоположения")
            
        }
    }
}

// MARK: - GMSMApViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        removeMarker()
        let marker = GMSMarker(position: coordinate)
        marker.snippet = "Широта: \(coordinate.latitude)\nДолгота: \(coordinate.longitude)"
        marker.icon = GMSMarker.markerImage(with: .green)
        marker.map = mapView
        mapView.animate(toLocation: coordinate)
        self.marker = marker
    }
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        infoMarker.snippet = "Широта: \(location.latitude)\nДолгота: \(location.longitude)"
        infoMarker.position = location
        infoMarker.title = name
        infoMarker.opacity = 0
        infoMarker.infoWindowAnchor.y = 0.4
        infoMarker.map = mapView
        mapView.selectedMarker = infoMarker
        mapView.animate(toLocation: location)
    }

}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        if isUpdateLocationStart {
            if let location = locations.first {
                mapView.animate(toLocation: location.coordinate)
                let driveMarker = GMSMarker(position: location.coordinate)
                driveMarker.icon = GMSMarker.markerImage(with: .magenta)
                driveMarker.map = mapView
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}

// MARK: - UISearchBarDelegate
extension MapViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            geocoder.geocodeAddressString(searchText) { (places, _) in
                if let places = places,
                    let resultsController = self.searchController?.searchResultsController as? ResultViewController {
                    
                    resultsController.mapViewDelegate = self
                    resultsController.results = places
                    resultsController.update()
                    
                }
            }
        }
    }
    
}

// MARK: - MapViewControllerDelegate
extension MapViewController: MapViewControllerDelegate {
    func selectAddres(_ coordinate: CLLocationCoordinate2D?) {
        if let coordinate = coordinate {
            if let searchMarker = searchMarker {
                searchMarker.position = coordinate
                
            } else {
                searchMarker = GMSMarker(position: coordinate)
                searchMarker?.map = mapView
                
            }
            
            mapView.animate(toLocation: coordinate)
        }
    }
    
}
