import Foundation
import SwiftData
import CryptoKit

@Model
final class User {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var email: String
    var passwordHash: String
    var name: String
    @Attribute(.unique) var nip: String? // Polish tax ID (10 digits, optional)
    var city: String?
    var street: String?
    var buildingNumber: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Employer.user)
    var employers: [Employer]?

    @Relationship(deleteRule: .cascade, inverse: \Transaction.user)
    var transactions: [Transaction]?

    @Relationship(deleteRule: .cascade, inverse: \Invoice.user)
    var invoices: [Invoice]?

    @Relationship(deleteRule: .cascade, inverse: \Product.user)
    var products: [Product]?

    init(email: String, password: String, name: String, nip: String? = nil,
         city: String? = nil, street: String? = nil, buildingNumber: String? = nil) {
        self.id = UUID()
        self.email = email
        self.passwordHash = User.hashPassword(password)
        self.name = name
        self.nip = nip
        self.city = city
        self.street = street
        self.buildingNumber = buildingNumber
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // Password hashing using SHA256
    static func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    func verifyPassword(_ password: String) -> Bool {
        return User.hashPassword(password) == self.passwordHash
    }

    func updatePassword(_ newPassword: String) {
        self.passwordHash = User.hashPassword(newPassword)
        self.updatedAt = Date()
    }
}
