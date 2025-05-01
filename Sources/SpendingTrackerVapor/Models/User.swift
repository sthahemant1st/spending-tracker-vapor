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
    }
}
