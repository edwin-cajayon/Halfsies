//
//  Theme.swift
//  Halfisies
//
//  Cozy, warm, trust-first UI theme
//

import SwiftUI

// MARK: - Halfisies Theme Colors
struct HalfisiesTheme {
    
    // MARK: - Backgrounds
    static let appBackground = Color(hex: "FAF7F2")      // Warm off-white
    static let cardBackground = Color(hex: "F1EAE0")     // Soft sand
    static let cardBackgroundAlt = Color(hex: "F7F3EC")  // Slightly lighter sand
    
    // MARK: - Primary Brand
    static let primary = Color(hex: "C97C5D")            // Muted terracotta
    static let primaryLight = Color(hex: "D99B82")       // Lighter terracotta
    static let primaryDark = Color(hex: "B06A4D")        // Darker terracotta
    
    // MARK: - Secondary Accent
    static let secondary = Color(hex: "8FA99B")          // Sage green
    static let secondaryLight = Color(hex: "A8BDB0")     // Light sage
    
    // MARK: - Text Colors
    static let textPrimary = Color(hex: "2F2A26")        // Near-black warm
    static let textSecondary = Color(hex: "6B645E")      // Medium gray-brown
    static let textMuted = Color(hex: "9A928B")          // Muted labels
    
    // MARK: - Borders & Dividers
    static let border = Color(hex: "E4DDD3")             // Card borders
    static let divider = Color(hex: "DED6CB")            // Dividers
    
    // MARK: - Feedback
    static let success = Color(hex: "8FA99B")            // Sage green
    static let warning = Color(hex: "E0A458")            // Warm amber
    static let error = Color(hex: "C96B6B")              // Muted coral red
    
    // MARK: - Shadows
    static let shadowColor = Color(hex: "2F2A26").opacity(0.06)
    
    // MARK: - Corner Radii
    static let cornerSmall: CGFloat = 8
    static let cornerMedium: CGFloat = 12
    static let cornerLarge: CGFloat = 16
    static let cornerPill: CGFloat = 50
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers

// Soft card style
struct CozyCardStyle: ViewModifier {
    var padding: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerMedium)
            .shadow(color: HalfisiesTheme.shadowColor, radius: 8, x: 0, y: 2)
    }
}

// Primary button style
struct CozyPrimaryButtonStyle: ButtonStyle {
    var isFullWidth: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                configuration.isPressed 
                    ? HalfisiesTheme.primaryDark 
                    : HalfisiesTheme.primary
            )
            .cornerRadius(HalfisiesTheme.cornerPill)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// Secondary button style
struct CozySecondaryButtonStyle: ButtonStyle {
    var isFullWidth: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(HalfisiesTheme.primary)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background(HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerPill)
            .overlay(
                RoundedRectangle(cornerRadius: HalfisiesTheme.cornerPill)
                    .stroke(HalfisiesTheme.border, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// Small pill button
struct CozyPillButtonStyle: ButtonStyle {
    var color: Color = HalfisiesTheme.primary
    var isSelected: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? color : color.opacity(0.12))
            .cornerRadius(HalfisiesTheme.cornerPill)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
    }
}

// MARK: - View Extensions
extension View {
    func cozyCard(padding: CGFloat = 16) -> some View {
        modifier(CozyCardStyle(padding: padding))
    }
    
    func cozyPrimaryButton(fullWidth: Bool = true) -> some View {
        buttonStyle(CozyPrimaryButtonStyle(isFullWidth: fullWidth))
    }
    
    func cozySecondaryButton(fullWidth: Bool = true) -> some View {
        buttonStyle(CozySecondaryButtonStyle(isFullWidth: fullWidth))
    }
}

// MARK: - Text Styles
extension Text {
    func titleStyle() -> some View {
        self
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(HalfisiesTheme.textPrimary)
    }
    
    func headlineStyle() -> some View {
        self
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundColor(HalfisiesTheme.textPrimary)
    }
    
    func bodyStyle() -> some View {
        self
            .font(.system(size: 15, weight: .regular))
            .foregroundColor(HalfisiesTheme.textSecondary)
    }
    
    func captionStyle() -> some View {
        self
            .font(.system(size: 13, weight: .regular))
            .foregroundColor(HalfisiesTheme.textMuted)
    }
    
    func priceStyle() -> some View {
        self
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(HalfisiesTheme.primary)
    }
}
