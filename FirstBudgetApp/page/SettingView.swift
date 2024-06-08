////
////  SettingView.swift
////  FirstBudgetApp
////
////  Created by Edwin Kam on 6/3/24.
////
//
//import SwiftUI
//
//@MainActor
//final class SettingViewModel: ObservableObject {
//    
//    @Published private(set) var user: AuthDataResultModel? = nil
//    func loadCurrentUser() throws {
//        self.user = try AuthManager.shared.getAuthenticatedUser()
//    }
//}
//
//struct SettingView: View {
//    
//    @StateObject private var viewModel = SettingViewModel()
//    var body: some View {
//        List {
//            if let user = viewModel.user {
//                Text("UserId: \(user.uid)")
//            }
//        }
//        .onAppear {
//            try? viewModel.loadCurrentUser()
//        }
//        .navigationBarItems(trailing: Button(action: {
//            do {
//                try AuthManager.shared.signOut()
//            } catch {
//                // Handle error appropriately, e.g., show an alert
//                print("Error signing out: \(error.localizedDescription)")
//            }
//        }) {
//            Image(systemName: "power")
//                .resizable()
//                .frame(width: 24, height: 24)
//                .foregroundColor(.red)
//        })
//    }
//}
//
//#Preview {
//    SettingView()
//}
