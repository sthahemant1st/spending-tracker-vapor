import Fluent

struct CreateStar: AsyncMigration {
    // Prepares the database for storing Star models.
    func prepare(on database: any Database) async throws {
        try await database.schema("stars")
            .id()
            .field("name", .string)
            .field("galaxy_id", .uuid, .references("galaxies", "id"))
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: any Database) async throws {
        try await database.schema("stars").delete()
    }
}
