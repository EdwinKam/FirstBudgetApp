import SwiftUI
import CoreData

struct SelectCategoryView: View {
    @FetchRequest(
        sortDescriptors: [],
        animation: .default
    ) private var categories: FetchedResults<TransactionCategory>

    @Binding var selectedCategory: TransactionCategory?
    @Binding var isPresentingCategoryPopup: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Select Category")
                .font(.headline)
                .padding(.bottom, 10)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(categories.enumerated()), id: \.element) { index, category in
                        if index % 4 == 0 {
                            HStack {
                                ForEach(index..<min(index + 4, categories.count), id: \.self) { innerIndex in
                                    CategoryCircleView(category: categories[innerIndex], isSelected: categories[innerIndex] == selectedCategory)
                                        .onTapGesture {
                                            selectedCategory = categories[innerIndex]
                                        }
                                }
                                // Add PlusCircleView if there's space in the current row
                                if index + 4 >= categories.count {
                                    PlusCircleView(isSelected: false)
                                        .onTapGesture {
                                            isPresentingCategoryPopup = true
                                        }
                                    ForEach(0..<(4 - (categories.count % 4) - 1), id: \.self) { _ in
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    // Add PlusCircleView in a new row if the last row is full
                    if categories.count % 4 == 0 {
                        HStack {
                            PlusCircleView(isSelected: false)
                                .onTapGesture {
                                    isPresentingCategoryPopup = true
                                }
                            ForEach(0..<3, id: \.self) { _ in
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .sheet(isPresented: $isPresentingCategoryPopup) {
                NewCategoryPopup(isPresented: $isPresentingCategoryPopup, newCategory: $selectedCategory)
            }
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
