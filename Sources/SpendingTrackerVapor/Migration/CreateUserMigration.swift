import Fluent

struct CreateUserMigration: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .id()
            .field("first_name", .string, .required)
            .field("last_name", .string, .required)
            // Pet group fields
            .field("pet_name", .string, .required)
            .field("pet_type", .string, .required)
            .create()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
}
