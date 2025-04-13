import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async throws -> String in
        try await req.queue.dispatch(
        EmailJob.self, 
        .init(to: "email@email.com", message: "message"))
        return "Hello, world!"
    }
}
