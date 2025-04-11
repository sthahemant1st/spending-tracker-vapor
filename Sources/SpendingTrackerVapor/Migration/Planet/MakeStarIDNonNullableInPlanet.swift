import Fluent
import Vapor
import FluentSQL

struct MakeStarIDNonNullableInPlanet: AsyncMigration {
    func prepare(on database: any Database) async throws {
        guard let sql = database as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database does not support SQL")
        }

        try await sql.raw("""
            ALTER TABLE planets
            ALTER COLUMN star_id SET NOT NULL
        """).run()
    }

    func revert(on database: any Database) async throws {
        guard let sql = database as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database does not support SQL")
        }

        try await sql.raw("""
            ALTER TABLE planets
            ALTER COLUMN star_id DROP NOT NULL
        """).run()
    }
}
