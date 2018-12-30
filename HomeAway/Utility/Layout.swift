//
//  Layout.swift
//  HomeAway
//
//  Created by YIN CHAO LIAO on 12/24/18.
//  Copyright © 2018 CHAO LIAO. All rights reserved.
//

import UIKit

class Layout {
    static func disableAutoresizingMaskConstrains(views: [UIView]) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}
