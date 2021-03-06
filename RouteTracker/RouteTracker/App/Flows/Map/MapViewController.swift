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
import RxSwift
import RxCocoa

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
    
    @IBOutlet weak var btnSettings: UIButton! {
        didSet {
            btnSettings.layer.cornerRadius = 8
            btnSettings.layer.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.6392156863, blue: 1, alpha: 0.95)
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
    
    var locationManager = LocationManager.shared
    var workoutService = WorkoutService()
    var trackService = TrackService()
    var currentWorkout: Workout?
    
    var searchMarker: GMSMarker?
    var marker: GMSMarker?
    let placeInfoMarker = GMSMarker()
    var currentPositionMarker = GMSMarker() {
        didSet {
            currentPositionMarker.map = mapView
        }
    }
    
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
            route?.strokeWidth = 6
        }
    }
    
    var onWorkoutList: (() -> Void)?
    var onWorkoutDetails: ((String, String) -> Void)?
    var onSettings: (() -> Void)?
    var onLogout: (() -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let userLogin = UserDefaults.standard.string(forKey: "userLogin") else { return }
        workoutCount = workoutService.count(userLogin)
        
        configureSearch()
        configureMap()
        configureLocationManager()
        configureWorkoutStatus()
        showWelcomeMessage()
    }
    
    // MARK: - Methods
    func showWelcomeMessage() {
        let message = UserDefaults.standard.string(forKey: "message")
        if message != "" {
            showSelfDisappearingMessage(message!)
            UserDefaults.standard.set("", forKey: "message")
        } else {
            guard let firstName = UserDefaults.standard.string(forKey: "firstName") else { return }
            showSelfDisappearingMessage("Привет, \(firstName)!\nПора на тренировку!")
        }
    }
    
    func configureSearch() {
        let storyboard = UIStoryboard(name: "Map", bundle: nil)
        if let resultViewController = storyboard.instantiateViewController(identifier: "ResultViewController") as? ResultViewController {
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
    
    func configureLocationManager() {
        let _ = locationManager.currentObservableLocation.addObservers(self, options: [.new]) { [weak self] (coordinate, _) in
            
            guard let coordinate = coordinate else { return }
            
            self?.mapView.animate(toLocation: coordinate)
            
            if self?.locationManager.isWorkoutStarted.value == true {
                if let imgData = UserDefaults.standard.data(forKey: "imageData"), let image = UIImage(data: imgData) {
                    let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: 40, height: 40), image: image, borderColor: .white, borderWidth: 2, radius: 20)
                    self?.currentPositionMarker.iconView = customMarker
                }
                self?.currentPositionMarker.position = coordinate
                self?.currentPositionMarker.map = self?.mapView
                self?.routePath?.add(coordinate)
                self?.route?.path = self?.routePath
                self?.trackService.track(workout: self?.currentWorkout, coordinate: coordinate)
            }
        }
    }
    
    private func configureWorkoutStatus() {
        locationManager.isWorkoutStarted.addObservers(self, options: [.new]) { [weak self] (value, _) in
            guard let self = self else { return }
            
            if value {
                self.isWorkout(started: value)
                self.configureRoutePath()
            } else {
                self.isWorkout(started: value)
                self.onWorkoutDetails?(self.currentWorkout?.activityID ?? "", "Тренировка завершена!")
            }
        }
    }
    
    func removeMarker() {
        marker?.map = nil
        marker = nil
    }
    
    func isWorkout(started: Bool) {
        if started {
            UIView.animate(withDuration: 0.29, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.btnStartDetection.setTitle("Закончить тренировку", for: .normal)
                self.btnStartDetection.layer.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 0.95)
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.29, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.btnStartDetection.setTitle("Начать тренировку", for: .normal)
                self.btnStartDetection.layer.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.6392156863, blue: 1, alpha: 0.95)
            }, completion: nil)
        }
    }
    
    func configureRoutePath() {
        route?.map = nil
        route = GMSPolyline()
        routePath = GMSMutablePath()
        route?.map = mapView
    }
    
    func loadPathFromWorkoutWith(activityID: String) {
        guard let paths = trackService.list(workoutID: activityID), !paths.isEmpty else { return }
        
        currentWorkout = workoutService.loadBy(activityID: activityID)
        configureRoutePath()
        
        var bounds = GMSCoordinateBounds()
        paths.forEach { path in
            routePath?.add(CLLocationCoordinate2D(latitude: path.latitude, longitude: path.longitude))
            route?.path = routePath
            bounds = bounds.includingCoordinate(CLLocationCoordinate2D(latitude: path.latitude, longitude: path.longitude))
        }
        
        mapView.setMinZoom(1, maxZoom: 17)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
        mapView.animate(with: update)
    }
    
    func onWorkoutSelect(_ activityID: String) {
        loadPathFromWorkoutWith(activityID: activityID)
    }
    
    func onWorkoutDelete(_ activityID: String) {
        if currentWorkout?.activityID == activityID {
            configureRoutePath()
            currentWorkout = nil
        }
        
        if workoutService.remove(activityID: activityID) {
            trackService.removePathWith(workoutID: activityID)
            workoutCount -= 1
        }
    }
    
    func saveAndStopWorkout() {
        var totalDistance: Double?
        if let lastLocation = locationManager.lastKnownLocation,
           let firstLocation = locationManager.firstKnownLocation {
            totalDistance = trackService.calculateDistance(from: firstLocation, to: lastLocation)
        }
        
        guard let userLogin = UserDefaults.standard.string(forKey: "userLogin") else { return }
        
        let image = mapView.takeScreenshot()
        let myTimeStamp = String(NSDate().timeIntervalSince1970)
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            let url = documentsDirectory.appendingPathComponent("Img_\(userLogin + "_" + myTimeStamp).jpeg")
            try? data.write(to: url)
            workoutService.stop(distance: totalDistance, userLogin: userLogin, urlScreenshot: "\(url)")
        } else {
            workoutService.stop(distance: totalDistance, userLogin: userLogin, urlScreenshot: "")
        }
        
        currentPositionMarker.map = nil
        locationManager.stop()
    }
    
    func logout() {
        UserDefaults.standard.set(false, forKey: "isLogin")
        guard let firstName = UserDefaults.standard.string(forKey: "firstName") else { return }
        let message = "\(firstName), до скорых встреч!"
        UserDefaults.standard.set(message, forKey: "message")
        onLogout?()
    }
    
    func selectAddress(_ coordinate: CLLocationCoordinate2D?) {
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
    
    func onAvatarChanged(_ avatar: UIImage?) {
        guard let avatar = avatar else { return }
        let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: 40, height: 40), image: avatar, borderColor: .white, borderWidth: 2, radius: 20)
        currentPositionMarker.iconView = customMarker
    }
    
    // MARK: - Actions
    @IBAction func goHome(_ sender: Any) {
        guard locationManager.isWorkoutStarted.value == false else {
            showSelfDisappearingMessage("Необходимо закончить тренировку")
            return
        }
        removeMarker()
        let marker = GMSMarker(position: homeCoordinate)
        marker.title = "Дом"
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
    
    @IBAction func btnLogoutClicked(_ sender: Any) {
        
        let actionVC = locationManager.isWorkoutStarted.value == false ? UIAlertController(title: "", message: "Вы уверены, что хотите выйти?", preferredStyle: .alert) : UIAlertController(title: "", message: "Вы хотите выйти и сохранить тренировку?", preferredStyle: .alert)
        
        let actionOK = locationManager.isWorkoutStarted.value == false ? UIAlertAction(title: "Да", style: .default) { [weak self] _ in self?.logout() } : UIAlertAction(title: "Сохранить и выйти", style: .default) { [weak self] _ in self?.saveAndStopWorkout()
            self?.logout()
        }
        
        let actionCancel = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        actionVC.addAction(actionOK)
        actionVC.addAction(actionCancel)
        present(actionVC, animated: true)
        
    }
    
    @IBAction func btnMyCurrentLocationClicked(_ sender: Any) {
        guard locationManager.isUpdateLocationRestricted == false else {
            showMessage(message: "Для работы данной функции необходимо разрешить отслеживание местоположения")
            return
        }
        
        if locationManager.isWorkoutStarted.value {
            showSelfDisappearingMessage("Отслеживание включено")
        } else {
            locationManager.currentLocation()
        }
    }
    
    @IBAction func btnStartWorkoutClicked(_ sender: Any) {
        guard locationManager.isUpdateLocationRestricted == false else {
            showMessage(message: "Для работы данной функции необходимо разрешить отслеживание местоположения")
            return
        }
        
        if locationManager.isWorkoutStarted.value == false {
            currentWorkout = workoutService.start()
            locationManager.start()
            workoutCount += 1
        } else {
            saveAndStopWorkout()
        }
    }
    
    @IBAction func btnWorkoutListClicked(_ sender: Any) {
        guard workoutCount > 0 else {
            showSelfDisappearingMessage("Нет записанных тренировок")
            return
        }
        
        guard locationManager.isWorkoutStarted.value == false else {
            showSelfDisappearingMessage("Необходимо закончить тренировку")
            return
        }
        
        onWorkoutList?()
    }
    
    @IBAction func btnSettingsClicked(_ sender: Any) {
        onSettings?()
    }
}

// MARK: - GMSMApViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if marker == nil {
            let marker = GMSMarker(position: coordinate)
            marker.snippet = "Широта: \(coordinate.latitude)\nДолгота: \(coordinate.longitude)"
            marker.icon = GMSMarker.markerImage(with: .green)
            marker.map = mapView
            mapView.animate(toLocation: coordinate)
            self.marker = marker
        } else {
            removeMarker()
        }
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
                    resultsController.mapViewController = self
                    resultsController.results = places
                    resultsController.update()
                }
            }
        }
    }
}
