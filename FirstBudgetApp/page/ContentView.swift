import SwiftUI
import CoreData
import Charts
import FirebaseFirestore

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var showSignInView: Bool

    // State variable to hold fetched items
    @State private var items: [TransactionItem] = []

    @State private var selectedItem: TransactionItem?
    @State private var selectedCategory: TransactionCategory? // New state for selected category
    @State private var showOptions = false // State to toggle the options
    @State private var selectedTimePeriod: TimePeriod = .week // State for selected time period
    @State private var currentDate = Date() // State for current date for time period navigation

    // Filtered items based on the selected time period
    private var filteredItems: [TransactionItem] {
        let calendar = Calendar.current
        let now = currentDate

        return items.filter { item in
            guard let createdAt = item.createdAt else { return false }

            switch selectedTimePeriod {
            case .week:
                return calendar.isDate(createdAt, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(createdAt, equalTo: now, toGranularity: .month)
            }
        }
    }

    // Computed property to get the top 2 popular categories
    private var top2Categories: [TransactionCategory] {
        let categoryCounts = Dictionary(grouping: filteredItems, by: { $0.category })
            .mapValues { $0.count }
            .sorted(by: { $0.value > $1.value })
            .prefix(2)
            .compactMap { $0.key }
        return categoryCounts
    }

    // Computed property to get the date range string based on the selected time period
    private var dateRangeString: String {
        let calendar = Calendar.current
        let formatter = DateFormatter()

        switch selectedTimePeriod {
        case .week:
            formatter.dateStyle = .short
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
            let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
            return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
        case .month:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: currentDate)
        }
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
                    if !filteredItems.isEmpty {
                        PieChartView(transactionItems: filteredItems, selectedCategory: $selectedCategory, timeRange: selectedTimePeriod, timeRangeString: dateRangeString)
                            .frame(height: 300)
                            .padding()
                    } else {
                        Text("No data to display")
                            .frame(height: 300)
                            .padding()
                    }
                    
                    // Segmented control for time period selection
                    Picker("Time Period", selection: $selectedTimePeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding([.leading, .trailing, .bottom])
                    
                    // Display date range and navigation arrows
                    HStack {
                        Button(action: {
                            withAnimation {
                                adjustDate(by: -1)
                            }
                        }) {
                            Image(systemName: "arrow.left")
                        }
                        Spacer()
                        Text(dateRangeString)
                        Spacer()
                        Button(action: {
                            withAnimation {
                                adjustDate(by: 1)
                            }
                        }) {
                            Image(systemName: "arrow.right")
                        }
                        .disabled(isFutureDate()) // Disable the button if it navigates to the future
                    }
                    .padding()

                    if !filteredItems.isEmpty {
                        TransactionList(items: filteredItems, filteredByCategory: selectedCategory)
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
                            NavigationLink(
                                destination: NewTransaction().onDisappear {
                                    showOptions = false
                                },
                                label: {
                                    Text("Add New Transaction")
                                        .padding()
                                        .frame(minWidth: 150)
                                        .background(Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            )
                            ForEach(top2Categories, id: \.self) { category in
                                NavigationLink(
                                    destination: NewTransaction(selectedCategory: category).onDisappear {
                                        showOptions = false
                                    },
                                    label: {
                                        Text(category.name ?? "Unknown")
                                            .padding()
                                            .frame(minWidth: 150)
                                            .background(Color.gray)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                )
                            }
                        }
                        .transition(AnyTransition.scale(scale: 0.5).combined(with: .opacity))
                    }
                }
                .padding()
            }
            .navigationBarItems(trailing: Button(action: {
                do {
                    try AuthManager.shared.signOut()
                    CoreDataManager.shared.deleteAllPersistentStores()
                    // Set showSignInView to true when signed out
                    showSignInView = true
                } catch {
                    // Handle error appropriately, e.g., show an alert
                    print("Error signing out: \(error.localizedDescription)")
                }
            }) {
                Image(systemName: "power")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.red)
            })
        }
        .task {
            await fetchFirebaseTransactions()
        }
    }

    private func fetchFirebaseTransactions() async {
        do {
            items = try await TransactionManager.shared.fetchTransactions()
        } catch {
            print("Failed to fetch transactions from Firebase: \(error.localizedDescription)")
        }
    }

    private func selectedCategory(for name: String?) -> TransactionCategory? {
        guard let name = name else { return nil }
        return items.first(where: { $0.category?.name == name })?.category
    }

    private func adjustDate(by value: Int) {
        let calendar = Calendar.current
        var newDate: Date?
        
        switch selectedTimePeriod {
        case .week:
            newDate = calendar.date(byAdding: .weekOfYear, value: value, to: currentDate)
        case .month:
            newDate = calendar.date(byAdding: .month, value: value, to: currentDate)
        }
        
        if let newDate = newDate, newDate <= Date() {
            currentDate = newDate
        }
    }

    private func isFutureDate() -> Bool {
        let calendar = Calendar.current
        var newDate: Date?
        
        switch selectedTimePeriod {
        case .week:
            newDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)
        case .month:
            newDate = calendar.date(byAdding: .month, value: 1, to: currentDate)
        }
        
        if let newDate = newDate {
            return newDate > Date()
        }
        
        return false
    }
}

#Preview {
    ContentView(showSignInView: .constant(true)).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
