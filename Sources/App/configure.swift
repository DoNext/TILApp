import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
///
/// https://docs.vapor.codes/3.0/getting-started/structure/#configureswift
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(DateMiddleware.self) // Adds `Date` header to responses
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a database
//    let sqlite: SQLiteDatabase
//    if env.isRelease {
//        /// Create file-based SQLite db using $SQLITE_PATH from process env
//        sqlite = try SQLiteDatabase(storage: .file(path: Environment.get("SQLITE_PATH")!))
//    } else {
//        /// Create an in-memory SQLite database
//        sqlite = try SQLiteDatabase(storage: .memory)
//    }

    /// Register the configured SQLite database to the database config.
    var databases = DatabaseConfig()
    // Step 3
    let databaseConfig = PostgreSQLDatabaseConfig(
        hostname: "localhost",
        username: "vapor",
        database: "vapor",
        password: "password")
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)
    services.register(databases)
    var migrations = MigrationConfig()
    // Step 5
    migrations.add(model: Acronym.self, database: .psql)
    services.register(migrations)

}
