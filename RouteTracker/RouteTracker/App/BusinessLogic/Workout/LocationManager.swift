//
//  LocationService.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 21.01.2021.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject {
    static let shared = LocationManager()
    
    private override init() {
        super.init()
        configureLocationManager()
        
    }
    
    let locationManager = CLLocationManager()
    
    var isUpdateLocationRestricted: Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager().authorizationStatus {
            case .restricted, .denied:
                return true
            default:
                return false
            }
        }
        
        return true
    }
    
    private(set) var isWorkoutStarted: OwnObservable<Bool> = OwnObservable(false)
    private(set) var currentObservableLocation: OwnObservable<CLLocationCoordinate2D?> = OwnObservable(nil)
    
    var firstKnownLocation: CLLocationCoordinate2D?
    var lastKnownLocation: CLLocationCoordinate2D?
    
    private func configureLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func start() {
        firstKnownLocation = nil
        lastKnownLocation = nil
        
        isWorkoutStarted.value = true
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        firstKnownLocation = nil
        lastKnownLocation = nil
        
        isWorkoutStarted.value = false
        locationManager.stopUpdatingLocation()
    }
    
    func stillActive(coordinate: CLLocationCoordinate2D?) {
        if (coordinate?.longitude == lastKnownLocation?.longitude && coordinate?.latitude == lastKnownLocation?.latitude) {
            
        }
        
        lastKnownLocation = coordinate
        currentObservableLocation.value = coordinate
        
        if firstKnownLocation == nil {
            firstKnownLocation = coordinate
        }
    }
    
    func currentLocation() {
        locationManager.requestLocation()
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        stillActive(coordinate: locations.last?.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
