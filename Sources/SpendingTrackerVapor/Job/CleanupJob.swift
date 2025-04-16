import Vapor
import Queues

struct CleanupJob: AsyncScheduledJob {
    // Add extra services here via dependency injection, if you need them.

    func run(context: QueueContext) async throws {
        // Do some work here, perhaps queue up another job.
    }
}