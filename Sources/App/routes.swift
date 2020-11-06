import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get("/") { _ in
        "hello world!"
    }

    try app.register(collection: UserController())
    try app.register(collection: DinnerController())
}
