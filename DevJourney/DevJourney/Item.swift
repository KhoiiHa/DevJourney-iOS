//
//  Item.swift
//  DevJourney
//
//  Created by Vu Minh Khoi Ha on 29.05.26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
