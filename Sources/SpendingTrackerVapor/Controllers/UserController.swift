import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: create)
        users.get(use: getAll)
    }

    func create(req: Request) async throws -> GetUserDTO {
        let createUserDto = try req.content.decode(CreateUserDTO.self)
        let user: User = .init(
            firstName: createUserDto.firstName, lastName: createUserDto.lastName,
            pet: .init(name: createUserDto.petName, type: createUserDto.petType))
        try await user.create(on: req.db)
        return user.getUserDto
    }

    func getAll(req: Request) async throws -> [GetUserDTO] {
        var queryBuilder = User.query(on: req.db)

        if let petType = try? req.query.get(Animal.self, at: "petType") {
            queryBuilder = queryBuilder.filter(\.$pet.$type == petType)
        }
        if let lastName = try? req.query.get(String.self, at: "lastName") {
            // queryBuilder = queryBuilder.filter(\.$lastName, .custom("ILIKE"), "%\(lastName)%")
            // queryBuilder = queryBuilder.filterInsensitiveContains(\.$lastName, lastName)
            queryBuilder = queryBuilder.filterFuzzy("last_name", lastName)
        }

        return try await queryBuilder.all().map { $0.getUserDto }
    }
}

extension QueryBuilder {
    func filterFuzzy(_ key: String, _ value: String, threshold: Double = 0.3) -> Self {
        self.filter(.sql(unsafeRaw: "similarity(\(key), '\(value)') > \(threshold)"))
    }
}

extension QueryBuilder {
    func filterInsensitiveContains(_ key: KeyPath<Model, FieldProperty<Model, String>>, _ value: String) -> Self {
        self.filter(key, .custom("ILIKE"), "%\(value)%")
    }
}