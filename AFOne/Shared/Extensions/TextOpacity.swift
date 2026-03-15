//
//  TextOpacity.swift
//  AFOne
//
//  Text opacity scale as SwiftUI ViewModifiers per SPEC.md Section 3
//

import SwiftUI

enum TextOpacityLevel: CaseIterable {
    case primary
    case high
    case secondary
    case tertiary
    case quaternary
    case fill
    
    var opacity: Double {
        switch self {
        case .primary:
            return 1.0
        case .high:
            return 0.85
        case .secondary:
            return 0.5
        case .tertiary:
            return 0.3
        case .quaternary:
            return 0.18
        case .fill:
            return 0.07
        }
    }
    
    var usesSemanticColor: Bool {
        switch self {
        case .primary, .secondary, .tertiary:
            return true
        default:
            return false
        }
    }
}

extension View {
    @ViewBuilder
    func textOpacity(_ level: TextOpacityLevel) -> some View {
        if level.usesSemanticColor {
            switch level {
            case .primary:
                self.foregroundStyle(.primary)
            case .secondary:
                self.foregroundStyle(.secondary)
            case .tertiary:
                self.foregroundStyle(.tertiary)
            default:
                self.opacity(level.opacity)
            }
        } else {
            self.opacity(level.opacity)
        }
    }
}
