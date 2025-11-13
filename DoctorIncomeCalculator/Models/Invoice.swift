import Foundation
import SwiftData

@Model
final class Invoice {
    @Attribute(.unique) var id: UUID
    var fakturowniaId: String? // Fakturownia platform ID
    var number: String?
    var sellDate: Date?
    var price: Double?
    var createdAt: Date
    var updatedAt: Date

    var employer: Employer?
    var user: User?

    init(fakturowniaId: String? = nil, number: String? = nil, sellDate: Date? = nil,
         price: Double? = nil, employer: Employer, user: User) {
        self.id = UUID()
        self.fakturowniaId = fakturowniaId
        self.number = number
        self.sellDate = sellDate
        self.price = price
        self.employer = employer
        self.user = user
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
