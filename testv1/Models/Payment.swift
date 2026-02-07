//
//  Payment.swift
//  Halfisies
//
//  Payment tracking model for subscription sharing
//

import Foundation

// MARK: - Payment Status
enum PaymentStatus: String, Codable, CaseIterable {
    case pending = "pending"           // Payment not yet made
    case awaitingConfirmation = "awaiting_confirmation"  // User claims paid, waiting for principal to confirm
    case confirmed = "confirmed"       // Principal confirmed payment received
    case overdue = "overdue"          // Payment is past due date
    case disputed = "disputed"         // There's a dispute about payment
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .awaitingConfirmation: return "Awaiting Confirmation"
        case .confirmed: return "Confirmed"
        case .overdue: return "Overdue"
        case .disputed: return "Disputed"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "FFD670"      // Golden
        case .awaitingConfirmation: return "70D6FF"  // Blue
        case .confirmed: return "4ECDC4"    // Green
        case .overdue: return "FF9770"      // Coral
        case .disputed: return "FF70A6"     // Pink
        }
    }
}

// MARK: - Payment Method
enum PaymentMethod: String, Codable, CaseIterable, Identifiable {
    case venmo = "Venmo"
    case paypal = "PayPal"
    case cashApp = "Cash App"
    case zelle = "Zelle"
    case bankTransfer = "Bank Transfer"
    case other = "Other"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .venmo: return "v.circle.fill"
        case .paypal: return "p.circle.fill"
        case .cashApp: return "dollarsign.circle.fill"
        case .zelle: return "z.circle.fill"
        case .bankTransfer: return "building.columns.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .venmo: return "3D95CE"
        case .paypal: return "003087"
        case .cashApp: return "00D632"
        case .zelle: return "6D1ED4"
        case .bankTransfer: return "1E3A5F"
        case .other: return "888888"
        }
    }
    
    var deepLinkBase: String? {
        switch self {
        case .venmo: return "venmo://paycharge"
        case .paypal: return "paypal://send"
        case .cashApp: return "cashapp://cash.app"
        case .zelle: return nil  // No universal deep link
        case .bankTransfer: return nil
        case .other: return nil
        }
    }
}

// MARK: - Payment Record
struct PaymentRecord: Identifiable, Codable {
    let id: String
    let listingId: String
    let requestId: String
    let payerId: String          // Co-subscriber who pays
    let payerName: String
    let recipientId: String      // Principal who receives
    let recipientName: String
    let amount: Double
    let dueDate: Date
    var status: PaymentStatus
    var paidDate: Date?
    var confirmedDate: Date?
    var paymentMethod: PaymentMethod?
    var notes: String?
    let createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        listingId: String,
        requestId: String,
        payerId: String,
        payerName: String,
        recipientId: String,
        recipientName: String,
        amount: Double,
        dueDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
        status: PaymentStatus = .pending,
        paidDate: Date? = nil,
        confirmedDate: Date? = nil,
        paymentMethod: PaymentMethod? = nil,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.listingId = listingId
        self.requestId = requestId
        self.payerId = payerId
        self.payerName = payerName
        self.recipientId = recipientId
        self.recipientName = recipientName
        self.amount = amount
        self.dueDate = dueDate
        self.status = status
        self.paidDate = paidDate
        self.confirmedDate = confirmedDate
        self.paymentMethod = paymentMethod
        self.notes = notes
        self.createdAt = createdAt
    }
    
    var isOverdue: Bool {
        status == .pending && Date() > dueDate
    }
    
    var formattedAmount: String {
        String(format: "$%.2f", amount)
    }
}

// MARK: - Payment Info (for listings)
struct PaymentInfo: Codable {
    var acceptedMethods: [PaymentMethod]
    var venmoUsername: String?
    var paypalEmail: String?
    var cashAppTag: String?
    var zelleEmail: String?
    var zellePhone: String?
    var bankDetails: String?
    var additionalNotes: String?
    
    init(
        acceptedMethods: [PaymentMethod] = [],
        venmoUsername: String? = nil,
        paypalEmail: String? = nil,
        cashAppTag: String? = nil,
        zelleEmail: String? = nil,
        zellePhone: String? = nil,
        bankDetails: String? = nil,
        additionalNotes: String? = nil
    ) {
        self.acceptedMethods = acceptedMethods
        self.venmoUsername = venmoUsername
        self.paypalEmail = paypalEmail
        self.cashAppTag = cashAppTag
        self.zelleEmail = zelleEmail
        self.zellePhone = zellePhone
        self.bankDetails = bankDetails
        self.additionalNotes = additionalNotes
    }
    
    func getPaymentHandle(for method: PaymentMethod) -> String? {
        switch method {
        case .venmo: return venmoUsername
        case .paypal: return paypalEmail
        case .cashApp: return cashAppTag
        case .zelle: return zelleEmail ?? zellePhone
        case .bankTransfer: return bankDetails
        case .other: return additionalNotes
        }
    }
}

// MARK: - Mock Data
extension PaymentRecord {
    static let mockPending = PaymentRecord(
        listingId: "listing-1",
        requestId: "request-1",
        payerId: "user-1",
        payerName: "Jane S.",
        recipientId: "owner-1",
        recipientName: "John D.",
        amount: 5.75,
        status: .pending
    )
    
    static let mockConfirmed = PaymentRecord(
        listingId: "listing-1",
        requestId: "request-2",
        payerId: "user-2",
        payerName: "Mike T.",
        recipientId: "owner-1",
        recipientName: "John D.",
        amount: 5.75,
        status: .confirmed,
        paidDate: Date().addingTimeInterval(-86400),
        confirmedDate: Date(),
        paymentMethod: .venmo
    )
}
