import SwiftUI
import CoreData
import Charts

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionItem.createdAt, ascending: false)],
        animation: .default
    ) private var items: FetchedResults<TransactionItem>
    
    @State private var selectedItem: TransactionItem?
    @State private var selectedCategory: TransactionCategory? // New state for selected category
    @State private var showOptions = false // State to toggle the options
    @State private var selectedTimePeriod: TimePeriod = .thisWeek // State for selected time period

    // Enum for time period options
    enum TimePeriod: String, CaseIterable {
        case thisWeek = "This Week"
        case thisMonth = "This Month"
    }

    // Computed property to get the top 2 popular categories
    private var top2Categories: [TransactionCategory] {
        let categoryCounts = Dictionary(grouping: items, by: { $0.category })
            .mapValues { $0.count }
            .sorted(by: { $0.value > $1.value })
            .prefix(2)
            .compactMap { $0.key }
        return categoryCounts
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                // Background layer
                LinearGradient(gradient: Gradient(colors: [Color(.systemGreen).opacity(0.1), Color.white]),
                               startPoint: .top,
                               endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if !items.isEmpty {
                        PieChartView(transactionItems: Array(items), selectedCategory: $selectedCategory, timeRange: selectedTimePeriod.rawValue)
                            .frame(height: 300)
                            .padding()
                        
                        // Segmented control for time period selection
                        Picker("Time Period", selection: $selectedTimePeriod) {
                            ForEach(TimePeriod.allCases, id: \.self) { period in
                                Text(period.rawValue).tag(period)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding([.leading, .trailing, .bottom])
                        
                        TransactionList(items: items, filteredByCategory: selectedCategory)
                    } else {
                        Text("No data to display")
                            .frame(height: 300)
                            .padding()
                    }
                }
                .blur(radius: showOptions ? 3 : 0)
                
                // Fade out and blur the rest of the page when options are shown
                if showOptions {
                    Color.white.opacity(0.6)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                showOptions = false
                            }
                        }
                }

                VStack {
                    // The circular button
                    Button(action: {
                        withAnimation {
                            showOptions.toggle()
                        }
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding()
                            .background(Color(.systemGreen).opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    // The pop-up options
                    if showOptions {
                        VStack(alignment: .leading, spacing: 10) {
                            NavigationLink(destination: NewTransaction()) {
                                Text("Add New Transaction")
                                    .padding()
                                    .frame(minWidth: 150)
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            ForEach(top2Categories, id: \.self) { category in
                                NavigationLink(destination: NewTransaction(selectedCategory: category)) {
                                    Text(category.name ?? "Unknown")
                                        .padding()
                                        .frame(minWidth: 150)
                                        .background(Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .transition(AnyTransition.scale(scale: 0.5).combined(with: .opacity))
                    }
                }
                .padding()
            }
        }
    }

    private func selectedCategory(for name: String?) -> TransactionCategory? {
        guard let name = name else { return nil }
        return items.first(where: { $0.category?.name == name })?.category
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
