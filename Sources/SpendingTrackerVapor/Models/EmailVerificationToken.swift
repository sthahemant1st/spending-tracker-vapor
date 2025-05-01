//
//  EmailVerificationToken.swift
//  SpendingTrackerVapor
//
//  Created by Hemant Shrestha on 30.04.25.
//

import Fluent
import Vapor

final class EmailVerificationToken: Model, @unchecked Sendable {
    static let schema: String = "email_verrifications_tokens"
    
    @ID(key: .id) var id: UUID?
    @Field(key: "token") var token: String
    @Field(key: "expires_at") var expiresAt: Date
    @Parent(key: "user_id") var user: User
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() {}
    
    init(token: String, expiresAt: Date, userID: UUID) {
        self.token = token
        self.expiresAt = expiresAt
        self.$user.id = userID
    }
    
    init(userID: UUID) {
        self.token = UUID().uuidString
        self.expiresAt = Date().addingTimeInterval(3600)
        self.$user.id = userID
    }
}
