//
//  StatusBadgeView.swift
//  DevJourney
//

import SwiftUI

struct StatusBadgeView: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12), in: Capsule())
    }
}

#Preview {
    VStack(spacing: 12) {
        StatusBadgeView(title: "Offen", color: .blue)
        StatusBadgeView(title: "Erledigt", color: .green)
        StatusBadgeView(title: "Absage", color: .red)
    }
    .padding()
}
