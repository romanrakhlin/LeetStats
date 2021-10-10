//
//  NetworkManager.swift
//  LeetStats
//
//  Created by Roman Rakhlin on 10.10.2021.
//

import Foundation

struct NetworkManager {
    let leetcodeAPI = "https://leetcode-stats-api.herokuapp.com/"

    func performRequest(with username: String, completed: @escaping (Stats?) -> Void) {
        let urlString = leetcodeAPI + username
        
        guard let url = URL(string: urlString) else {
            completed(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completed(nil)
                return
            }
            if let safeData = data {
                if let stats = parseJSON(statsData: safeData) {
                    completed(stats)
                    return
                }
            } else {
                completed(nil)
                return
            }
        }
        task.resume()
    }
    
    func parseJSON(statsData: Data) -> Stats? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(Stats.self, from: statsData)
            return decodedData
        } catch {
            return nil
        }
    }
}
