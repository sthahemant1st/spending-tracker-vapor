import Fluent
import Vapor

final class User: Model, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "first_name")
    var firstName: String

    @Field(key: "last_name")
    var lastName: String
    // The user's nested pet.
    @Group(key: "pet")
    var pet: Pet

    init() { }

    init(id: UUID? = nil, firstName: String, lastName: String, pet: Pet) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.pet = pet
    }
}

final class Pet: Fields, @unchecked Sendable {
    // The pet's name.
    @Field(key: "name")
    var name: String

    // The type of pet. 
    @Enum(key: "type")
    var type: Animal

    // Creates a new, empty Pet.
    init() { }

    init(name: String, type: Animal) {
        self.name = name
        self.type = type
    }
}

enum Animal: String, Codable {
    case dog, cat
}

struct CreateUserDTO: Content {
    var firstName: String
    var lastName: String
    var petName: String
    var petType: Animal
}

struct GetUserDTO: Content {
    var firstName: String
    var lastName: String
    var petName: String
    var petType: Animal
}

extension User {
    var getUserDto: GetUserDTO {
        return .init(
            firstName: self.firstName,
            lastName: self.lastName,
            petName: self.pet.name,
            petType: self.pet.type
        )
    }
}