import Fluent

struct CreateGalaxy: AsyncMigration {
    // Prepares the database for storing Galaxy models.
    func prepare(on database: any Database) async throws {
        try await database.schema(Galaxy.schema)
            .id()
            .field("name", .string)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: any Database) async throws {
        try await database.schema("galaxies").delete()
    }
}