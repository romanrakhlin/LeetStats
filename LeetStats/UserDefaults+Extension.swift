//
//  UserDefaults+Extension.swift
//  LeetStats
//
//  Created by Roman Rakhlin on 23.10.2021.
//

import Foundation

typealias Key = UserDefaults.Keys

extension UserDefaults {
    static let appGroup = UserDefaults(suiteName: "group.com.romanrakhlin.LeetStats")!
}

extension UserDefaults {
    enum Keys: String {
        case luckyNumber
        case contacts
    }
}

extension UserDefaults {
    func setArray<Element>(_ array: [Element], forKey key: String) where Element: Encodable {
        let data = try? JSONEncoder().encode(array)
        set(data, forKey: key)
    }

    func getArray<Element>(forKey key: String) -> [Element]? where Element: Decodable {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode([Element].self, from: data)
    }
}
