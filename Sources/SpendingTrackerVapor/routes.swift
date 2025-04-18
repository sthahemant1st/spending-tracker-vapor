import Fluent
import Vapor
import VaporToOpenAPI

func routes(_ app: Application) throws {

    try app.register(collection: PlanetsController())
    try app.register(collection: UserController())
    
    app.get("swagger") { req -> Response in
        return req.redirect(to: "/swagger/index.html")
    }

    // generate OpenAPI documentation
    app.get("openapi.json") { req in
      req.application.routes.openAPI(
        info: InfoObject(
          title: "Example API",
          description: "Example API description",
          version: "0.1.0"
        )
      )
    }
    .excludeFromOpenAPI()
    
    app.get { req async in
        "It works great!"
    }
    .openAPI(
        description: "Just to check if server is up or not",
        response: .type(String.self),
        responseDescription: "Constant string, response string dosen't matter",
        statusCode: .ok
    )

    app.get("hello", ":name") { req -> String in
        guard let name = req.parameters.get("name") else {
            throw Abort(.badRequest)
        }
        return "Hello, \(name)!"
    }
    .description("says hello to the person with the given name")
    .openAPI(
        response: .type(String.self),
        responseDescription: "Greetings to the provided name"
    )

    // try app.register(collection: TodosController())

    app.post("greeting") { req in
        let greeting = try req.content.decode(Greeting.self)
        print(greeting.hello)
        return HTTPStatus.noContent
    }
    .openAPI(
        body: .type(Greeting.self),
        statusCode: .noContent
    )

    app.get("hello") { req -> String in
        let hello = try req.query.decode(Hello.self)
        return "Hello, \(hello.name ?? "Beautiful")"
        // let name = req.query["name"] ?? "Beautiful"
        // return "Hello, \(name)"
    }

    app.get("test") { req in
        let response = try await req.client.get("https://httpbin.org/status/200")
        print("Response: \(response)")
        return HTTPStatus.ok
    }

    app.post("accounts") { req -> Account in
        try Account.validate(content: req)
        let account = try req.content.decode(Account.self)
        return account
    }
    .openAPI(
        body: .type(Account.self),
        response: .type(Account.self),
        responseDescription: "Returns the created account"
    )
    app.get("accounts") { req -> Account in
        try Account.validate(query: req)
        let account = try req.query.decode(Account.self)
        return account
    }

    app.get("galaxies") { req async throws in
        try await Galaxy.query(on: req.db).with(\.$stars).all()
    }

    app.post("galaxies") { req async throws -> Galaxy in
        let galaxy = try req.content.decode(Galaxy.self)
        try await galaxy.create(on: req.db)
        return galaxy
    }

    app.post("stars") { req async throws -> Star in
        let star = try req.content.decode(Star.self)
        try await star.create(on: req.db)
        return star
    }

    app.get("stars") { req async throws in
        try await Star.query(on: req.db).all()
    }
}
