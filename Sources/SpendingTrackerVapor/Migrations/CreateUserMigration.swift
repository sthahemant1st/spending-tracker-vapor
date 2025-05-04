//
//  CreateUserMigration.swift
//  SpendingTrackerVapor
//
//  Created by Hemant Shrestha on 30.04.25.
//

import Fluent

struct CreateUserMigration: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
            .id()
            .field("first_name", .string, .required)
            .field("middle_name", .string)
            .field("last_name", .string, .required)
            .field("email", .string, .required)
            .field("username", .string, .required)
            .field("password_hash", .string, .required)
            .field("created_at", .datetime)
            .field( "updated_at", .datetime)
            .field("is_email_verified", .bool, .required)
            .field("token_version", .int, .required)
            .unique(on: "email")
            .unique(on: "username")
            .create()
    }
    
    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema(User.schema).delete()
    }
}
