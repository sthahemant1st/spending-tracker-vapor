import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }
    app.post("users") { req async throws -> User in
        try User.Create.validate(content: req)
        let create = try req.content.decode(User.Create.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        let user = try User(
            name: create.name,
            email: create.email,
            passwordHash: Bcrypt.hash(create.password)
        )
        try await user.save(on: req.db)
        return user
    }

    let passwordProtected = app.grouped(User.authenticator())
    passwordProtected.post("login") { req async throws -> UserToken in
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        try await token.save(on: req.db)
        return token
    }

    let tokenProtected = app.grouped(UserToken.authenticator())
    tokenProtected.get("v2", "me") { req -> User in
        let user = try req.auth.require(User.self)
        return user
    }

    let protected = app.grouped(BasicUserAuthenticator())
    protected.get("me") { req -> String in
        try req.auth.require(UserOld.self).name
    }

    let bearerProtected = app.grouped(BearerUserAuthenticator())
    bearerProtected.get("bearer-procted-api") { req -> String in
        try req.auth.require(UserOld.self).name
    }
}

struct BasicUserAuthenticator: AsyncBasicAuthenticator {

    func authenticate(
        basic: BasicAuthorization,
        for request: Request
    ) async throws {
        if basic.username == "test" && basic.password == "secret" {
            request.auth.login(UserOld(name: "Vapor"))
        }
    }
}

struct BearerUserAuthenticator: AsyncBearerAuthenticator {

    func authenticate(
        bearer: BearerAuthorization,
        for request: Request
    ) async throws {
        if bearer.token == "foo" {
            request.auth.login(UserOld(name: "Vapor"))
        }
    }
}
