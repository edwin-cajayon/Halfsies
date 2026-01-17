//
//  HalfsiesLogo.swift
//  Halfsies
//
//  App logo component - two halves representing sharing
//

import SwiftUI

struct HalfsiesLogo: View {
    var size: CGFloat = 80
    var showShadow: Bool = true
    
    var body: some View {
        HStack(spacing: size * 0.03) {
            // Left half (Pink)
            Circle()
                .trim(from: 0.25, to: 0.75)
                .fill(
                    LinearGradient(
                        colors: [
                            HalfisiesTheme.primary,
                            HalfisiesTheme.primary.opacity(0.9)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.5, height: size)
                .rotationEffect(.degrees(180))
            
            // Right half (Blue)
            Circle()
                .trim(from: 0.25, to: 0.75)
                .fill(
                    LinearGradient(
                        colors: [
                            HalfisiesTheme.secondary,
                            HalfisiesTheme.secondaryLight
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.5, height: size)
        }
        .shadow(color: showShadow ? HalfisiesTheme.primary.opacity(0.2) : .clear, radius: 12, x: -4, y: 4)
        .shadow(color: showShadow ? HalfisiesTheme.secondary.opacity(0.2) : .clear, radius: 12, x: 4, y: 4)
    }
}

// Simple version - just two half circles
struct HalfsiesLogoSimple: View {
    var size: CGFloat = 80
    
    var body: some View {
        HStack(spacing: 2) {
            // Left half (Pink)
            HalfCircle()
                .fill(HalfisiesTheme.primary)
                .frame(width: size * 0.48, height: size)
            
            // Right half (Blue)  
            HalfCircle()
                .fill(HalfisiesTheme.secondary)
                .frame(width: size * 0.48, height: size)
                .rotationEffect(.degrees(180))
        }
    }
}

// Half circle shape
struct HalfCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.maxX, y: rect.midY),
            radius: rect.height / 2,
            startAngle: .degrees(90),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

// Logo with text
struct HalfsiesLogoWithText: View {
    var logoSize: CGFloat = 60
    var showTagline: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            HalfsiesLogoSimple(size: logoSize)
            
            VStack(spacing: 4) {
                Text("Halfsies")
                    .font(.system(size: logoSize * 0.4, weight: .bold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                if showTagline {
                    Text("Share more, spend less")
                        .font(.system(size: logoSize * 0.18))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        HalfsiesLogo(size: 100)
        
        HalfsiesLogoSimple(size: 80)
        
        HalfsiesLogoWithText(logoSize: 60, showTagline: true)
    }
    .padding()
    .background(HalfisiesTheme.appBackground)
}
