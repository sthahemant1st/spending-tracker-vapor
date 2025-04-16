import Queues
import QueuesRedisDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // register routes
    try routes(app)

    try app.queues.use(.redis(url: "redis://127.0.0.1:6379"))

    // Register jobs
    let emailJob = EmailJob()
    app.queues.add(emailJob)
    try app.queues.startInProcessJobs(on: .default)

    app.queues.schedule(CleanupJob())
        .yearly()
        .in(.may)
        .on(23)
        .at(.noon)
    app.queues.add(MyEventDelegate())
    try app.queues.startScheduledJobs()

    app.middleware.use(app.sessions.middleware)
    app.sessions.use(.memory)

}

struct MyEventDelegate: JobEventDelegate {
    /// Called when the job is dispatched to the queue worker from a route
    func dispatched(job: JobEventData, eventLoop: any EventLoop) -> EventLoopFuture<Void> {
        eventLoop.future()
    }

    /// Called when the job is placed in the processing queue and work begins
    func didDequeue(jobId: String, eventLoop: any EventLoop) -> EventLoopFuture<Void> {
        eventLoop.future()
    }

    /// Called when the job has finished processing and has been removed from the queue
    func success(jobId: String, eventLoop: any EventLoop) -> EventLoopFuture<Void> {
        eventLoop.future()
    }

    /// Called when the job has finished processing but had an error
    func error(jobId: String, error: any Error, eventLoop: any EventLoop) -> EventLoopFuture<Void> {
        eventLoop.future()
    }
}

/*
https://redis.io/docs/latest/operate/oss_and_stack/install/archive/install-redis/install-redis-on-mac-os/
To start redis now and restart at login:
  brew services start redis
  brew services stop redis
  brew services info redis
redis-cli

Or, if you don't want/need a background service you can just run:
  /opt/homebrew/opt/redis/bin/redis-server /opt/homebrew/etc/redis.conf

  Workers should stay running in production. Consult your hosting provider to
  find out how to keep long-running processes alive. Heroku, for example,
  allows you to specify "worker" dynos like this in your Procfile: worker: App queues --scheduled
*/
