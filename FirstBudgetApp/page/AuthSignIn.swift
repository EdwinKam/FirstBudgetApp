//
//  AuthSignIn.swift
//  FirstBudgetApp
//
//  Created by Edwin Kam on 6/2/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

@MainActor
final class AuthViewModel: ObservableObject {
    
    func signInGoogle(authState: AuthState) async throws {
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        // waiting for the google sign-in page result
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
                
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken = gidSignInResult.user.accessToken.tokenString

        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        try await AuthManager.shared.signInWithGoogle(tokens: tokens)

        // Load authenticated user into the authState
        await authState.loadAuthenticatedUser()
    }
}

struct AuthSignIn: View {
    @StateObject private var viewModel = AuthViewModel()
    @EnvironmentObject var authState: AuthState
    @Binding var showSignInView: Bool

    var body: some View {
        VStack {
            // Header
            Text("Welcome to FirstBudgetApp")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)
            
            Text("Sign in to continue")
                .font(.title2)
                .foregroundColor(.gray)
                .padding(.bottom, 50)
            
            Spacer()
            
            // Google Sign-In Button
            Button(action: {
                Task {
                    do {
                        try await viewModel.signInGoogle(authState: authState)
                        // Set showSignInView to false when sign-in is successful
                        showSignInView = false
                    } catch {
                        // Handle error appropriately, e.g., show an alert
                        print("Error signing in: \(error.localizedDescription)")
                    }
                }
            }) {
                HStack {
                    if let googleLogo = UIImage(named: "google_logo") {
                        Image(uiImage: googleLogo)
                            .resizable()
                            .frame(width: 24, height: 24)
                    } else {
                        // Default image if google_logo is not found
                        Image(systemName: "globe")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    Text("Sign in with Google")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
            }
            .padding(.horizontal, 50)
            
            Spacer()
            
            // Footer
            Text("By signing in, you agree to our Terms and Privacy Policy.")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.2), Color.white]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
    }
}

#Preview {
    AuthSignIn(showSignInView: .constant(true))
}
