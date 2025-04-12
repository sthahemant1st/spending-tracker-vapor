import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async throws -> View in
        return try await req.view.render("hello", ["name": "Leaf", "age": "5"])
    }

    app.get("welcome") { req async throws -> View in
        return try await req.view.render(
            "welcome", WelcomeContext(title: "Welcome to Vapor!", numbers: [1, 2, 3, 4, 5]))
    }

    app.get("planet") { req async throws -> View in
        struct SolarSystem: Codable {
            var planets = ["Venus", "Earth", "Mars"]
        }

        return try await req.view.render("planet", SolarSystem())
    }
}

struct WelcomeContext: Encodable {
    var title: String
    var numbers: [Int]
}
