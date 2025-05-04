//
//  UserController.swift
//  SpendingTrackerVapor
//
//  Created by Hemant Shrestha on 01.05.25.
//

import Vapor
import Fluent
import VaporToOpenAPI
import JWT

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("api", "v1", "users")
        users.post("register", use: register)
            .openAPI(
                body: .type(CreateUserRequest.self),
                response: .type(String.self),
                statusCode: .created
            )
        
        users.get("verify", use: verify)
            .openAPI(
                query: .type(VerifyUserQuery.self) ,
                response: .type(
                    String.self
                )
            )
        
        users.post("login", use: login)
            .openAPI(
                body: .type(LoginRequest.self),
                response: .type(LoginResponse.self)
            )
        
        users.post("refresh", use: refresh)
            .openAPI(
                body: .type(RefreshTokenRequest.self),
                response: .type(LoginResponse.self)
            )
    }
    
    func refresh(req: Request) async throws -> LoginResponse {
        let refreshTokenRequest = try req.content.decode(RefreshTokenRequest.self)
        
        let refreshToken = try await RefreshToken.query(on: req.db)
            .filter(\.$token, .equal, refreshTokenRequest.refreshToken)
            .filter(\.$expiresAt > Date.now)
            .with(\.$user)
            .first()
        guard let refreshToken else {
            throw Abort(.unauthorized, reason: "Invalid refresh token")
        }
        let jwt = try await createJWTToken(for: refreshToken.user, req: req)
        let newRefreshToken = try createRefreshToken(for: refreshToken.user)
        
        try await req.db.transaction { db in
            try await newRefreshToken.save(on: db)
            try await refreshToken.delete(on: db)
        }
        
        return .init(
            accessToken: jwt,
            refreshToken: newRefreshToken.token,
            expiresAt: newRefreshToken.expiresAt
        )
    }
    
    func login(req: Request) async throws -> LoginResponse {
        let loginRequest = try req.content.decode(LoginRequest.self)
        
        let username = loginRequest.username.lowercased()
        
        let user = try await User.query(on: req.db)
            .filter(\.$username == username)
            .first()
        
        guard let user else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        guard user.isEmailVerified else {
            throw Abort(.unprocessableEntity, reason: "Email not verified")
        }
        
        
        guard try Bcrypt.verify(loginRequest.password, created: user.passwrodHash) else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }

        let jwt = try await createJWTToken(for: user, req: req)
        
        let refreshToken = try createRefreshToken(for: user)
        try await refreshToken.save(on: req.db)

        return LoginResponse(
            accessToken: jwt,
            refreshToken: refreshToken.token,
            expiresAt: refreshToken.expiresAt
        )
    }
    
    func createJWTToken(for user: User, req: Request) async throws -> String {
        let accessTokenTTL: TimeInterval = 60 * 15
        let exp: ExpirationClaim = .init(value: Date.now.addingTimeInterval(accessTokenTTL))
        let payload = AccessTokenPayload(
            subject: .init(value: try user.requireID().uuidString),
            expiration: exp
        )
        return try await req.jwt.sign(payload)
    }
    
    func createRefreshToken(for user: User) throws -> RefreshToken {
        let refreshTokenString = [UInt8].random(count: 32).base64
        let refreshTokenTTL: TimeInterval = 60 * 60
        return RefreshToken(
            token: refreshTokenString,
            expiresAt: Date.now.addingTimeInterval(refreshTokenTTL),
            userID: try user.requireID()
        )
    }
    
    func verify(req: Request) async throws -> String {
        let query: VerifyUserQuery
        
        do {
            query = try req.query.decode(VerifyUserQuery.self)
        } catch {
            throw Abort(.badRequest, reason: "Missing required query parameters")
        }
        
        let emailVerificationToken = try await EmailVerificationToken.query(on: req.db)
            .filter(\.$token == query.token)
            .filter(\.$expiresAt > Date.now)
            .with(\.$user)
            .first()
        guard let emailVerificationToken else {
            throw Abort(.badRequest, reason: "Invalid token")
        }
        
        let user = emailVerificationToken.user

        try await req.db.transaction { db in
            user.isEmailVerified = true
            try await user.save(on: db)
            try await emailVerificationToken.delete(on: db)
        }
        
        return "User has been verified. Now you can login."
    }
    
    func register(req: Request) async throws -> HTTPStatus {
        try CreateUserRequest.validate(content: req)
        let dto = try req.content.decode(CreateUserRequest.self)
        
        
        let username = dto.username.lowercased()
        guard try await User.query(on: req.db).filter(\.$username == username).first() == nil else {
            throw Abort(.badRequest, reason: "User with this username already exists")
        }
        
        let email = dto.email.lowercased()
        guard try await User.query(on: req.db).filter(\.$email == email).first() == nil else {
            throw Abort(.badRequest, reason: "User with this email already exists")
        }
        
        let passwordHash = try Bcrypt.hash(dto.password)
        let user = User(
            firstName: dto.firstName,
            middleName: dto.middleName,
            lastName: dto.lastName,
            email: email,
            username: username,
            passwrodHash: passwordHash
        )

        try await req.db.transaction { database in
            try await user.save(on: database)

            let userId = try user.requireID()
            let token = EmailVerificationToken(userID: userId)
            try await token.save(on: database)

            req.application.emailService?.sendEmailVerificationToken(to: email, with: token.token)
        }
        
        return .created
    }
}

struct AccessTokenPayload: JWTPayload {
    var subject: SubjectClaim
    var expiration: ExpirationClaim
    
    func verify(using algorithm: some JWTKit.JWTAlgorithm) async throws {
        try expiration.verifyNotExpired()
    }
}
