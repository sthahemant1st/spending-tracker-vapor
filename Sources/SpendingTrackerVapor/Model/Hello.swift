import Vapor

struct Hello: Content {
    var name: String?

    mutating func afterDecode() throws {
        // Name may not be passed in, but if it is, then it can't be an empty string.
        self.name = self.name?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let name = self.name, name.isEmpty {
            throw Abort(.badRequest, reason: "Name must not be empty.")
        }
    }
}