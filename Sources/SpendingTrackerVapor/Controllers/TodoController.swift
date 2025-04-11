// import Vapor

// struct TodosController: RouteCollection {
//     func boot(routes: RoutesBuilder) throws {
//         let todos = routes.grouped("todos")
//         todos.get(use: index)
//         todos.post(use: create)

//         todos.group(":id") { todo in
//             todo.get(use: show)
//             todo.put(use: update)
//             todo.delete(use: delete)
//         }
//     }

//     func index(req: Request) async throws -> [Todo] {
//         try await Todo.query(on: req.db).all()
//     }

//     func create(req: Request) async throws -> Todo {
//         let todo = try req.content.decode(Todo.self)
//         try await todo.save(on: req.db)
//         return todo
//     }

//     func show(req: Request) async throws -> Todo {
//         guard let todo = try await Todo.find(req.parameters.get("id"), on: req.db) else {
//             throw Abort(.notFound)
//         }
//         return todo
//     }

//     func update(req: Request) async throws -> Todo {
//         guard let todo = try await Todo.find(req.parameters.get("id"), on: req.db) else {
//             throw Abort(.notFound)
//         }
//         let updatedTodo = try req.content.decode(Todo.self)
//         todo.title = updatedTodo.title
//         try await todo.save(on: req.db)
//         return todo
//     }

//     func delete(req: Request) async throws -> HTTPStatus {
//         guard let todo = try await Todo.find(req.parameters.get("id"), on: req.db) else {
//             throw Abort(.notFound)
//         }
//         try await todo.delete(on: req.db)
//         return .ok
//     }
// }

// struct Todo: Model, Content {
//     static let schema = "todos"

//     @ID(key: .id)
//     var id: UUID?

//     @Field(key: "title")
//     var title: String

//     init() { }

//     init(id: UUID? = nil, title: String) {
//         self.id = id
//         self.title = title
//     }
// }