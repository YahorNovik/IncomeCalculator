import Foundation
import SwiftData

@Model
final class Invoice {
    @Attribute(.unique) var id: UUID
    var number: String?
    var sellDate: Date?
    var price: Double?
    var createdAt: Date
    var updatedAt: Date

    var employer: Employer?
    var user: User?

    init(number: String? = nil, sellDate: Date? = nil,
         price: Double? = nil, employer: Employer, user: User) {
        self.id = UUID()
        self.number = number
        self.sellDate = sellDate
        self.price = price
        self.employer = employer
        self.user = user
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
