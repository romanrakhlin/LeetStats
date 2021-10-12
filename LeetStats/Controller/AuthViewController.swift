//
//  AuthViewController.swift
//  LeetStats
//
//  Created by Roman Rakhlin on 10.10.2021.
//

import UIKit

class AuthViewController: UIViewController {
    
    let networkManager = NetworkManager()
    var stats: Stats?
    let defaults = UserDefaults.standard // for UserDefaults

    @IBOutlet weak var usernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func authButtonPressed(_ sender: UIButton) {
        // getting data from API
        if let username = usernameTextField.text {
            if username != "" {
                networkManager.performRequest(with: username, completed: { newStats in
                    self.stats = newStats // save all stats
                    self.stats!.username = username // save username independently
                    if let safeStats = self.stats {
                        switch safeStats.status {
                        case "success":
                            // save stats to UserDefaults
                            let encoder = JSONEncoder()
                            if let encoded = try? encoder.encode(self.stats) {
                                self.defaults.set(encoded, forKey: "SavedStats")
                                self.defaults.synchronize()
                            }
                            
                            // go to the ProfileViewCOntroller
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "profileSegue", sender: self)
                            }
                        case "error":
                            self.showErrorAlert(with: "Wrong username")
                        default:
                            self.showErrorAlert(with: "Something Went Wrong")
                        }
                    } else {
                        self.showErrorAlert(with: "Invalid Input")
                    }
                })
            } else {
                showErrorAlert(with: "Enter your username")
            }
        }
    }
    
    func showErrorAlert(with errorText: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: errorText, message: "It's important!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileSegue" {
            if let destinationVC = segue.destination as? ProfileViewController {
                destinationVC.stats = stats
                destinationVC.calendarSubmissions = stats!.submissionCalendar
            }
        }
    }
}
