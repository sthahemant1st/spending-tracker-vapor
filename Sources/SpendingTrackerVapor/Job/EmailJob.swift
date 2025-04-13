import Vapor 
import Foundation 
import Queues 

struct Email: Codable {
    let to: String
    let message: String
}

struct EmailJob: AsyncJob {
    typealias Payload = Email

    func dequeue(_ context: QueueContext, _ payload: Email) async throws {
        // This is where you would send the email
    }

    func error(_ context: QueueContext, _ error: any Error, _ payload: Email) async throws {
        // If you don't want to handle errors you can simply return. You can also omit this function entirely. 
    }
}