import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async throws -> String in
        try await req.queue.dispatch(
            EmailJob.self,
            .init(to: "email@email.com", message: "message"))
        return "Hello, world!"
    }

    app.webSocket("echo") { req, ws in
        // Connected WebSocket.
        ws.onText { ws, text in
            // Received text from the client.
            print("Received text: \(text)")
            ws.send("Echo: \(text)")
        }
    }

    app.get("set", ":value") { req -> HTTPStatus in
        req.session.data["name"] = req.parameters.get("value")
        return .ok
    }

    app.get("get") { req -> String in
        req.session.data["name"] ?? "n/a"
    }

    app.get("del") { req -> HTTPStatus in
        req.session.destroy()
        return .ok
    }
}
