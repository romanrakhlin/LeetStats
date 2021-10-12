//
//  ProfileViewController.swift
//  LeetStats
//
//  Created by Roman Rakhlin on 10.10.2021.
//

import UIKit

class ProfileViewController: UIViewController {
    
    var stats: Stats!
    let defaults = UserDefaults.standard // for UserDefaults
    var submissions: [Int]!
    var calendarSubmissions: [String: Int]!
    
    // views
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var easyView: UIView!
    @IBOutlet weak var mediumView: UIView!
    @IBOutlet weak var hardView: UIView!
    
    // labels
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var easyLabel: UILabel!
    @IBOutlet weak var mediumLabel: UILabel!
    @IBOutlet weak var hardLabel: UILabel!
    
    override func loadView() {
        super .loadView()
        
        submissions = setAllSubmission()
        let calendarMainView = CalendarView(frame: CGRect(x: 0, y: 0, width: calendarView.frame.width, height: calendarView.frame.height), data: submissions)
        calendarView.addSubview(calendarMainView)
        calendarMainView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarMainView.topAnchor.constraint(equalTo: calendarView.topAnchor),
            calendarMainView.bottomAnchor.constraint(equalTo: calendarView.bottomAnchor),
            calendarMainView.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor),
            calendarMainView.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set values to labels
        usernameLabel.text = stats.username!
        totalLabel.text = "Total " + String(stats.totalSolved)
        easyLabel.text = "Easy " + String(stats.easySolved)
        mediumLabel.text = "Medium " + String(stats.mediumSolved)
        hardLabel.text = "Hard " + String(stats.hardSolved)
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // round
        totalView.layer.cornerRadius = totalView.frame.size.height / 5
        easyView.layer.cornerRadius = easyView.frame.size.height / 5
        mediumView.layer.cornerRadius = mediumView.frame.size.height / 5
        hardView.layer.cornerRadius = hardView.frame.size.height / 5
        
        // shadows
        totalView.layer.shadowColor = UIColor.black.cgColor
        totalView.layer.shadowOpacity = 0.4
        totalView.layer.shadowOffset = .zero
        totalView.layer.shadowRadius = 8
        
        easyView.layer.shadowColor = UIColor.black.cgColor
        easyView.layer.shadowOpacity = 0.4
        easyView.layer.shadowOffset = .zero
        easyView.layer.shadowRadius = 8
        
        mediumView.layer.shadowColor = UIColor.black.cgColor
        mediumView.layer.shadowOpacity = 0.4
        mediumView.layer.shadowOffset = .zero
        mediumView.layer.shadowRadius = 8
        
        hardView.layer.shadowColor = UIColor.black.cgColor
        hardView.layer.shadowOpacity = 0.4
        hardView.layer.shadowOffset = .zero
        hardView.layer.shadowRadius = 8
    }
    
    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        defaults.removeObject(forKey: "SavedStats")
        defaults.synchronize()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
    }
    
    /*
     1. Find seconds passed from 1970 year and store it in todayInSecondsFrom1970
     2.
    */
    private func setAllSubmission() -> [Int] {
        // equal to 12*7=84 elemts by default
        var submissions = [Int](repeating: 0, count: 84)
        
        // creating curretn date
        let currentDate = Date()
        
        // millisends from 1st jan 1970 year
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT:0)!
        let todayInSecondsFrom1970 = calendar.startOfDay(for: currentDate).timeIntervalSince1970
        
        let day = 24 * 3600
        
        for (key, value) in calendarSubmissions {
            let index = (submissions.count - (Int(todayInSecondsFrom1970) - Int(key)!) / day) - 1
            if index >= 0 {
                submissions[index] = value
            }
        }
        
        return submissions
    }
}
