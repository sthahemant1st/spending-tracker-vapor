//
//  CreateEmailVerificationTokenMigrate.swift
//  SpendingTrackerVapor
//
//  Created by Hemant Shrestha on 30.04.25.
//

import Fluent

struct CreateEmailVerificationTokenMigration: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema(EmailVerificationToken.schema)
            .id()
            .field("token", .string, .required)
            .field("expires_at", .datetime, .required)
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("created_at", .datetime)
            .unique(on: "token")
            .create()
    }
    
    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema(EmailVerificationToken.schema).delete()
    }
}
