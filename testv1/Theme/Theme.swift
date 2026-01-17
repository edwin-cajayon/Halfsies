//
//  Theme.swift
//  Halfsies
//
//  Vibrant, playful, friendly UI theme with Liquid Glass effects
//  Palette: https://coolors.co/palette/70d6ff-ff70a6-ff9770-ffd670
//

import SwiftUI

// MARK: - Halfsies Theme Colors
struct HalfisiesTheme {
    
    // MARK: - Backgrounds
    static let appBackground = Color(hex: "FFF9F5")      // Warm cream white
    static let cardBackground = Color(hex: "FFFFFF")     // Pure white cards
    static let cardBackgroundAlt = Color(hex: "FFF5F8")  // Soft pink tint
    
    // MARK: - Glass Colors
    static let glassWhite = Color.white.opacity(0.7)
    static let glassTint = Color(hex: "FF70A6").opacity(0.05)
    static let glassBorder = Color.white.opacity(0.8)
    static let glassHighlight = Color.white.opacity(0.9)
    
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
    static let glassShadow = Color.black.opacity(0.06)
    
    // MARK: - Corner Radii
    static let cornerSmall: CGFloat = 10
    static let cornerMedium: CGFloat = 14
    static let cornerLarge: CGFloat = 20
    static let cornerXLarge: CGFloat = 28
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
    
    // MARK: - Glass Gradients
    static let glassGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.85),
            Color.white.opacity(0.6)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let glassShine = LinearGradient(
        colors: [
            Color.white.opacity(0.5),
            Color.white.opacity(0.0)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let glassPinkTint = LinearGradient(
        colors: [
            Color(hex: "FF70A6").opacity(0.08),
            Color(hex: "70D6FF").opacity(0.05)
        ],
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

// MARK: - Liquid Glass Card Style
struct LiquidGlassCardStyle: ViewModifier {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = HalfisiesTheme.cornerLarge
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    // Blur background
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                    
                    // Glass gradient overlay
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(HalfisiesTheme.glassGradient)
                    
                    // Subtle color tint
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(HalfisiesTheme.glassPinkTint)
                    
                    // Inner highlight (top edge shine)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.8),
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )
                }
            )
            .shadow(color: HalfisiesTheme.glassShadow, radius: 12, x: 0, y: 6)
            .shadow(color: HalfisiesTheme.primary.opacity(0.05), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Liquid Glass Button Style
struct LiquidGlassButtonStyle: ButtonStyle {
    var color: Color = HalfisiesTheme.primary
    var isSelected: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    if isSelected {
                        // Filled glass
                        Capsule()
                            .fill(color.opacity(0.9))
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0.0)
                                    ],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    } else {
                        // Empty glass
                        Capsule()
                            .fill(.ultraThinMaterial)
                        Capsule()
                            .fill(Color.white.opacity(0.6))
                        Capsule()
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    }
                }
            )
            .shadow(color: isSelected ? color.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Liquid Glass Primary Button
struct LiquidGlassPrimaryButtonStyle: ButtonStyle {
    var isFullWidth: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                ZStack {
                    // Base gradient
                    Capsule()
                        .fill(HalfisiesTheme.primaryGradient)
                    
                    // Glass shine overlay
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.0),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // Inner border highlight
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                        .padding(1)
                }
            )
            .shadow(color: HalfisiesTheme.primary.opacity(0.4), radius: 12, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Liquid Glass Secondary Button
struct LiquidGlassSecondaryButtonStyle: ButtonStyle {
    var isFullWidth: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(HalfisiesTheme.primary)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background(
                ZStack {
                    Capsule()
                        .fill(.ultraThinMaterial)
                    
                    Capsule()
                        .fill(Color.white.opacity(0.7))
                    
                    Capsule()
                        .fill(HalfisiesTheme.primary.opacity(0.05))
                    
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    HalfisiesTheme.primary.opacity(0.4),
                                    HalfisiesTheme.primary.opacity(0.2)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )
                }
            )
            .shadow(color: HalfisiesTheme.glassShadow, radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Soft card style with pink shadow (legacy)
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

// Primary button style with gradient (legacy)
struct CozyPrimaryButtonStyle: ButtonStyle {
    var isFullWidth: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        LiquidGlassPrimaryButtonStyle(isFullWidth: isFullWidth).makeBody(configuration: configuration)
    }
}

// Secondary button style (legacy)
struct CozySecondaryButtonStyle: ButtonStyle {
    var isFullWidth: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        LiquidGlassSecondaryButtonStyle(isFullWidth: isFullWidth).makeBody(configuration: configuration)
    }
}

