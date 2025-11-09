import Foundation
import CoreData
import Combine
import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let preferencesRepository: PreferencesRepository
    
    init(preferencesRepository: PreferencesRepository = AppStoragePreferencesRepository.shared) {
        self.preferencesRepository = preferencesRepository
    }
    
    func login() async {
        isLoading = true
        errorMessage = nil
        
        // TODO: Implement actual authentication with Appwrite
        // For now, simulate login
        do {
            guard !email.isEmpty && !password.isEmpty else {
                throw BarError.invalidData("Email and password required")
            }
            
            // Simulate delay
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Save login info
            preferencesRepository.setLoginData(
                email: email,
                userId: UUID().uuidString,
                token: "mock-token"
            )
            
            print("✅ Login successful")
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Login failed"
        }
        
        isLoading = false
    }
    
    func signup() async {
        // TODO: Implement signup
    }
}
