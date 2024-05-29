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
        }
    }
}
