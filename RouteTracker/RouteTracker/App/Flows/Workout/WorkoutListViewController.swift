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
    
    var didWorkoutSelect: ((String) -> Void)?
    var didWorkoutDelete: ((String) -> Void)?
    var dateFormatter = DateFormatter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Список тренировок"

        workouts = service.list()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeZone = .current
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
            didWorkoutSelect?(workout.activityID)
            tableView.reloadData()
        }
        
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let workout = workouts?[indexPath.row] {
                workouts?.remove(at: indexPath.row)
                tableView.reloadData()
                
                didWorkoutDelete?(workout.activityID)
                
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension WorkoutListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        workouts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutCell", for: indexPath)
        
        if let workout = workouts?[indexPath.row] {
            cell.textLabel?.text = workout.title + " " + dateFormatter.string(from: workout.timestamp)
            cell.detailTextLabel?.text = "Время тренировки: " + workout.timeTotal
        }

        return cell
    }
}
