//
//  Subscription.swift
//  Halfisies
//
//  Created by Edwin on 17/01/2026.
//

import Foundation
import SwiftUI

// MARK: - Service Category (Inspired by Spliiit's 10 categories)
enum ServiceCategory: String, Codable, CaseIterable {
    case streaming = "Streaming"
    case music = "Music"
    case gaming = "Gaming"
    case productivity = "Productivity"
    case cloud = "Cloud Storage"
    case news = "News & Media"
    case fitness = "Fitness"
    case learning = "Learning"
    case vpn = "VPN & Security"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .streaming: return "play.tv"
        case .music: return "music.note.list"
        case .gaming: return "gamecontroller"
        case .productivity: return "briefcase"
        case .cloud: return "cloud"
        case .news: return "newspaper"
        case .fitness: return "figure.run"
        case .learning: return "graduationcap"
        case .vpn: return "lock.shield"
        case .other: return "square.grid.2x2"
        }
    }
    
    var color: Color {
        switch self {
        case .streaming: return Color(hex: "E50914")
        case .music: return Color(hex: "1DB954")
        case .gaming: return Color(hex: "9147FF")
        case .productivity: return Color(hex: "0078D4")
        case .cloud: return Color(hex: "4285F4")
        case .news: return Color(hex: "FF6B35")
        case .fitness: return Color(hex: "FF2D55")
        case .learning: return Color(hex: "F9A825")
        case .vpn: return Color(hex: "00D26A")
        case .other: return Color(hex: "888888")
        }
    }
}

// MARK: - Subscription Service Type
enum SubscriptionService: String, Codable, CaseIterable {
    // Streaming
    case netflix = "Netflix"
    case disneyPlus = "Disney+"
    case hboMax = "HBO Max"
    case hulu = "Hulu"
    case amazonPrime = "Amazon Prime"
    case paramountPlus = "Paramount+"
    case peacock = "Peacock"
    case crunchyroll = "Crunchyroll"
    // Music
    case spotify = "Spotify"
    case appleMusic = "Apple Music"
    case youtube = "YouTube Premium"
    case tidal = "Tidal"
    case deezer = "Deezer"
    // Gaming
    case xboxGamePass = "Xbox Game Pass"
    case psPlus = "PlayStation Plus"
    case nintendoOnline = "Nintendo Online"
    case eaPlay = "EA Play"
    // Productivity
    case microsoft365 = "Microsoft 365"
    case dropbox = "Dropbox"
    case notion = "Notion"
    case canva = "Canva Pro"
    // Cloud
    case iCloud = "iCloud+"
    case googleOne = "Google One"
    // News
    case nytimes = "NY Times"
    case wsj = "Wall Street Journal"
    // Fitness
    case peloton = "Peloton"
    case strava = "Strava"
    // Learning
    case masterclass = "MasterClass"
    case skillshare = "Skillshare"
    case duolingoPlus = "Duolingo Plus"
    // VPN
    case nordVPN = "NordVPN"
    case expressvpn = "ExpressVPN"
    // Other
    case other = "Other"
    
    var icon: String {
        switch self {
        case .netflix: return "play.rectangle.fill"
        case .spotify: return "waveform"
        case .appleMusic: return "music.note"
        case .disneyPlus: return "sparkles"
        case .hboMax: return "film"
        case .youtube: return "play.circle.fill"
        case .amazonPrime: return "shippingbox.fill"
        case .hulu: return "tv"
        case .paramountPlus: return "mountain.2"
        case .peacock: return "bird"
        case .crunchyroll: return "sparkles.tv"
        case .tidal: return "waveform.circle"
        case .deezer: return "music.quarternote.3"
        case .xboxGamePass: return "xbox.logo"
        case .psPlus: return "playstation.logo"
        case .nintendoOnline: return "gamecontroller.fill"
        case .eaPlay: return "gamecontroller"
        case .microsoft365: return "doc.text"
        case .dropbox: return "archivebox"
        case .notion: return "note.text"
        case .canva: return "paintbrush"
        case .iCloud: return "icloud"
        case .googleOne: return "externaldrive.badge.icloud"
        case .nytimes: return "newspaper"
        case .wsj: return "chart.line.uptrend.xyaxis"
        case .peloton: return "figure.indoor.cycle"
        case .strava: return "figure.run"
        case .masterclass: return "play.square.stack"
        case .skillshare: return "lightbulb"
        case .duolingoPlus: return "character.book.closed"
        case .nordVPN, .expressvpn: return "lock.shield"
        case .other: return "app.fill"
        }
    }
    
