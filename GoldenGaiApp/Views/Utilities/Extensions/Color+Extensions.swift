import SwiftUI

extension Color {
    static let brandPrimary = Color(red: 0.2, green: 0.3, blue: 0.8)
    static let brandSecondary = Color(red: 0.95, green: 0.5, blue: 0.2)
    static let backgroundLight = Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor.black : UIColor.white })
}
