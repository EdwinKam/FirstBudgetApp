import SwiftUI

struct RootView: View {
    
    @StateObject private var authState = AuthState()
    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack {
            if !showSignInView {
                ContentView(showSignInView: $showSignInView)
                    .onAppear() {
                        Task {
                            do {
                                try await CategoryManager.shared.downloadCategories(authState: authState)
                                try await ProfileManager.shared.createProfileIfNotExist(authState: authState)
                                print("Downloaded categories from Firebase")
                            } catch {
                                print("Failed to download categories: \(error.localizedDescription)")
                            }
                        }
                    }
            }
        }
        .onAppear {
            Task {
                await authState.loadAuthenticatedUser()
                showSignInView = authState.authUser == nil
            }
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthSignIn(showSignInView: $showSignInView)
                    .onDisappear {
                        Task {
                            await authState.loadAuthenticatedUser()
                        }
                    }
            }
        }
        .environmentObject(authState) // Inject the AuthState into the environment
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
