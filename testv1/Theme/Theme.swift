//
//  Theme.swift
//  Halfsies
//
//  Vibrant, playful, friendly UI theme
//  Palette: https://coolors.co/palette/70d6ff-ff70a6-ff9770-ffd670
//

import SwiftUI

// MARK: - Halfsies Theme Colors
struct HalfisiesTheme {
    
    // MARK: - Backgrounds
    static let appBackground = Color(hex: "FFF9F5")      // Warm cream white
    static let cardBackground = Color(hex: "FFFFFF")     // Pure white cards
    static let cardBackgroundAlt = Color(hex: "FFF5F8")  // Soft pink tint
    
    // MARK: - Primary Brand (Pink)
    static let primary = Color(hex: "FF70A6")            // Vibrant pink
    static let primaryLight = Color(hex: "FF99BF")       // Light pink
    static let primaryDark = Color(hex: "E85A90")        // Dark pink
    
    // MARK: - Secondary (Sky Blue)
    static let secondary = Color(hex: "70D6FF")          // Sky blue
    static let secondaryLight = Color(hex: "A0E4FF")     // Light blue
    static let secondaryDark = Color(hex: "50B8E0")      // Deeper blue
    
    // MARK: - Accent Colors
    static let coral = Color(hex: "FF9770")              // Warm coral
    static let golden = Color(hex: "FFD670")             // Golden yellow
    
    // MARK: - Text Colors
    static let textPrimary = Color(hex: "2D2D3A")        // Dark purple-gray
    static let textSecondary = Color(hex: "6B6B7B")      // Medium gray
    static let textMuted = Color(hex: "9D9DAD")          // Light gray
    
    // MARK: - Borders & Dividers
    static let border = Color(hex: "F0E8E8")             // Soft pink-gray border
    static let divider = Color(hex: "F5EDED")            // Light divider
    
    // MARK: - Feedback
    static let success = Color(hex: "70D6FF")            // Blue for success
    static let warning = Color(hex: "FFD670")            // Golden for warning
    static let error = Color(hex: "FF9770")              // Coral for error
    
    // MARK: - Shadows
    static let shadowColor = Color(hex: "FF70A6").opacity(0.08)
    
    // MARK: - Corner Radii
    static let cornerSmall: CGFloat = 10
    static let cornerMedium: CGFloat = 14
    static let cornerLarge: CGFloat = 20
    static let cornerPill: CGFloat = 50
    
    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "FF70A6"), Color(hex: "FF9770")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let secondaryGradient = LinearGradient(
        colors: [Color(hex: "70D6FF"), Color(hex: "A0E4FF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let sunsetGradient = LinearGradient(
        colors: [Color(hex: "FF70A6"), Color(hex: "FF9770"), Color(hex: "FFD670")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
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

// Soft card style with pink shadow
struct CozyCardStyle: ViewModifier {
    var padding: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerMedium)
            .shadow(color: HalfisiesTheme.shadowColor, radius: 12, x: 0, y: 4)
    }
}

// Primary button style with gradient
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
                Group {
                    if configuration.isPressed {
                        HalfisiesTheme.primaryDark
                    } else {
                        HalfisiesTheme.primaryGradient
                    }
                }
            )
            .cornerRadius(HalfisiesTheme.cornerPill)
            .shadow(color: HalfisiesTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
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
            .background(HalfisiesTheme.primary.opacity(0.1))
            .cornerRadius(HalfisiesTheme.cornerPill)
            .overlay(
                RoundedRectangle(cornerRadius: HalfisiesTheme.cornerPill)
                    .stroke(HalfisiesTheme.primary.opacity(0.3), lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// Small pill button
struct CozyPillButtonStyle: ButtonStyle {
    var color: Color = HalfisiesTheme.primary
    var isSelected: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? color : color.opacity(0.12))
            .cornerRadius(HalfisiesTheme.cornerPill)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
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
