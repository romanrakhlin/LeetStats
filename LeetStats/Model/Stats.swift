//
//  Stats.swift
//  LeetStats
//
//  Created by Roman Rakhlin on 10.10.2021.
//

import Foundation

// we are gonna use Decodable for decode JSON
// and Encodable to be able to save it to UserDefaults

struct Stats: Codable {
    var username: String? // its not in API but I gonna add it mannually aftet I get data
    var ranking: Int
    var totalMedium: Int
    var totalQuestions: Int
    var acceptanceRate: Double
    var easySolved: Int
    var totalSolved: Int
    var hardSolved: Int
//    var submissionCalendar: [SubmissionCalendar]?
    var mediumSolved: Int
    var contributionPoints: Int
    var totalEasy: Int
    var message: String
    var status: String
    var totalHard: Int
    var reputation: Int
}
