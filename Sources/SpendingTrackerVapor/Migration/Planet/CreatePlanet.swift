import Fluent

struct CreatePlanet: AsyncMigration {
    // Prepares the database for storing Planet models.
    func prepare(on database: any Database) async throws {
        try await database.schema("planets")
            .id()
            .field("name", .string, .required)
            .field("tag", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: any Database) async throws {
        try await database.schema("planets").delete()
    }
}