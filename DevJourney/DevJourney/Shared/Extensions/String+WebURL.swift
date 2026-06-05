//
//  String+WebURL.swift
//  DevJourney
//
//  Created by Codex on 05.06.26.
//

import Foundation

extension String {
    var webURL: URL? {
        let trimmedValue = trimmingCharacters(in: .whitespacesAndNewlines)

        guard
            let components = URLComponents(string: trimmedValue),
            let scheme = components.scheme?.lowercased(),
            ["http", "https"].contains(scheme),
            components.host?.isEmpty == false
        else {
            return nil
        }

        return components.url
    }
}
