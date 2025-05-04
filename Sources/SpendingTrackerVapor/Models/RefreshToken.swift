//
//  RefreshToken.swift
//  SpendingTrackerVapor
//
//  Created by Hemant Shrestha on 04.05.25.
//

import Foundation
import Fluent

final class RefreshToken: Model, @unchecked Sendable {
    static let schema = "refresh_tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "token")
    var token: String
    
    @Field(key: "expires_at")
    var expiresAt: Date
    
    @Parent(key: "user_id")
    var user: User
    
    init() {}
    
    init(token: String, expiresAt: Date, userID: UUID) {
        self.token = token
        self.expiresAt = expiresAt
        self.$user.id = userID
    }
}
