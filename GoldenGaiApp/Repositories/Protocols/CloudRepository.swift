import Foundation

@MainActor
protocol CloudRepository {
    func syncBars() async throws -> Int
    func uploadImage(_ imageData: Data, for uuid: String) async throws -> String
    func syncBarInfo() async throws -> Int
    func getRemoteBarInfo(for uuid: String) async throws -> BarInfo?
}
