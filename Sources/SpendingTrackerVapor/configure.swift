import Vapor
import Leaf

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // register routes
    try routes(app)

    // Configure the Leaf template engine
    app.views.use(.leaf)

    app.leaf.tags["now"] = NowTag()
    app.leaf.tags["hello"] = HelloTag()
    app.leaf.tags["helloData"] = HelloDataTag()
}
