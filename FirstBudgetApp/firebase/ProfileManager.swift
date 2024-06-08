import Foundation
import FirebaseFirestore
import CoreData

class ProfileManager {
    
    static let shared = ProfileManager()
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    func createProfileIfNotExist(authState: AuthState) async throws {
        guard let auth = authState.authUser else {
            throw URLError(.badServerResponse)
        }
        let db = Firestore.firestore()
        
        // Profile document under the user's document
        let profileDocRef = db.collection("users").document(auth.uid).collection("profile").document("profile")

        // Check if profile document exists
        let snapshot = try await profileDocRef.getDocument()
        
        if !snapshot.exists {
            // If profile document does not exist, create it
            let profileData: [String: Any] = [
                "name": "unname"
            ]
            
            try await profileDocRef.setData(profileData)
            print("Profile document created successfully in Firebase")
            
            // Add default categories
            await addDefaultCategories(authState: authState)
        } else {
            print("Profile document already exists in Firebase")
        }
    }
    
    func addDefaultCategories(authState: AuthState) async {
        let defaultCategories = ["Restaurant", "Grocery", "Gas", "Clothes"]
        
        for category in defaultCategories {
            do {
                try await CategoryManager.shared.addCatgoryAsync(name: category, authState: authState)
            } catch {
                print("error adding default category \(category)")
            }
        }
    }
}
