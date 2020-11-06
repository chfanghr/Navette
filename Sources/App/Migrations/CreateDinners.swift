import Fluent

struct CreateDinners: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Dinner.schema)
                .field("id", .uuid, .identifier(auto: true))
                .field("date", .datetime, .required)
                .field("host_id", .uuid, .references(User.schema, "id"), .required)
                .field("created_at", .datetime, .required)
                .field("updated_at", .datetime, .required)
                .field("location", .string, .required)
                .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Dinner.schema).delete()
    }


}
