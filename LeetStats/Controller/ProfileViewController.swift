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
    let networkManager = NetworkManager() // to make requests
    
    // views
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var easyView: UIView!
    @IBOutlet weak var mediumView: UIView!
    @IBOutlet weak var hardView: UIView!
    @IBOutlet weak var donutChartView: DonutChartView!
    
    // labels
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var easyLabel: UILabel!
    @IBOutlet weak var mediumLabel: UILabel!
    @IBOutlet weak var hardLabel: UILabel!
    @IBOutlet weak var rankingLabel: UILabel!
    @IBOutlet weak var reputationLabel: UILabel!
    @IBOutlet weak var contributionPointsLabel: UILabel!
    @IBOutlet weak var acceptanceLabel: UILabel!
    
    // images
    @IBOutlet weak var rankingImage: UIImageView!
    @IBOutlet weak var reputationImage: UIImageView!
    @IBOutlet weak var contributionsPointsImage: UIImageView!
    
    var activityIndicator = UIActivityIndicatorView(style: .large) // for indicator
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting up spinner
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        activityIndicator.center = self.view.center
        activityIndicator.backgroundColor = (UIColor (white: 0.3, alpha: 0.8))
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.layer.cornerRadius = 10
        view.addSubview(activityIndicator)
        
        // check if already in userdefaults
        // then set stats var from user defaults and go the profile controller
        if let savedStats = defaults.object(forKey: "SavedStats") as? Data {
            let decoder = JSONDecoder()
            if let loadedStats = try? decoder.decode(Stats.self, from: savedStats) {
                // check if username exists
                guard let username = loadedStats.username else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.activityIndicator.startAnimating()
                }
                
                // making new request to get new data
                networkManager.performRequest(with: username, completed: { newStats in
                    self.stats = newStats // save all stats
                    self.calendarSubmissions = self.stats!.submissionCalendar
                    self.stats!.username = username // save username independently

                    // save stats to UserDefaults
                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(self.stats) {
                        self.defaults.set(encoded, forKey: "SavedStats")
                        self.defaults.synchronize()
                    }

                    // go to the ProfileViewCOntroller
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        
                        self.submissions = self.setAllSubmission()
                        let calendarMainView = CalendarView(frame: CGRect(x: 0, y: 0, width: self.calendarView.frame.width, height: self.calendarView.frame.height), data: self.submissions)
                        self.calendarView.addSubview(calendarMainView)
                        calendarMainView.translatesAutoresizingMaskIntoConstraints = false
                        NSLayoutConstraint.activate([
                            calendarMainView.topAnchor.constraint(equalTo: self.calendarView.topAnchor),
                            calendarMainView.bottomAnchor.constraint(equalTo: self.calendarView.bottomAnchor),
                            calendarMainView.leadingAnchor.constraint(equalTo: self.calendarView.leadingAnchor),
                            calendarMainView.trailingAnchor.constraint(equalTo: self.calendarView.trailingAnchor),
                        ])
                        
                        // set values to labels
                        self.usernameLabel.text = self.stats.username!
                        self.totalLabel.text = String(self.stats.totalSolved) + " / " + String(self.stats.totalQuestions)
                        self.easyLabel.text = String(self.stats.easySolved) + " / " + String(self.stats.totalEasy)
                        self.mediumLabel.text = String(self.stats.mediumSolved) + " / " + String(self.stats.totalMedium)
                        self.hardLabel.text = String(self.stats.hardSolved) + " / " + String(self.stats.totalHard)
                        self.rankingLabel.text = "Ranking: \(String(self.stats.ranking))"
                        self.reputationLabel.text = "Reputation: \(String(self.stats.reputation))"
                        self.contributionPointsLabel.text = "Contribution Points: \(String(self.stats.contributionPoints))"
                        
                        // load donut chart view
                        let values : [CGFloat] = [self.stats.acceptanceRate / 100, 1 - self.stats.acceptanceRate / 100]
                        print(values)
                        let colors: [UIColor] = [.systemGreen, .white]
                        let entries = values.enumerated().map{ (index, value) in
                            return DonutChartEntry(value: value, color: colors[index])
                        }
                        self.donutChartView.configureView(entries: entries, centerLabelText: "\(self.stats.acceptanceRate)% / 100%", animate: true)
                    }
                })
            }
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "authSegue", sender: self)
            }
        }
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // round
        totalView.layer.cornerRadius = totalView.frame.size.height / 5
        easyView.layer.cornerRadius = easyView.frame.size.height / 5
        mediumView.layer.cornerRadius = mediumView.frame.size.height / 5
        hardView.layer.cornerRadius = hardView.frame.size.height / 5
        
        // shadows views
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
        
        donutChartView.layer.shadowColor = UIColor.black.cgColor
        donutChartView.layer.shadowOpacity = 0.2
        donutChartView.layer.shadowOffset = .zero
        donutChartView.layer.shadowRadius = 2
        
        //shadows labels and images
        usernameLabel.layer.shadowColor = UIColor.black.cgColor
        usernameLabel.layer.shadowOpacity = 0.4
        usernameLabel.layer.shadowOffset = .zero
        usernameLabel.layer.shadowRadius = 4
        
        acceptanceLabel.layer.shadowColor = UIColor.black.cgColor
        acceptanceLabel.layer.shadowOpacity = 0.4
        acceptanceLabel.layer.shadowOffset = .zero
        acceptanceLabel.layer.shadowRadius = 8
        
        rankingImage.layer.shadowColor = UIColor.black.cgColor
        rankingImage.layer.shadowOpacity = 0.4
        rankingImage.layer.shadowOffset = .zero
        rankingImage.layer.shadowRadius = 8
        
        rankingLabel.layer.shadowColor = UIColor.black.cgColor
        rankingLabel.layer.shadowOpacity = 0.4
        rankingLabel.layer.shadowOffset = .zero
        rankingLabel.layer.shadowRadius = 8
        
        reputationImage.layer.shadowColor = UIColor.black.cgColor
        reputationImage.layer.shadowOpacity = 0.4
        reputationImage.layer.shadowOffset = .zero
        reputationImage.layer.shadowRadius = 8
        
        contributionsPointsImage.layer.shadowColor = UIColor.black.cgColor
        contributionsPointsImage.layer.shadowOpacity = 0.4
        contributionsPointsImage.layer.shadowOffset = .zero
        contributionsPointsImage.layer.shadowRadius = 8
        
        contributionPointsLabel.layer.shadowColor = UIColor.black.cgColor
        contributionPointsLabel.layer.shadowOpacity = 0.4
        contributionPointsLabel.layer.shadowOffset = .zero
        contributionPointsLabel.layer.shadowRadius = 8
        
        reputationLabel.layer.shadowColor = UIColor.black.cgColor
        reputationLabel.layer.shadowOpacity = 0.4
        reputationLabel.layer.shadowOffset = .zero
        reputationLabel.layer.shadowRadius = 8
    }
    
    @IBAction func logOutButtonPressed(_ sender: UIBarButtonItem) {
        defaults.removeObject(forKey: "SavedStats")
        defaults.synchronize()
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "authSegue", sender: self)
        }
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIBarButtonItem) {
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
