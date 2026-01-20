import Vapor

/// Register all application routes
func routes(_ app: Application) throws {
    // Register controllers
    try app.register(collection: HealthController())
    try app.register(collection: DataController())
}