// Small pill button (legacy - now uses glass)
struct CozyPillButtonStyle: ButtonStyle {
    var color: Color = HalfisiesTheme.primary
    var isSelected: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        LiquidGlassButtonStyle(color: color, isSelected: isSelected).makeBody(configuration: configuration)
    }
}

// MARK: - View Extensions
extension View {
    func liquidGlassCard(padding: CGFloat = 16, cornerRadius: CGFloat = HalfisiesTheme.cornerLarge) -> some View {
        modifier(LiquidGlassCardStyle(padding: padding, cornerRadius: cornerRadius))
    }
    
    func cozyCard(padding: CGFloat = 16) -> some View {
        modifier(LiquidGlassCardStyle(padding: padding))
    }
    
    func liquidGlassPrimaryButton(fullWidth: Bool = true) -> some View {
        buttonStyle(LiquidGlassPrimaryButtonStyle(isFullWidth: fullWidth))
    }
    
    func liquidGlassSecondaryButton(fullWidth: Bool = true) -> some View {
        buttonStyle(LiquidGlassSecondaryButtonStyle(isFullWidth: fullWidth))
    }
    
    func cozyPrimaryButton(fullWidth: Bool = true) -> some View {
        buttonStyle(LiquidGlassPrimaryButtonStyle(isFullWidth: fullWidth))
    }
    
    func cozySecondaryButton(fullWidth: Bool = true) -> some View {
        buttonStyle(LiquidGlassSecondaryButtonStyle(isFullWidth: fullWidth))
    }
}

// MARK: - Liquid Glass Background
struct LiquidGlassBackground: View {
    var body: some View {
        ZStack {
            // Base warm background
            HalfisiesTheme.appBackground
            
            // Animated gradient blobs
            GeometryReader { geo in
                ZStack {
                    // Pink blob
                    Circle()
                        .fill(HalfisiesTheme.primary.opacity(0.15))
                        .blur(radius: 80)
                        .frame(width: 300, height: 300)
                        .offset(x: geo.size.width * 0.3, y: -50)
                    
                    // Blue blob
                    Circle()
                        .fill(HalfisiesTheme.secondary.opacity(0.12))
                        .blur(radius: 80)
                        .frame(width: 250, height: 250)
                        .offset(x: -geo.size.width * 0.2, y: geo.size.height * 0.3)
                    
                    // Golden blob
                    Circle()
                        .fill(HalfisiesTheme.golden.opacity(0.1))
                        .blur(radius: 60)
                        .frame(width: 200, height: 200)
                        .offset(x: geo.size.width * 0.4, y: geo.size.height * 0.6)
                }
            }
        }
        .ignoresSafeArea()
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

// MARK: - Glass Icon Badge
struct GlassIconBadge: View {
    let icon: String
    var color: Color = HalfisiesTheme.primary
    var size: CGFloat = 48
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            color.opacity(0.15),
                            color.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.2)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
            
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundColor(color)
        }
        .frame(width: size, height: size)
        .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Glass Discount Badge
struct GlassDiscountBadge: View {
    let percent: Int
    
    var body: some View {
        Text("-\(percent)%")
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                ZStack {
                    Capsule()
                        .fill(HalfisiesTheme.coral)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.0)
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            )
            .shadow(color: HalfisiesTheme.coral.opacity(0.4), radius: 4, x: 0, y: 2)
    }
}
