import Foundation
import FirebaseAuth

class AuthState: ObservableObject {
    @Published var authUser: AuthDataResultModel?
    
    init() {
        Task {
            await self.loadAuthenticatedUser()
        }
    }
    
    func loadAuthenticatedUser() async {
        do {
            let user = try AuthManager.shared.getAuthenticatedUser()
            DispatchQueue.main.async {
                self.authUser = user
            }
        } catch {
            print("Failed to load authenticated user: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.authUser = nil
            }
        }
    }
    
    func signOut() throws {
        try AuthManager.shared.signOut()
        DispatchQueue.main.async {
            self.authUser = nil
        }
    }
}
