import Fluent

struct CreateDinnerUserPivot: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DinnerInviteePivot.schema)
                .field("id", .uuid, .identifier(auto: true))
                .field("dinner_id", .uuid, .references(Dinner.schema, "id"))
                .field("invitee_id", .uuid, .references(User.schema, "id"))
                .unique(on: "invitee_id", "dinner_id")
                .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DinnerInviteePivot.schema).delete()
    }
}
