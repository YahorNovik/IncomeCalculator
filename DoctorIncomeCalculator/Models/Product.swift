import Foundation
import SwiftData

@Model
final class Product {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date

    var user: User?

    init(name: String, user: User) {
        self.id = UUID()
        self.name = name
        self.user = user
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
