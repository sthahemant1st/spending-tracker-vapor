import Vapor 

struct Account: Content {
    var name: String
    var username: String
    var age: Int
    var email: String
    var favoriteColor: Color?
}

enum Color: String, Codable {
    case red, blue, green
}

extension Account: Validatable {
    static func validations(_ validations: inout Validations) {
        // Validations go here.
        validations.add("name", as: String.self, is: !.empty)
        validations.add("username", as: String.self, is: .count(3...) && .alphanumeric)
        validations.add("age", as: Int.self, is: .range(0...120))
        validations.add("email", as: String.self, is: .email)
        validations.add(
            "favoriteColor", as: String.self,
            is: .in("red", "blue", "green"),
            required: false
        )
    }
}