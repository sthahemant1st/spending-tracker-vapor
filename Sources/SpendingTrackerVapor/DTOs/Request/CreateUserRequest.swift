//
//  CreateUserRequest.swift
//  SpendingTrackerVapor
//
//  Created by Hemant Shrestha on 30.04.25.
//

import Vapor
import Fluent

struct CreateUserRequest: Content {
    var firstName: String
    var middleName: String?
    var lastName: String
    var email: String
    var username: String
    var password: String
    
//    init(from decoder: any Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.firstName = try container.decode(String.self, forKey: .firstName)
//            .capitalized
//        self.middleName = try container
//            .decodeIfPresent(String.self, forKey: .middleName)?
//            .capitalized
//        self.lastName = try container.decode(String.self, forKey: .lastName)
//            .capitalized
//        self.email = try container.decode(String.self, forKey: .email)
//            .lowercased()
//            .trimmingCharacters(in: .whitespacesAndNewlines)
//        self.username = try container.decode(String.self, forKey: .username)
//            .lowercased()
//            .trimmingCharacters(in: .whitespacesAndNewlines)
//        self.password = try container.decode(String.self, forKey: .password)
//    }
}

extension CreateUserRequest: Validatable {
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("firstName", as: String.self, is: .count(2...100))
        validations.add("lastName", as: String.self, is: .count(2...100))
        validations.add("email", as: String.self, is: .email)
    }
}
