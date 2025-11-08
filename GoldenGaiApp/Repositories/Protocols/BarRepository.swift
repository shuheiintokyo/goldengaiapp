import Foundation

@MainActor
protocol BarRepository {
    func fetch() -> [Bar]
    func fetchByUUID(_ uuid: String) -> Bar?
    func update(_ bar: Bar) throws
    func delete(_ bar: Bar) throws
    func markVisited(_ uuid: String, timestamp: Date) throws
    func addPhoto(_ uuid: String, photoURL: String) throws
    func addComment(_ uuid: String, comment: String, language: String) throws
}
