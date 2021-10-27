//
//  ProfileViewController.swift
//  LeetStats
//
//  Created by Roman Rakhlin on 10.10.2021.
//

import UIKit

class ProfileViewController: UIViewController {    
    
    var stats: Stats!
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
    @IBOutlet weak var streakLabel: UILabel!
    
    // images
    @IBOutlet weak var rankingImage: UIImageView!
    @IBOutlet weak var reputationImage: UIImageView!
    @IBOutlet weak var contributionsPointsImage: UIImageView!
    @IBOutlet weak var streakImage: UIImageView!
    
    private let activityIndicator = MaterialActivityIndicatorView() // for indicator
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide all UI elements
        switchAppearenceOfComponents(to: true)
        
        // setting up spinner
        setupActivityIndicatorView()
        self.activityIndicator.startAnimating()
        
        // check if already in userdefaults
        // then set stats var from user defaults and go the profile controller
        if let userDefaults = UserDefaults(suiteName: "group.com.romanrakhlin.LeetStats") {
            if let savedStats = userDefaults.object(forKey: "SavedStats") as? Data {
                let decoder = JSONDecoder()
                if let loadedStats = try? decoder.decode(Stats.self, from: savedStats) {
                    
                    // check if username exists
                    guard let username = loadedStats.username else {
                        return
                    }

                    // check for interner connection
                    if ConnectionManager.shared.hasConnectivity() {
                        // making new request to get new data
                        networkManager.performRequest(with: username, completed: { gotStats in
                            // if we got nil while getting the data
                            guard let newStats = gotStats else {
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "authSegue", sender: self)
                                }
                                return
                            }
                            
                            self.stats = newStats // save all stats
                            self.calendarSubmissions = self.stats!.submissionCalendar
                            self.stats!.username = username // save username independently
                            let allYearSubmissions = self.setAllSubmission()
                            self.submissions = allYearSubmissions
                            self.stats!.streak = self.getStreakNum(array: allYearSubmissions)

                            // save stats to UserDefaults
                            let encoder = JSONEncoder()
                            if let encoded = try? encoder.encode(self.stats) {
                                userDefaults.setValue(encoded, forKey: "SavedStats")
                                userDefaults.synchronize()
                            }
                            
                            // settiin u pthe UI
                            DispatchQueue.main.async {
                                self.prepareComponentsOnView()
                                
                                // show all elements
                                self.switchAppearenceOfComponents(to: false)
                                
                                // stop the activity indicator
                                self.activityIndicator.stopAnimating()
                            }
                        })
                    } else {
                        self.stats = loadedStats // save all stats
                        self.calendarSubmissions = self.stats!.submissionCalendar
                        self.stats!.username = username // save username independently
                        let allYearSubmissions = self.setAllSubmission() // all submissions during the day
                        self.submissions = allYearSubmissions
                        self.stats!.streak = self.getStreakNum(array: allYearSubmissions)
                        
                        // settiin u pthe UI
                        DispatchQueue.main.async {
                            self.prepareComponentsOnView()
                            
                            // show all elements
                            self.switchAppearenceOfComponents(to: false)
                            
                            // stop the activity indicator
                            self.activityIndicator.stopAnimating()
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "authSegue", sender: self)
                    return
                }
            }
        }
    }
    
    // prepapre components on view
    private func prepareComponentsOnView() {
        DispatchQueue.main.async {
            let calendarMainView = CalendarView(frame: CGRect(x: 0, y: 0, width: self.calendarView.frame.width, height: self.calendarView.frame.height), data: self.submissions.suffix(84))
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
            self.streakLabel.text = String(self.stats.streak!)
            
            // load donut chart view
            let values : [CGFloat] = [self.stats.acceptanceRate / 100, 1 - self.stats.acceptanceRate / 100]
            print(values)
            let colors: [UIColor] = [.systemGreen, UIColor(named: "AcceptanceColor")!]
            let entries = values.enumerated().map{ (index, value) in
                return DonutChartEntry(value: value, color: colors[index])
            }
            self.donutChartView.configureView(entries: entries, centerLabelText: "\(self.stats.acceptanceRate)% / 100%", animate: true)
        }
    }
    
    // when we load data we have to hide all UI compoinents and then show them again
    private func switchAppearenceOfComponents(to value: Bool) {
        // views
        calendarView.isHidden = value
        totalView.isHidden = value
        easyView.isHidden = value
        mediumView.isHidden = value
        hardView.isHidden = value
        donutChartView.isHidden = value
        
        // labels
        usernameLabel.isHidden = value
        totalLabel.isHidden = value
        easyLabel.isHidden = value
        mediumLabel.isHidden = value
        hardLabel.isHidden = value
        rankingLabel.isHidden = value
        reputationLabel.isHidden = value
        contributionPointsLabel.isHidden = value
        acceptanceLabel.isHidden = value
        streakLabel.isHidden = value
        
        // images
        rankingImage.isHidden = value
        reputationImage.isHidden = value
        contributionsPointsImage.isHidden = value
        streakImage.isHidden = value
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // set viewcontroller's orientation to only PORTRAIT
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        
        // round
        totalView.layer.cornerRadius = totalView.frame.size.height / 5
        easyView.layer.cornerRadius = easyView.frame.size.height / 5
        mediumView.layer.cornerRadius = mediumView.frame.size.height / 5
        hardView.layer.cornerRadius = hardView.frame.size.height / 5
        calendarView.layer.cornerRadius = calendarView.frame.size.height / 5
        
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
        
        calendarView.layer.shadowColor = UIColor.black.cgColor
        calendarView.layer.shadowOpacity = 0.2
        calendarView.layer.shadowOffset = .zero
        calendarView.layer.shadowRadius = 2
    }
    
    @IBAction func logOutButtonPressed(_ sender: UIBarButtonItem) {
        if let userDefaults = UserDefaults(suiteName: "group.com.romanrakhlin.LeetStats") {
            userDefaults.removeObject(forKey: "SavedStats")
            userDefaults.synchronize()
        }
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "authSegue", sender: self)
        }
    }
    
    /*
     1. Find seconds passed from 1970 year and store it in todayInSecondsFrom1970
     2.
    */
    private func setAllSubmission() -> [Int] {
        // equal to 12*7=84 elemts by default
        
        // creating curretn date
        let currentDate = Date()
        
        // defining numbert of days in year
        let numberOfDaysInYear = 365
        
        // createing array of 0 * numberOfDaysInYear
        var submissions = [Int](repeating: 0, count: numberOfDaysInYear)
        
        // millisends from 1st jan 1970 year
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
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
    
    // func for adding streak property to Stats
    private func getStreakNum(array: [Int]) -> Int {
        var indexIterateFrom = array.count - 1
    
        // if last element is zero
        if array[array.count - 1] == 0 {
            // here is to possibilities
            // first - prelast is 0
            // second - prelast >0
            if array[array.count - 2] == 0 {
                return 0
            } else {
                indexIterateFrom = array.count - 2
            }
        }
        
        var count = 0
        
        while array[indexIterateFrom] != 0 {
            count += 1
            indexIterateFrom -= 1
            print(indexIterateFrom)
            if indexIterateFrom == -1 {
                break
            }
        }
        
        return count
        
//        let preparedArray = array
//        let reversedArray = preparedArray.reversed()
//
//        var count = 0
//
//        for i in reversedArray {
//            if i == 0 {
//                break
//            } else {
//                count += 1
//            }
//        }
//        return count
    }
}

// MARK: - Extension For Activity Indicator
private extension ProfileViewController {
    func setupActivityIndicatorView() {
        view.addSubview(activityIndicator)
        setupActivityIndicatorViewConstraints()
    }

    func setupActivityIndicatorViewConstraints() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
