//
//  MapViewController.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 15.01.2021.
//

import UIKit
import GoogleMaps
import CoreLocation
import RealmSwift

class MapViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView! {
        didSet {
            mapView.delegate = self
            mapView.isTrafficEnabled = true
            mapView.isMyLocationEnabled = true
            mapView.settings.compassButton = true
        }
    }
    @IBOutlet weak var mapType: UISegmentedControl! {
        didSet {
            mapType.selectedSegmentIndex = 1
            mapType.layer.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.6392156863, blue: 1, alpha: 0.95)
        }
    }
    @IBOutlet weak var zoomIn: UIButton!
    @IBOutlet weak var zoomOut: UIButton!
    @IBOutlet weak var btnTrafficOnOff: UIButton!
    @IBOutlet weak var btnStartDetection: UIButton! {
        didSet {
            btnStartDetection.layer.cornerRadius = 8
            btnStartDetection.layer.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.6392156863, blue: 1, alpha: 0.95)
        }
    }
    @IBOutlet weak var btnMyCurrentLocation: UIButton!
    @IBOutlet weak var btnWorkoutList: UIButton! {
        didSet {
            btnWorkoutList.layer.cornerRadius = 8
            btnWorkoutList.layer.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.6392156863, blue: 1, alpha: 0.95)
        }
    }
    @IBOutlet var btnCollection: [UIButton]! {
        didSet {
            for btn in btnCollection {
                btn.layer.cornerRadius = 25
                btn.layer.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.6392156863, blue: 1, alpha: 0.95)
            }
        }
    }
    
    // MARK: - Properties
    let homeCoordinate = CLLocationCoordinate2D(latitude: 55.752455, longitude: 37.623033)
    let geocoder = CLGeocoder()
    
    var locationService = LocationService.shared
    var workoutService = WorkoutService()
    var trackService = TrackService()
    var currentWorkout: Workout?
    
    var searchMarker: GMSMarker?
    var marker: GMSMarker?
    let placeInfoMarker = GMSMarker()
    
    var currentZoomLevel: Float = 17
    let zoomLevelStep: Float = 1
    
    var searchController: UISearchController?
    var isSearchBarEmpty: Bool {
      return searchController?.searchBar.text?.isEmpty ?? true
    }
    
    var routePath: GMSMutablePath?
    var workoutCount: Int = 0
    var route: GMSPolyline? {
        didSet {
            route?.strokeColor = #colorLiteral(red: 0.1803921569, green: 0.6392156863, blue: 1, alpha: 0.95)
            route?.strokeWidth = 5
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
        locationService.delegate = self
        workoutCount = workoutService.count()
        configureSearch()
        configureMap()
        
    }
    
    // MARK: - Methods
    func configureSearch() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let resultViewController = storyboard.instantiateViewController(identifier: "resultViewController") as? ResultViewController {
            searchController = UISearchController(searchResultsController: resultViewController)
            guard let searchController = searchController else { return }
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
    
    func configureMap() {
        let camera = GMSCameraPosition.init(target: homeCoordinate, zoom: currentZoomLevel)
        mapView.camera = camera
        mapView.mapType = .hybrid
    }
    
    func addMarker() {
        locationService.currentLocation()
        let location = locationService.locationManager?.location?.coordinate ?? homeCoordinate
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
    
    func startWorkout() {
        UIView.animate(withDuration: 0.29, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.btnStartDetection.setTitle("Остановить тренировку", for: .normal)
            self.btnStartDetection.layer.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 0.95)
        }, completion: nil)
    }
    
    func stopWorkout() {
        UIView.animate(withDuration: 0.29, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.btnStartDetection.setTitle("Начать тренировку", for: .normal)
            self.btnStartDetection.layer.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.6392156863, blue: 1, alpha: 0.95)
        }, completion: nil)
    }
    
    func configureRoutePath() {
        route?.map = nil
        routePath = nil
        route = GMSPolyline()
        route?.map = mapView
        routePath = GMSMutablePath()
    }
    
    func loadPathFromWorkoutWith(activityID: String) {
        guard let paths = trackService.listBy(workoutID: activityID), !paths.isEmpty else { return }
        guard let firstCoordinate = paths.first else { return }
        
        currentWorkout = workoutService.loadBy(workoutID: activityID)
        
        mapView.animate(toLocation: CLLocationCoordinate2D(latitude: firstCoordinate.latitude,
                                                           longitude: firstCoordinate.longitude)
        )
        
        configureRoutePath()
                
        paths.forEach { path in
            routePath?.add(CLLocationCoordinate2D(latitude: path.latitude, longitude: path.longitude))
            route?.path = routePath
        }
    }

    // MARK: - Actions
    @IBAction func goHome(_ sender: Any) {
        removeMarker()
        let marker = GMSMarker(position: homeCoordinate)
        marker.title = "Home"
        marker.snippet = "Широта: \(homeCoordinate.latitude)\nДолгота: \(homeCoordinate.longitude)"
        marker.icon = GMSMarker.markerImage(with: .green)
        marker.map = mapView
        mapView.animate(toLocation: homeCoordinate)
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
        if marker == nil {
            addMarker()
        } else {
            removeMarker()
        }
    }
    
    @IBAction func btnMyCurrentLocationClicked(_ sender: Any) {
        guard locationService.isUpdateLocationRestricted == false else {
            showErrorMessage(message: "Для работы данной функции необходимо разрешить отслеживание местоположения")
            return
        }
        
        locationService.currentLocation()
        
    }
    
    @IBAction func btnStartDetectionClicked(_ sender: Any) {
        guard locationService.isUpdateLocationRestricted == false else {
            showErrorMessage(message: "Для работы данной функции необходимо разрешить отслеживание местоположения")
            return
        }
        
        if locationService.isUpdateLocationStarted == false {
            currentWorkout = workoutService.start()
            locationService.start()
            workoutCount += 1
        } else {
            currentWorkout = workoutService.stop()
            locationService.stop()
        }
    }
    
    @IBAction func btnWorkoutListClicked(_ sender: Any) {
        guard workoutCount > 0 else {
            showErrorMessage(message: "Нет записанных тренировок.")
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let destination = storyboard.instantiateViewController(identifier: "workoutListController") as? WorkoutListViewController else { return }
        
        destination.didWorkoutSelect = { [weak self] activityID in
            self?.loadPathFromWorkoutWith(activityID: activityID)
        }
        
        destination.didWorkoutDelete = { [weak self] activityID in
            guard let self = self else { return }
            
            if self.currentWorkout?.activityID == activityID {
                self.configureRoutePath()
                self.currentWorkout = nil
            }
            
            if self.workoutService.removeBy(workoutID: activityID) {
                self.trackService.removePathWith(workoutID: activityID)
                self.workoutCount -= 1
            }
        }
        
        navigationController?.present(destination, animated: true)
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
        placeInfoMarker.snippet = "Широта: \(location.latitude)\nДолгота: \(location.longitude)"
        placeInfoMarker.position = location
        placeInfoMarker.title = name
        placeInfoMarker.opacity = 0
        placeInfoMarker.infoWindowAnchor.y = 0.4
        placeInfoMarker.map = mapView
        mapView.selectedMarker = placeInfoMarker
        mapView.animate(toLocation: location)
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

// MARK: - LocationServiceDelegate
extension MapViewController: LocationServiceDelegate {
    func willUpdateLocationStarted() {
        startWorkout()
        configureRoutePath()
    }
    
    func willUpdateLocationStopped() {
        stopWorkout()
    }
    
    func didLocationChanged(_ manager: CLLocationManager, coordinate: CLLocationCoordinate2D?) {
        guard let coordinate = coordinate else { return }
        mapView.animate(toLocation: coordinate)
              
        routePath?.add(coordinate)
        route?.path = routePath
        
        trackService.track(workout: currentWorkout, coordinate: coordinate)
    }
    
    func didUpdateIsInactive(_ manager: CLLocationManager, coordinate: CLLocationCoordinate2D?) { }
    
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

