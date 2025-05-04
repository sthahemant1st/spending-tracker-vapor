import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Increases the streaming body collection limit to 500kb
    app.routes.defaultMaxBodySize = "500kb"

    // create a new JSON encoder that uses unix-timestamp dates
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .secondsSince1970
    // override the global encoder used for the `.json` media type
    ContentConfiguration.global.use(encoder: encoder, for: .json)

    // 2. Add your ProblemDetailsErrorMiddleware at the end
    app.middleware.use(ProblemDetailsErrorMiddleware())
    
    // iniatializing service.
    let emailService = TemporaryEmailService()
    app.emailService = emailService

    try routes(app)

    app.databases.use(
        .postgres(
            configuration: .init(
                hostname: "localhost",
                username: "spending_tracker",
                password: "spending_tracker",
                database: "spending_tracker",
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
    app.migrations.add(CreateUserMigration())
    app.migrations.add(CreateEmailVerificationTokenMigration())
}

