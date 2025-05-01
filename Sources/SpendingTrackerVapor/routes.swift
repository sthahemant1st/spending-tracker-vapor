import Fluent
import Vapor
import VaporToOpenAPI

func routes(_ app: Application) throws {
    
    app.get("swagger") { req -> Response in
        return req.redirect(to: "/swagger/index.html")
    }
    .excludeFromOpenAPI()

    // generate OpenAPI documentation
    app.get("openapi.json") { req in
      req.application.routes.openAPI(
        info: InfoObject(
          title: "Example API",
          description: "Example API description",
          version: "0.1.0"
        )
      )
    }
    .excludeFromOpenAPI()
    
    app.get { req async in
        "It works great!"
    }
    .openAPI(
        description: "Just to check if server is up or not",
        response: .type(String.self),
        responseDescription: "Constant string, response string dosen't matter",
        statusCode: .ok
    )
    
    try app.register(collection: UserController())
    
}