    var brandColor: Color {
        switch self {
        case .netflix: return Color(hex: "E50914")
        case .spotify: return Color(hex: "1DB954")
        case .appleMusic: return Color(hex: "FC3C44")
        case .disneyPlus: return Color(hex: "113CCF")
        case .hboMax: return Color(hex: "B435F5")
        case .youtube: return Color(hex: "FF0000")
        case .amazonPrime: return Color(hex: "00A8E1")
        case .hulu: return Color(hex: "1CE783")
        case .paramountPlus: return Color(hex: "0064FF")
        case .peacock: return Color(hex: "000000")
        case .crunchyroll: return Color(hex: "F47521")
        case .tidal: return Color(hex: "000000")
        case .deezer: return Color(hex: "FEAA2D")
        case .xboxGamePass: return Color(hex: "107C10")
        case .psPlus: return Color(hex: "003791")
        case .nintendoOnline: return Color(hex: "E60012")
        case .eaPlay: return Color(hex: "FF4747")
        case .microsoft365: return Color(hex: "D83B01")
        case .dropbox: return Color(hex: "0061FF")
        case .notion: return Color(hex: "000000")
        case .canva: return Color(hex: "00C4CC")
        case .iCloud: return Color(hex: "3693F3")
        case .googleOne: return Color(hex: "4285F4")
        case .nytimes: return Color(hex: "000000")
        case .wsj: return Color(hex: "0080C3")
        case .peloton: return Color(hex: "DF1C2F")
        case .strava: return Color(hex: "FC4C02")
        case .masterclass: return Color(hex: "000000")
        case .skillshare: return Color(hex: "00FF84")
        case .duolingoPlus: return Color(hex: "58CC02")
        case .nordVPN: return Color(hex: "4687FF")
        case .expressvpn: return Color(hex: "DA3940")
        case .other: return Color(hex: "888888")
        }
    }
    
    var category: ServiceCategory {
        switch self {
        case .netflix, .disneyPlus, .hboMax, .hulu, .amazonPrime, .paramountPlus, .peacock, .crunchyroll:
            return .streaming
        case .spotify, .appleMusic, .youtube, .tidal, .deezer:
            return .music
        case .xboxGamePass, .psPlus, .nintendoOnline, .eaPlay:
            return .gaming
        case .microsoft365, .dropbox, .notion, .canva:
            return .productivity
        case .iCloud, .googleOne:
            return .cloud
        case .nytimes, .wsj:
            return .news
        case .peloton, .strava:
            return .fitness
        case .masterclass, .skillshare, .duolingoPlus:
            return .learning
        case .nordVPN, .expressvpn:
            return .vpn
        case .other:
            return .other
        }
    }
    
    // Typical individual monthly price (for savings calculation)
    var soloPrice: Double {
        switch self {
        case .netflix: return 15.49
        case .spotify: return 10.99
        case .appleMusic: return 10.99
        case .disneyPlus: return 13.99
        case .hboMax: return 15.99
        case .youtube: return 13.99
        case .amazonPrime: return 14.99
        case .hulu: return 17.99
        case .xboxGamePass: return 16.99
        case .psPlus: return 17.99
        case .microsoft365: return 9.99
        case .nordVPN: return 12.99
        default: return 12.99
        }
    }
    
    // Popular services for quick filtering
    static var popular: [SubscriptionService] {
        [.netflix, .spotify, .disneyPlus, .youtube, .hboMax, .amazonPrime, .xboxGamePass, .microsoft365]
    }
}

// MARK: - Subscription Listing
struct SubscriptionListing: Identifiable, Codable {
    let id: String
    let ownerId: String
    var ownerName: String
    var ownerRating: Double
    var ownerTrustScore: Int // Trust score like Spliiit
    var service: SubscriptionService
    var planName: String // "Family", "Premium Family", etc.
    var totalSeats: Int
    var availableSeats: Int
    var pricePerSeat: Double // Monthly price per seat
    var description: String
    var createdAt: Date
    var isActive: Bool
    var joinedCount: Int // How many people have joined this listing
    
    var occupiedSeats: Int {
        totalSeats - availableSeats
    }
    
    var monthlyRevenue: Double {
        Double(occupiedSeats) * pricePerSeat
    }
    
    // Calculate savings vs solo subscription
    var savingsPercent: Int {
        let soloPrice = service.soloPrice
        guard soloPrice > 0 else { return 0 }
        let savings = ((soloPrice - pricePerSeat) / soloPrice) * 100
        return max(0, Int(savings))
    }
    
    var monthlySavings: Double {
        max(0, service.soloPrice - pricePerSeat)
    }
    
    var yearlySavings: Double {
        monthlySavings * 12
    }
    
