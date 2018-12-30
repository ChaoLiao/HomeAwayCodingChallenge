//
//  Performer.swift
//  HomeAway
//
//  Created by YIN CHAO LIAO on 12/26/18.
//  Copyright © 2018 CHAO LIAO. All rights reserved.
//

import Foundation

struct Performer: Decodable {
    
    let id: Int
    let type: String
    let name: String
    let image: String?
    
    enum ImageSize: String {
        case small
        case medium
        case large
        case huge
    }
    
    let images: [ImageSize.RawValue: String]
}
