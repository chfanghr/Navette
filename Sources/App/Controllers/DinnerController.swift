import Vapor
import Fluent

struct NewDinner {
    let date: Date
    let location: String
}

struct DinnerController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.group("dinner") {
            $0.post("new", use: create)
            $0.get(":dinnerId", use: getDinner)
            $0.put(":dinnerId", "invite", ":userId", use: inviteUser)
        }
    }

    fileprivate func create(req: Request) throws -> EventLoopFuture<Dinner.Public> {
        throw Abort(.notImplemented)
    }

    fileprivate func getDinner(req: Request) throws -> EventLoopFuture<Dinner.Public> {
        guard let dinnerId = req.parameters.get("dinnerId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return Dinner.query(on: req.db)
                .filter(\.$id == dinnerId)
                .with(\.$invitees)
                .with(\.$host)
                .first()
                .unwrap(or: Abort(.notFound))
                .flatMapThrowing {
                    try $0.asPublic()
                }
    }

    fileprivate func inviteUser(req: Request) throws -> EventLoopFuture<Dinner.Public> {
        guard
                let dinnerId = req.parameters.get("dinnerId", as: UUID.self),
                let inviteeId = req.parameters.get("userId", as: UUID.self)
                else {
            throw Abort(.badRequest)
        }

        var dinner: Dinner!

        return try queryDinner(dinnerId, req: req)
                .unwrap(or: Abort(.notFound))
                .flatMap { exDinner -> EventLoopFuture<User?> in
                    dinner = exDinner
                    return User
                            .query(on: req.db)
                            .filter(\.$id == inviteeId)
                            .first()
                }
                .unwrap(or: Abort(.notFound))
                .flatMap { invitee in
                    if dinner.invitees.contains(where: { $0.id == inviteeId }) {
                        guard let publicDinner = try? dinner.asPublic() else {
                            return req.eventLoop.future(error: Abort(.internalServerError))
                        }

                        return req.eventLoop.makeSucceededFuture(publicDinner)
                    }

                    return addInvitee(invitee: invitee, to: dinner, req: req)
                }
    }


    private func queryDinner(_ id: Dinner.IDValue, req: Request) throws -> EventLoopFuture<Dinner?> {
        Dinner.query(on: req.db)
                .filter(\.$id == id)
                .with(\.$invitees)
                .with(\.$host)
                .first()
    }

    private func addInvitee(invitee: User, to dinner: Dinner, req: Request) -> EventLoopFuture<Dinner.Public> {
        dinner.$invitees.attach(invitee, on: req.db).flatMap {
            dinner.save(on: req.db)
        }.flatMap {
            dinner.$invitees.load(on: req.db)
        }.flatMapThrowing {
            try dinner.asPublic()
        }
    }
}
