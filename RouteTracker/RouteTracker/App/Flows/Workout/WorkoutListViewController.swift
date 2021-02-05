//
//  WorkoutListViewController.swift
//  RouteTracker
//
//  Created by Maxim Safronov on 21.01.2021.
//

import UIKit

class WorkoutListViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    // MARK: - Properties
    var service = WorkoutService()
    var workouts: [Workout]? = []
    var filteredWorkouts: [Workout]? = []
    
    var onWorkoutDetails: ((String, String) -> Void)?
    var didWorkoutDelete: ((String) -> Void)?
    
    var dateFormatter = DateFormatter()
    
    private var edgeSwipeGestureRecognizer: UISwipeGestureRecognizer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Список тренировок"
        
        tableView.backgroundColor = .clear
        
        guard let userLogin = UserDefaults.standard.string(forKey: "userLogin") else { return }
        
        workouts = service.list(userLogin)
        
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        edgeSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
        view.addGestureRecognizer(edgeSwipeGestureRecognizer!)
    }
    
    @objc func handleSwipes(gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.direction == .right {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Private methods
    private func removeWorkoutItem(indexPath: IndexPath) {
        if let workout = workouts?[indexPath.row] {
            workouts?.remove(at: indexPath.row)
            tableView.reloadData()
            didWorkoutDelete?(workout.activityID)
        }
    }
    
    // MARK: - Actions
    @IBAction func btnCloseClicked(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate
extension WorkoutListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let workout = workouts?[indexPath.row] {
            dismiss(animated: true, completion: { [self] in
                onWorkoutDetails?(workout.activityID, workout.title)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeWorkoutItem(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let actionProvider: UIContextMenuActionProvider = { _ in
            return UIMenu(children: [
                UIAction(title: "Удалить", image: UIImage(systemName: "trash")) { _ in
                    self.removeWorkoutItem(indexPath: indexPath)
                }
            ])
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: actionProvider)
    }
}

// MARK: - UITableViewDataSource
extension WorkoutListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        workouts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutViewCell", for: indexPath)
        if let workout = workouts?[indexPath.row] {
            filteredWorkouts = workouts?.filter {$0.date == workout.date}
            let totalSeconds = workout.secondsTotal % 60
            let totalMinutes = workout.secondsTotal / 60 % 60
            let totalHours = workout.secondsTotal / 3600
            
            var timeTotal: String { (totalHours == 0 ? "" : String(totalHours) + " ч. ") + (totalMinutes == 0 ? "" : String(totalMinutes) + " мин. ") + String(totalSeconds) + " сек." }
            
            cell.textLabel?.text = workout.title + " " + dateFormatter.string(from: workout.date)
            cell.detailTextLabel?.text = "Время: " + timeTotal + " Дистанция: \(String(Int(workout.pathLenght))) м."
        }

        return cell
    }
}
