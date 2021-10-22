//
//  ConnectionManager.swift
//  LeetStats
//
//  Created by Roman Rakhlin on 22.10.2021.
//

import Foundation
import Reachability

class ConnectionManager {

    static let shared = ConnectionManager()
    private init () {}

    func hasConnectivity() -> Bool {
        do {
            let reachability: Reachability = try Reachability()
            let networkStatus = reachability.connection
            
            switch networkStatus {
            case .unavailable:
                return false
            case .wifi, .cellular:
                return true
            }
        }
        catch {
            return false
        }
    }
}
