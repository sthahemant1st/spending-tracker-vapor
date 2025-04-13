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
    // try app.queues.startScheduledJobs()
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
*/
