import UIKit
import Foundation
import CoreData
import Combine
protocol ImageRepository {
    func save(_ image: UIImage, for uuid: String) throws
    func load(for uuid: String) -> UIImage?
    func delete(for uuid: String) throws
}
