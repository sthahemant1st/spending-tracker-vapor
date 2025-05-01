//
//  UserController.swift
//  SpendingTrackerVapor
//
//  Created by Hemant Shrestha on 01.05.25.
//

import Vapor
import Fluent
import VaporToOpenAPI

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("api", "v1", "users")
        users.post("register", use: register)
            .openAPI(
                body: .type(CreateUserDTO.self),
                response: .type(String.self),
                statusCode: .created
            )
    }
    
    func register(req: Request) async throws -> HTTPStatus {
        try CreateUserDTO.validate(content: req)
        let dto = try req.content.decode(CreateUserDTO.self)
        
        
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
