//
//  RootView.swift
//  FirstBudgetApp
//
//  Created by Edwin Kam on 6/2/24.
//

import SwiftUI

struct RootView: View {
    
    @State var showSignInView: Bool = false
    
    var body: some View {
        ZStack {
            if !showSignInView {
                ContentView(showSignInView: $showSignInView)
                    .onAppear() {
                        Task {
                            do {
                                try await CategoryManager.shared.downloadCategories()
                                print("downloaded from firebase")
                            } catch {
                                print("Failed to download categories: \(error.localizedDescription)")
                            }
                        }
                    }
            }
        }
        .onAppear {
            let authUser = try? AuthManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthSignIn(showSignInView: $showSignInView)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
