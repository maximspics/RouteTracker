//
//  WorkoutDetailViewController.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 28.01.2021.
//

import UIKit
import Kingfisher

class WorkoutDetailViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var imgMapScreenshot: UIImageView!
    @IBOutlet weak var btnShowOnMap: UIButton! {
        didSet {
            btnShowOnMap.layer.cornerRadius = 8
            btnShowOnMap.layer.backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.6392156863, blue: 1, alpha: 0.95)
        }
    }
    
    var service = WorkoutService()
    var activityID: String?
    var workoutTitle: String?
    var dateFormatter = DateFormatter()
    
    var didWorkoutSelect: ((String) -> Void)?
    
    private var edgeSwipeGestureRecognizer: UISwipeGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        
        guard let activityID = activityID else { return }
        guard let workout = service.loadBy(activityID: activityID) else { return }
        
        let totalSeconds = workout.secondsTotal % 60
        let totalMinutes = workout.secondsTotal / 60 % 60
        let totalHours = workout.secondsTotal / 3600
        
        var timeTotal: String { (totalHours == 0 ? "" : String(totalHours) + " ч. ") + (totalMinutes == 0 ? "" : String(totalMinutes) + " мин. ") + String(totalSeconds) + " сек." }
        
        lblTitle.text = workoutTitle ?? workout.title
        lblTitle.textColor = workoutTitle == "Тренировка" ? .black : #colorLiteral(red: 0.1803921569, green: 0.6392156863, blue: 1, alpha: 1)
        lblDate.text = "Дата: \(dateFormatter.string(from: workout.date))"
        lblDuration.text = "Время: \(timeTotal)"
        lblDistance.text = "Дистанция: \(String(Int(workout.pathLenght))) м."
        imgMapScreenshot.kf.setImage(with: URL(string: workout.urlScreenshot))
        
        edgeSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
        view.addGestureRecognizer(edgeSwipeGestureRecognizer!)
    }
    
    @objc func handleSwipes(gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.direction == .right {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func btnShowOnMapClicked(_ sender: Any) {
        guard let activityID = activityID else { return }
        dismiss(animated: true, completion: { [self] in
            didWorkoutSelect?(activityID)
        })
    }
    
    @IBAction func btnCloseClicked(_ sender: Any) {
        dismiss(animated: true)
    }
}
