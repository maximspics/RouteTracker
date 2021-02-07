//
//  LocationService.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 21.01.2021.
//

import UIKit
import CoreLocation

protocol LocationServiceDelegate {
    func willUpdateLocationStarted()
    func willUpdateLocationStopped()
    func didLocationChanged(_ manager: CLLocationManager, coordinate: CLLocationCoordinate2D?)
    func didUpdateIsInactive(_ manager: CLLocationManager, coordinate: CLLocationCoordinate2D?)
    func selectAddres(_ coordinate: CLLocationCoordinate2D?)
}

class LocationService: NSObject {
    static let shared = LocationService()
    private(set) var locationManager: CLLocationManager?
    var delegate: LocationServiceDelegate?
    
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
    
    private(set) var isWorkoutStarted: Bool = false
    private(set) var firstKnownLocation: CLLocationCoordinate2D?
    private(set) var lastKnownLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestAlwaysAuthorization()
            locationManager?.allowsBackgroundLocationUpdates = true
            locationManager?.pausesLocationUpdatesAutomatically = false
            locationManager?.startMonitoringSignificantLocationChanges()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        }
        
    }
    
    func start() {
        firstKnownLocation = nil
        lastKnownLocation = nil
        
        isWorkoutStarted = true
        locationManager?.startUpdatingLocation()
        delegate?.willUpdateLocationStarted()
    }
    
    func stop() {
        firstKnownLocation = nil
        lastKnownLocation = nil
        
        isWorkoutStarted = false
        locationManager?.stopUpdatingLocation()
        delegate?.willUpdateLocationStopped()
    }
    
    func stillActive(coordinate: CLLocationCoordinate2D?) {
        if (coordinate?.longitude == lastKnownLocation?.longitude && coordinate?.latitude == lastKnownLocation?.latitude) {
            
        }
        
        lastKnownLocation = coordinate
        
        if firstKnownLocation == nil {
            firstKnownLocation = coordinate
        }
    }
    
    func currentLocation() {
        locationManager?.requestLocation()
    }
    
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        stillActive(coordinate: locations.last?.coordinate)
        
        delegate?.didLocationChanged(manager, coordinate: locations.last?.coordinate)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
