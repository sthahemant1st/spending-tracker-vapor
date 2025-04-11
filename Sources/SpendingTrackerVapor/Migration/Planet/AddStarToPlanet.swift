import Fluent

struct AddStarToPlanet: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("planets")
            .field("star_id", .uuid, .references("stars", "id"))
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("planets")
            .deleteField("star_id")
            .update()
    }
}
