//
//  Event.swift
//  HomeAway
//
//  Created by YIN CHAO LIAO on 12/21/18.
//  Copyright © 2018 CHAO LIAO. All rights reserved.
//

import Foundation

struct Event: Decodable {

    let id: Int
    let title: String
    let isoDateLocal: String
    let venue: Venue
    let performers: [Performer]
    var isFavorited: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case isoDateLocal = "datetime_local"
        case venue
        case performers
    }
}

struct EventContainer: Decodable {
    let events: [Event]
}
