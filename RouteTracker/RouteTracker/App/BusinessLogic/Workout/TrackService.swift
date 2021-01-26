//
//  TrackService.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 21.01.2021.
//

import Foundation
import CoreLocation
import GoogleMaps
import RealmSwift

protocol TrackServiceDelegate {
    func didUpdateTrackWith(error: Error)
}

class TrackService: NSObject {
    var delegate: TrackServiceDelegate?
    let service = RealmService.shared
    
    func track(workout: Workout?, coordinate: CLLocationCoordinate2D?) {
        guard let workout = workout, let coordinate = coordinate else { return }
        let path = Path(activityID: workout.activityID,
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude)
        
        do {
            try RealmService.shared.save(items: path)

        } catch let error {
            delegate?.didUpdateTrackWith(error: error)
        }
    }
    
    func listBy(workoutID: String) -> [Path]? {
        guard let trackList = service.get(Path.self)?
                .filter("activityID == '\(workoutID)'")
                .sorted(byKeyPath: "date", ascending: true) else {
            
            return nil
        }
        
        return trackList.map { $0 }
        
    }
    
    func removePathWith(workoutID: String) {
        if let trackList = service.get(Path.self)?
                                  .filter("activityID == '\(workoutID)'") {
            try? service.delete(items: trackList)
        }
    }
    
    func calculateDistance(from firstCoordinate: CLLocationCoordinate2D, to lastCoordinate: CLLocationCoordinate2D) -> Double {
        return Double(GMSGeometryDistance(firstCoordinate, lastCoordinate))
    }
}
