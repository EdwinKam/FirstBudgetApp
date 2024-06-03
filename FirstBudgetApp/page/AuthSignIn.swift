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
    
    func signInGoogle() async throws {
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        // waiting the google sign in page result
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
                
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken = gidSignInResult.user.accessToken.tokenString

        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        try await AuthManager.shared.signInWithGoogle(tokens: tokens)
    }
}

struct AuthSignIn: View {
    @StateObject private var viewModel = AuthViewModel()
    var body: some View {
        GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark)){
            Task {
                do {
                    try await viewModel.signInGoogle()
                } catch {
                    
                }
            }
        }
    }
}

#Preview {
    AuthSignIn()
}
