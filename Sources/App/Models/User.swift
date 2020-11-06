import Vapor
import Fluent

final class User: Model {
    struct Public: Content {
        let username: String
        let id: UUID
        let createdAt: Date?
        let updatedAt: Date?
    }

    static let schema = "users"

    @ID(key: "id")
    var id: UUID?

    @Field(key: "username")
    var username: String

    @Field(key: "password_hash")
    var passwordHash: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {
    }

    init(id: UUID? = nil, username: String, passwordHash: String) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
    }
}

extension User {
    static func create(from userSignup: UserSignup) throws -> User {
        User(username: userSignup.username,
                passwordHash: try Bcrypt.hash(userSignup.password))
    }

    func asPublic() throws -> Public {
        Public(username: username,
                id: try requireID(),
                createdAt: createdAt,
                updatedAt: updatedAt)
    }

    func createToken(source: SessionSource) throws -> Token {
        let calendar = Calendar(identifier: .gregorian)
        let expireDate = calendar.date(byAdding: .year, value: 1, to: Date())
        return try Token(userId: requireID(),
                token: [UInt8].random(count: 16).base64,
                source: source,
                expiresAt: expireDate)
    }
}