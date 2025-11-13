import Foundation
import SwiftData

@Model
final class Transaction {
    @Attribute(.unique) var id: UUID
    var date: Date
    var amount: Double // >= 0
    var percent: Double // 0-100, tax/commission percentage
    var patientName: String?
    var transactionDescription: String?
    var createdAt: Date
    var updatedAt: Date

    var employer: Employer?
    var user: User?

    init(date: Date, amount: Double, percent: Double, patientName: String? = nil,
         transactionDescription: String? = nil, employer: Employer, user: User) {
        self.id = UUID()
        self.date = date
        self.amount = amount
        self.percent = percent
        self.patientName = patientName
        self.transactionDescription = transactionDescription
        self.employer = employer
        self.user = user
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // Calculate net income after deducting percentage
    var netIncome: Double {
        return amount * (1 - percent / 100)
    }

    // Calculate deducted amount
    var deductedAmount: Double {
        return amount * (percent / 100)
    }
}
