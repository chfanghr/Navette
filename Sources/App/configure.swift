import Fluent
import Vapor
import FluentSQLiteDriver

public func configure(_ app: Application) throws {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.dateEncodingStrategy = .iso8601

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .iso8601

    ContentConfiguration.global.use(encoder: encoder, for: .json)
    ContentConfiguration.global.use(decoder: decoder, for: .json)

    app.databases.use(.sqlite(
            .file(Environment.get("DATABASE_FILE") ?? "Navette.db")),
            as: .sqlite)

    app.middleware.use(
            ErrorMiddleware.default(environment: app.environment))

    app.migrations.add(CreateUsers())
    app.migrations.add(CreateTokens())
    try app.autoMigrate().wait()

    try routes(app)
}
