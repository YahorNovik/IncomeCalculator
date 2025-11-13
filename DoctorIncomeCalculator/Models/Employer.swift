import Foundation
import SwiftData

@Model
final class Employer {
    @Attribute(.unique) var id: UUID
    var name: String
    var nip: String? // 10 digits, optional
    var city: String?
    var street: String?
    var buildingNumber: String?
    var defaultPercent: Double // 0-100, default commission/tax rate
    var createdAt: Date
    var updatedAt: Date

    var user: User?

    @Relationship(deleteRule: .cascade, inverse: \Transaction.employer)
    var transactions: [Transaction]?

    @Relationship(deleteRule: .cascade, inverse: \Invoice.employer)
    var invoices: [Invoice]?

    init(name: String, nip: String? = nil,
         city: String? = nil, street: String? = nil, buildingNumber: String? = nil,
         defaultPercent: Double = 0.0, user: User) {
        self.id = UUID()
        self.name = name
        self.nip = nip
        self.city = city
        self.street = street
        self.buildingNumber = buildingNumber
        self.defaultPercent = defaultPercent
        self.user = user
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var fullAddress: String {
        var components: [String] = []
        if let street = street { components.append(street) }
        if let buildingNumber = buildingNumber { components.append(buildingNumber) }
        if let city = city { components.append(city) }
        return components.joined(separator: ", ")
    }
}
