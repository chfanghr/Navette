import Vapor
import Fluent

final class DinnerInviteePivot: Model {
    static let schema = "dinner_invitee"

    @ID(key: "id")
    var id: UUID?

    @Parent(key: "dinner_id")
    var dinner: Dinner

    @Parent(key: "invitee_id")
    var invitee: User

    init() {
    }

    init(id: UUID? = nil, dinnerId: Dinner.IDValue, inviteeId: User.IDValue) {
        self.id = id
        self.$dinner.id = dinnerId
        self.$invitee.id = inviteeId
    }
}