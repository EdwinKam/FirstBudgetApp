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

    var body: some View {
        let sortedCategories = sortCategoriesByPopularity(categories: categories, transactions: transactions)
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(sortedCategories.chunked(into: 4)), id: \.self) { rowCategories in
                HStack {
                    ForEach(rowCategories, id: \.self) { category in
                        CategoryCircleView(category: category, isSelected: category == selectedCategory)
                            .onTapGesture {
                                selectedCategory = category
                            }
                            .onLongPressGesture {
                                categoryToEdit = category // Set category to edit
                                isPresentingCategoryPopup = true
                            }
                    }
                    if rowCategories.count < 4 {
                        PlusCircleView(isSelected: false)
                            .onTapGesture {
                                print("press")
                                selectedCategory = nil // Clear selected category for new addition
                                categoryToEdit = nil
                                isPresentingCategoryPopup = true
                            }
                        ForEach(0..<(3 - rowCategories.count), id: \.self) { _ in
                            Spacer()
                        }
                    }
                }
            }
            if sortedCategories.count % 4 == 0 {
                HStack {
                    PlusCircleView(isSelected: false)
                        .onTapGesture {
                            selectedCategory = nil // Clear selected category for new addition
                            categoryToEdit = nil
                            isPresentingCategoryPopup = true
                        }
                    Spacer()
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
                categories = try CategoryManager.shared.fetchCategories()
                print("done fetching all catgory in select category view")
                transactions = try TransactionManager.shared.fetchFromCoreData()
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
        print(categories)
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
            let firstLetter = category.name?.prefix(1) ?? "?"
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
            Text(category.name ?? "")
                .font(.caption)
                .foregroundColor(.primary)
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
        }
        .padding(.horizontal, 8)
    }
}
