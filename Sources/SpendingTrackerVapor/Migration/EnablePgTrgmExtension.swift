import Fluent
import FluentSQL
import Vapor

struct EnablePgTrgmExtension: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        guard let sql = database as? any SQLDatabase else {
            return database.eventLoop.makeFailedFuture(
                Abort(.internalServerError, reason: "Database does not support SQL"))
        }

        return sql.raw("CREATE EXTENSION IF NOT EXISTS pg_trgm").run()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        guard let sql = database as? any SQLDatabase else {
            return database.eventLoop.makeFailedFuture(
                Abort(.internalServerError, reason: "Database does not support SQL"))
        }

        return sql.raw("DROP EXTENSION IF EXISTS pg_trgm").run()
    }

}
