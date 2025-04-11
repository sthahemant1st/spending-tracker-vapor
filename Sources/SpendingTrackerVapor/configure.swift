import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Increases the streaming body collection limit to 500kb
    app.routes.defaultMaxBodySize = "500kb"

    // create a new JSON encoder that uses unix-timestamp dates
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .secondsSince1970
    // override the global encoder used for the `.json` media type
    ContentConfiguration.global.use(encoder: encoder, for: .json)

    // register routes
    let foo = Environment.get("FOO")
    app.logger.info("FOO: \(foo ?? "nil")")

    try routes(app)

    app.databases.use(
        .postgres(
            configuration: .init(
                hostname: "localhost",
                username: "vapor",
                password: "password",
                database: "spending_tracker_db",
                tls: .disable
            )
        ),
        as: .psql
    )
    
    // swift run SpendingTrackerVapor migrate
    // createuser -s postgres -- // creates super user
    // psql -U postgres -d spending_tracker_db -- // connect to db
    // CREATE EXTENSION IF NOT EXISTS pg_trgm; -- // enable pg_trgm extension
    // \q -- // quit psql
    app.migrations.add(CreateGalaxy())
    app.migrations.add(CreateStar())
    app.migrations.add(CreatePlanet())
    app.migrations.add(CreateUserMigration())
    app.migrations.add(AddStarToPlanet())
    app.migrations.add(AssignFirstStarToExistingPlanets())
    app.migrations.add(MakeStarIDNonNullableInPlanet())
    // app.migrations.add(EnablePgTrgmExtension())
}
