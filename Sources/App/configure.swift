import Vapor
import Fluent
import FluentPostgresDriver
import Foundation
func configure(_ app: Application) async throws {
    let workingDir = DirectoryConfiguration.detect().workingDirectory
    let envPath = workingDir + ".env"
    if FileManager.default.fileExists(atPath: envPath) {
        print(".env ファイルが見つかりました: \(envPath)")
    } else {
        print(".env ファイルが見つかりません")
    }
    let dbUser = Environment.get("POSTGRES_USER")!
    let dbPassword = Environment.get("POSTGRES_PASSWORD")!
    let dbName = Environment.get("POSTGRES_DB")!
    let dbHost = Environment.get("POSTGRES_HOSTNAME")!
    let dbPort = Environment.get("POSTGRES_PORT").flatMap(Int.init)!
    // PostgreSQL の設定
    app.databases.use(.postgres(
        hostname: dbHost,
        port: dbPort,
        username: dbUser,
        password: dbPassword,
        database: dbName
    ), as: .psql)
    // register routes
    try routes(app)
}
struct DotEnv {
    static func load(filename: String = ".env") {
        guard let path = Bundle.main.path(forResource: filename, ofType: nil) else {
            print("⚠️ \(filename) file not found")
            return
        }
        
        do {
            let contents = try String(contentsOfFile: path, encoding: .utf8)
            let lines = contents.split(separator: "\n")
            
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // 空行やコメント（# で始まる）をスキップ
                if trimmed.isEmpty || trimmed.hasPrefix("#") {
                    continue
                }
                
                // "KEY=VALUE" 形式の解析
                let parts = trimmed.split(separator: "=", maxSplits: 1)
                if parts.count == 2 {
                    let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
                    let value = String(parts[1]).trimmingCharacters(in: .whitespaces)
                    
                    // 環境変数として設定
                    setenv(key, value, 1)
                }
            }
        } catch {
            print("⚠️ Failed to load \(filename): \(error)")
        }
    }
}
