import Fluent

struct CreateUsers: Migration {
    func prepare(on database: Database) -> EventLoopFuture<()> {
        database.schema(User.schema)
                .field("id", .uuid, .identifier(auto: true))
                .field("username", .string, .required)
                .unique(on: "username")
                .field("password_hash", .string, .required)
                .field("created_at", .datetime, .required)
                .field("expired_at", .datetime, .required)
                .create()
    }

    func revert(on database: Database) -> EventLoopFuture<()> {
        database.schema(User.schema).delete()
    }
}