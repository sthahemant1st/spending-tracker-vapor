import Fluent
import Vapor 
import FluentSQL

struct AssignFirstStarToExistingPlanets: AsyncMigration {
    func prepare(on database: any Database) async throws {
        // Step 1: Get the first Star's ID
        guard let firstStar = try await Star.query(on: database).first() else {
            throw Abort(.internalServerError, reason: "No Star found to assign to planets")
        }

        // Step 2: Update all existing planets with NULL star_id
        try await Planet.query(on: database)
        //   .filter(.sql(unsafeRaw: "star_id IS NULL"))
        // .filter(.field("star_id"), .custom("IS NULL"))
            .set(\.$star.$id, to: firstStar.id!)
            .update()
    }

    func revert(on database: any Database) async throws {
        // Optional: revert by nulling out the star_id from planets
        guard let sql = database as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database doesn't support raw SQL")
        }

        try await sql.raw("UPDATE planets SET star_id = NULL").run()
    }
}
