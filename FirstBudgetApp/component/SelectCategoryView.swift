import SwiftUI
import CoreData

struct SelectCategoryView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var selectedCategory: TransactionCategory?
    @Binding var isPresentingCategoryPopup: Bool
    @State var categoryToEdit: TransactionCategory?

    // State variables for categories and transactions
    @State private var categories: [TransactionCategory] = []
    @State private var transactions: [TransactionItem] = []
    @EnvironmentObject var authState: AuthState

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        let sortedCategories = sortCategoriesByPopularity(categories: categories, transactions: transactions)
        VStack(alignment: .leading, spacing: 16) {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(sortedCategories) { category in
                    CategoryCircleView(category: category, isSelected: category.id == selectedCategory?.id)
                        .onTapGesture {
                            selectedCategory = category
                        }
                        .onLongPressGesture {
                            categoryToEdit = category // Set category to edit
                            isPresentingCategoryPopup = true
                        }
                }
                PlusCircleView(isSelected: false)
                    .onTapGesture {
                        selectedCategory = nil // Clear selected category for new addition
                        categoryToEdit = nil
                        isPresentingCategoryPopup = true
                    }
            }
        }
        .padding(20)
        .sheet(isPresented: $isPresentingCategoryPopup) {
            NewCategoryPopup(isPresented: $isPresentingCategoryPopup, newCategory: $selectedCategory, editFromCategory: $categoryToEdit)
                .onDisappear() {
                    fetchCategoriesAndTransactions()
                }
        }
        .onAppear {
            fetchCategoriesAndTransactions()
//            NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: viewContext, queue: .main) { _ in
//                fetchCategoriesAndTransactions()
//            }
        }
    }

    private func fetchCategoriesAndTransactions() {
        Task {
            do {
                categories = try await CategoryManager.shared.fetchCategories(authState: authState)
                print("done fetching all catgory in select category view")
                transactions = try await TransactionManager.shared.fetchTransactions(authState: authState)
            } catch {
                print("Failed to fetch data: \(error.localizedDescription)")
            }
        }
    }

    private func sortCategoriesByPopularity(categories: [TransactionCategory], transactions: [TransactionItem]) -> [TransactionCategory] {
        let categoryCounts = transactions.reduce(into: [TransactionCategory: Int]()) { counts, transaction in
            if let category = transaction.category {
                counts[category, default: 0] += 1
            }
        }
        print("print sort popularity category")
        print(categories.map { $0.name })
        return categories.sorted { (category1, category2) -> Bool in
            let count1 = categoryCounts[category1] ?? 0
            let count2 = categoryCounts[category2] ?? 0
            return count1 > count2
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

struct CategoryCircleView: View {
    var category: TransactionCategory
    var isSelected: Bool

    var body: some View {
        VStack {
            let firstLetter = category.name.prefix(1)
            Text(String(firstLetter))
                .font(.headline)
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 2)
                )
            Text(category.name)
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 8)
    }
}

struct PlusCircleView: View {
    var isSelected: Bool

    var body: some View {
        VStack {
            Text("+")
                .font(.headline)
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 2)
                )
            Text("Add")
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 8)
    }
}
