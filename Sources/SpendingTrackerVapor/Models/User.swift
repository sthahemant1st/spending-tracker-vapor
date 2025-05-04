//
//  User.swift
//  SpendingTrackerVapor
//
//  Created by Hemant Shrestha on 30.04.25.
//

import Fluent
import Vapor

final class User: Model, @unchecked Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "first_name")
    var firstName: String
    
    @Field(key: "middle_name")
    var middleName: String?
    
    @Field(key: "last_name")
    var lastName: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password_hash")
    var passwrodHash: String
    
    @Field(key: "is_email_verified")
    var isEmailVerified: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updateAt: Date?
    
    @Field(key: "token_version")
    var tokenVersion: Int
    
    @Children(for: \.$user)
    var emailTokens: [EmailVerificationToken]
    
    init() {}
    
    init(
        firstName: String,
        middleName: String?,
        lastName: String,
        email: String,
        username: String,
        passwrodHash: String
    ) {
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.email = email
        self.username = username
        self.passwrodHash = passwrodHash
        self.isEmailVerified = false
        self.tokenVersion = 0
    }
}

extension User: Authenticatable {}

struct UserAuthenticator: AsyncBearerAuthenticator {
    func authenticate(
        bearer: Vapor.BearerAuthorization,
        for request: Vapor.Request
    ) async throws {
        let payload = try await request.jwt.verify(bearer.token, as: AccessTokenPayload.self)
        let userID = UUID(uuidString: payload.subject.value)
        
        let user = try await User.find(userID, on: request.db)
        
        
        if let user, user.tokenVersion == payload.tokenVersion {
            request.auth.login(user)
        }
    }
}
