//
//  LeaderboardEntry.swift
//  Leaderboardly
//
//  Created by Simon Bromberg on 2020-01-30.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import Foundation

struct LeaderboardEntry: Decodable, Hashable {
    let name: String
    let imageURL: URL
    let score: Float

    enum CodingKeys: String, CodingKey {
        case name
        case imageURL = "image_url"
        case score
    }
}
