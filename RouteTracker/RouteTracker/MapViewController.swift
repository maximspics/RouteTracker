//
//  MapViewController.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 15.01.2021.
//

import UIKit
import GoogleMaps
import CoreLocation

protocol MapViewControllerDelegate: class {
    func selectAddres(_ coordinate: CLLocationCoordinate2D?)
}

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var mapType: UISegmentedControl!
    @IBOutlet weak var zoomIn: UIButton!
    @IBOutlet weak var zoomOut: UIButton!
    @IBOutlet weak var btnTrafficOnOff: UIButton!
    @IBOutlet weak var btnStartDetection: UIButton!
    @IBOutlet weak var btnMyCurrentLocation: UIButton!
    
    let coordinate = CLLocationCoordinate2D(latitude: 55.79622385766241, longitude: 37.53777835518122)
    let geocoder = CLGeocoder()
    
    var locationManager: CLLocationManager?
    var searchController: UISearchController?
    
    var searchMarker: GMSMarker?
    var marker: GMSMarker?
    let infoMarker = GMSMarker()
    
    var currentZoomLevel: Float = 17
    let zoomLevelStep: Float = 1
    
    var isUpdateLocationStart = false
    var isUpdateLocationRestricted: Bool = true
    var isSearchBarEmpty: Bool {
      return searchController?.searchBar.text?.isEmpty ?? true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        configureSearch()
        configureMap()
        configurLocationManager()
    }
    
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
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = true
        }
    }
    
    func configurLocationManager() {
        // По-умолчанию локация запрещена
        isUpdateLocationRestricted = true
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.requestWhenInUseAuthorization()
            locationManager?.delegate = self
         
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse, .authorizedAlways:
                isUpdateLocationRestricted = false
            default:
                isUpdateLocationRestricted = true
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
        
        zoomIn.layer.cornerRadius = 5
        zoomIn.layer.opacity = 0.8
        zoomIn.layer.borderColor = UIColor.darkGray.cgColor
        zoomIn.layer.borderWidth = 1
        
        zoomOut.layer.cornerRadius = 5
        zoomOut.layer.opacity = 0.8
        zoomOut.layer.borderColor = UIColor.darkGray.cgColor
        zoomOut.layer.borderWidth = 1
        
        btnMyCurrentLocation.layer.cornerRadius = 5
        btnMyCurrentLocation.layer.opacity = 0.8
        btnMyCurrentLocation.layer.borderColor = UIColor.darkGray.cgColor
        btnMyCurrentLocation.layer.borderWidth = 1
        
        btnTrafficOnOff.layer.cornerRadius = 5
        btnTrafficOnOff.layer.opacity = 0.8
        btnTrafficOnOff.layer.borderColor = UIColor.darkGray.cgColor
        btnTrafficOnOff.layer.borderWidth = 1
                
        btnTrafficOnOff.setImage(UIImage(systemName: (mapView.isTrafficEnabled == true ? "car.fill" : "car")),
                                 for: .normal
        )
    }

    @IBAction func goHome(_ sender: Any) {
        mapView.animate(toLocation: coordinate)

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
        btnTrafficOnOff.setImage(UIImage(systemName: (mapView.isTrafficEnabled == true ? "car.fill" : "car")),
                                 for: .normal
        )

    }
    
    @IBAction func btnAddMarkerClicked(_ sender: Any) {
        if marker == nil {
            marker = GMSMarker(position: coordinate)
            marker?.title = "Test"
            marker?.snippet = "Some description"
            marker?.map = mapView
            marker?.icon = GMSMarker.markerImage(with: .green)
            mapView.animate(toLocation: coordinate)
            
        } else {
            marker?.map = nil
            marker = nil
        }
    }
    
    @IBAction func btnMyCurrentLocationClicked(_ sender: Any) {
        if isUpdateLocationRestricted {
            showErrorMessage(message: "Для работы данной функции необходимо разрешить отслеживание местоположения")
            
        } else {
            locationManager?.requestLocation()
            
        }
    }
    
    @IBAction func btnStartDetectionClicked(_ sender: Any) {
        if isUpdateLocationRestricted {
            showErrorMessage(message: "Для работы данной функции необходимо разрешить отслеживание местоположения")
            
        } else {
            if isUpdateLocationStart {
                btnStartDetection.setTitle("Отслеживать", for: .normal)
                btnStartDetection.backgroundColor = .systemBlue
                locationManager?.stopUpdatingLocation()
            } else {
                btnStartDetection.setTitle("Остановить отслеживание", for: .normal)
                btnStartDetection.backgroundColor = .systemGreen
                locationManager?.startUpdatingLocation()
            }
            
            isUpdateLocationStart = !isUpdateLocationStart
        }
    }
}

// MARK: GMSMApViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if let marker = marker {
            marker.position = coordinate
        } else {
            marker = GMSMarker(position: coordinate)
            marker?.title = "Test"
            marker?.snippet = "Some description"
            marker?.map = mapView
            marker?.icon = GMSMarker.markerImage(with: .green)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        infoMarker.snippet = "Долгота: \(location.latitude),\nширота: \(location.longitude)"
        infoMarker.position = location
        infoMarker.title = name
        infoMarker.opacity = 0
        infoMarker.infoWindowAnchor.y = 0.4
        infoMarker.map = mapView
        mapView.selectedMarker = infoMarker
    }

}

// MARK: CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.animate(toLocation: location.coordinate)
            
            let driveMarker = GMSMarker(position: location.coordinate)
            driveMarker.map = mapView
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

// MARK: UISearchBarDelegate
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

// MARK: MapViewControllerDelegate
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