    init(
        id: String = UUID().uuidString,
        ownerId: String,
        ownerName: String,
        ownerRating: Double = 5.0,
        ownerTrustScore: Int = 50,
        service: SubscriptionService,
        planName: String,
        totalSeats: Int,
        availableSeats: Int,
        pricePerSeat: Double,
        description: String = "",
        createdAt: Date = Date(),
        isActive: Bool = true,
        joinedCount: Int = 0
    ) {
        self.id = id
        self.ownerId = ownerId
        self.ownerName = ownerName
        self.ownerRating = ownerRating
        self.ownerTrustScore = ownerTrustScore
        self.service = service
        self.planName = planName
        self.totalSeats = totalSeats
        self.availableSeats = availableSeats
        self.pricePerSeat = pricePerSeat
        self.description = description
        self.createdAt = createdAt
        self.isActive = isActive
        self.joinedCount = joinedCount
    }
}

// MARK: - Mock Data
extension SubscriptionListing {
    static let mockListings: [SubscriptionListing] = [
        SubscriptionListing(
            id: "1",
            ownerId: "owner-1",
            ownerName: "John D.",
            ownerRating: 4.8,
            ownerTrustScore: 92,
            service: .netflix,
            planName: "Premium",
            totalSeats: 4,
            availableSeats: 2,
            pricePerSeat: 5.50,
            description: "Sharing my Netflix Premium. 4K + HDR available. Fast, reliable sharing for over 2 years!",
            joinedCount: 47
        ),
        SubscriptionListing(
            id: "2",
            ownerId: "owner-2",
            ownerName: "Sarah M.",
            ownerRating: 4.9,
            ownerTrustScore: 88,
            service: .spotify,
            planName: "Family",
            totalSeats: 6,
            availableSeats: 3,
            pricePerSeat: 2.50,
            description: "Spotify Family plan with 3 open slots! No commitment needed.",
            joinedCount: 156
        ),
        SubscriptionListing(
            id: "3",
            ownerId: "owner-3",
            ownerName: "Mike R.",
            ownerRating: 5.0,
            ownerTrustScore: 95,
            service: .disneyPlus,
            planName: "Bundle",
            totalSeats: 4,
            availableSeats: 1,
            pricePerSeat: 4.00,
            description: "Disney+ Hulu ESPN bundle. Last slot! Super Trusted owner.",
            joinedCount: 89
        ),
        SubscriptionListing(
            id: "4",
            ownerId: "owner-4",
            ownerName: "Emma L.",
            ownerRating: 4.7,
            ownerTrustScore: 76,
            service: .youtube,
            planName: "Family",
            totalSeats: 5,
            availableSeats: 4,
            pricePerSeat: 3.50,
            description: "YouTube Premium Family - ad free everything, background play",
            joinedCount: 34
        ),
        SubscriptionListing(
            id: "5",
            ownerId: "owner-5",
            ownerName: "Alex K.",
            ownerRating: 4.6,
            ownerTrustScore: 71,
            service: .appleMusic,
            planName: "Family",
            totalSeats: 6,
            availableSeats: 2,
            pricePerSeat: 2.75,
            description: "Apple Music Family sharing - lossless audio included",
            joinedCount: 28
        ),
        SubscriptionListing(
            id: "6",
            ownerId: "owner-6",
            ownerName: "Chris P.",
            ownerRating: 4.9,
            ownerTrustScore: 85,
            service: .xboxGamePass,
            planName: "Ultimate",
            totalSeats: 5,
            availableSeats: 3,
            pricePerSeat: 4.50,
            description: "Xbox Game Pass Ultimate - 100s of games, EA Play included",
            joinedCount: 67
        ),
        SubscriptionListing(
            id: "7",
            ownerId: "owner-7",
            ownerName: "Dana W.",
            ownerRating: 4.8,
            ownerTrustScore: 82,
            service: .microsoft365,
            planName: "Family",
            totalSeats: 6,
            availableSeats: 4,
            pricePerSeat: 2.00,
            description: "Microsoft 365 Family - 1TB OneDrive per person!",
            joinedCount: 112
        ),
        SubscriptionListing(
            id: "8",
            ownerId: "owner-8",
            ownerName: "Ryan T.",
            ownerRating: 4.5,
            ownerTrustScore: 68,
            service: .nordVPN,
            planName: "Family",
            totalSeats: 6,
            availableSeats: 5,
            pricePerSeat: 2.25,
            description: "NordVPN 6-device plan. Protect your privacy!",
            joinedCount: 19
        )
    ]
}

// Color extension is defined in Theme/Theme.swift
