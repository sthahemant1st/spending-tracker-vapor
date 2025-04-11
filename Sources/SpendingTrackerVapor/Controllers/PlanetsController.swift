import Vapor
import Fluent 

struct PlanetsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let planets = routes.grouped("planets")
        planets.get(use: index)
        planets.post(use: create)
        planets.get("withDeleted", use: allWithDeleted)
        planets.group(":planetID") { planet in
            planet.delete(use: delete)
            planet.put(use: update)
            planet.get(use: getPlanet)

            planet.delete("force", use: forceDelete)
            planet.post("restore", use: restore)
        }
    }

    func index(req: Request) async throws -> [Planet] {
        return try await Planet.query(on: req.db).all()
    }

    func create(req: Request) async throws -> Planet {
        let planet = try req.content.decode(Planet.self)
        try await planet.create(on: req.db)
        return planet
    }
    func delete(req: Request) async throws -> HTTPStatus {
        guard let planet = try await Planet.find(req.parameters.get("planetID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await planet.delete(on: req.db)
        return .noContent
    }

    func update(req: Request) async throws -> Planet {
        guard let planet = try await Planet.find(req.parameters.get("planetID"), on: req.db) else {
            throw Abort(.notFound)
        }

        let updatedPlanet = try req.content.decode(Planet.self)
        planet.name = updatedPlanet.name
        planet.tag = updatedPlanet.tag
        try await planet.save(on: req.db)
        return planet
    }
    func getPlanet(req: Request) async throws -> Planet {
        guard let planet = try await Planet.find(req.parameters.get("planetID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return planet
    }

    // Get all including soft-deleted
    func allWithDeleted(req: Request) async throws -> [Planet] {
        return try await Planet.query(on: req.db).withDeleted().all()
    }

    // Force delete
    func forceDelete(req: Request) async throws -> HTTPStatus {
        let planet = try await getPlanetDeleted(req: req)
        try await planet.delete(force: true, on: req.db)
        return .noContent
    }
    func getPlanetDeleted(req: Request) async throws -> Planet {
        guard let idString = req.parameters.get("planetID"),
            let uuid = UUID(uuidString: idString),
            let planet = try await Planet.query(on: req.db)
                .withDeleted()
                .filter(\.$id == uuid)
                // .filter(\.$id, .equal, uuid)
                .first()
        else {
            throw Abort(.notFound)
        }
        return planet
    }
    // Restore a soft-deleted planet
    func restore(req: Request) async throws -> Planet {
        let planet = try await getPlanetDeleted(req: req)
                // Check if the planet is soft-deleted
        guard planet.deletedAt != nil else {
            throw Abort(.badRequest, reason: "Planet is not deleted")
        }
        try await planet.restore(on: req.db)
        return planet
    }

}
