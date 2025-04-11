import Fluent
import Vapor

final class Planet: Model, @unchecked Sendable, Content {
    static let schema = "planets"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @OptionalField(key: "tag")
    var tag: String?

    @Parent(key: "star_id")
    var star: Star

    // When this Planet was created.
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    // When this Planet was last updated.
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() {}

    init(id: UUID? = nil, name: String, tag: String? = nil, starId: Star.IDValue) {
        self.id = id
        self.name = name
        self.tag = tag
        self.$star.id = starId
    }
}
