import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // register routes
    try routes(app)

    // psql -U postgres // postgres is super user // login to psql using this command
    // CREATE DATABASE practice_auth;
    // GRANT ALL PRIVILEGES ON DATABASE practice_auth TO vapor
    // \q
    app.databases.use(
        .postgres(
            configuration: .init(
                hostname: "localhost",
                username: "vapor",
                password: "password",
                database: "practice_auth",
                tls: .disable
            )
        ),
        as: .psql
    )
    // swift run SpendingTrackerVapor migrate
    app.migrations.add(User.Migration())
    app.migrations.add(UserToken.Migration())

}
