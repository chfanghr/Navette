import Vapor
import Fluent

struct UserSignup: Content {
    let username: String
    let password: String
}

struct NewSession: Content {
    let token: String
    let user: User.Public
}

extension UserSignup: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: .count(6...))
    }
}

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.grouped("user").post("signup", use: create)
    }

    fileprivate func create(req: Request) throws -> EventLoopFuture<NewSession> {
        try UserSignup.validate(content: req)
        let userSignup = try req.content.decode(UserSignup.self)
        let user = try User.create(from: userSignup)

        var token: Token!

        return checkIfUserExists(userSignup.username, req: req).flatMap { exists in
            guard !exists else {
                return req.eventLoop.future(error: UserError.usernameToken)
            }
            return user.save(on: req.db).flatMap {
                guard let newToken = try? user.createToken(source: .signup) else {
                    return req.eventLoop.future(error: Abort(.internalServerError))
                }
                token = newToken
                return token.save(on: req.db)
            }.flatMapThrowing {
                NewSession(token: token.value, user: try user.asPublic())
            }
        }
    }

    private func checkIfUserExists(_ username: String, req: Request) -> EventLoopFuture<Bool> {
        User.query(on: req.db)
                .filter(\.$username == username)
                .first()
                .map {
                    $0 != nil
                }
    }

    fileprivate func login(req: Request) throws -> EventLoopFuture<NewSession> {
        throw Abort(.notImplemented)
    }

    func getMyOwnUser(req: Request) throws -> User.Public {
        throw Abort(.notImplemented)
    }
}