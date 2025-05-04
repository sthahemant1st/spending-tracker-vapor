//
//  CreateRefreshTokenMigration.swift
//  SpendingTrackerVapor
//
//  Created by Hemant Shrestha on 04.05.25.
//

import Fluent

struct CreateRefreshTokenMigration: Migration {
    func prepare(on database: any FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database.schema(RefreshToken.schema)
            .id()
            .field("token", .string, .required)
            .field("expires_at", .datetime, .required)
            .field("user_id", .uuid, .references("users", "id", onDelete: .cascade))
            .unique(on: "token")
            .create()
            
    }
    
    func revert(on database: any FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database.schema(RefreshToken.schema).delete()
    }
}
