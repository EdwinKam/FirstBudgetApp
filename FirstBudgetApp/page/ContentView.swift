import SwiftUI
import CoreData
import Charts
import FirebaseFirestore

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var showSignInView: Bool

    // State variable to hold fetched transaction items
    @StateObject private var transactionState = TransactionState()
    @EnvironmentObject var authState: AuthState

    @State private var selectedItem: TransactionItem?
    @State private var selectedCategory: TransactionCategory? // New state for selected category
    @State private var showOptions = false // State to toggle the options
    @State private var showMenuOptions = false // State to toggle the menu options
    @State private var selectedTimePeriod: TimePeriod = .week // State for selected time period
    @State private var currentDate = Date() // State for current date for time period navigation

    // Filtered items based on the selected time period
    private var filteredItems: [TransactionItem] {
        let calendar = Calendar.current
        let now = currentDate

        return transactionState.transactionItems.filter { item in
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
                        BarChartView(transactionItems: filteredItems, timeRange: selectedTimePeriod, timeRangeString: dateRangeString)
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
                .blur(radius: showOptions || showMenuOptions ? 3 : 0)
                .disabled(showOptions || showMenuOptions) // Disable interactions when options are shown

                // Fade out and blur the rest of the page when options are shown
                if showOptions || showMenuOptions {
                    Color.white.opacity(0.6)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                showOptions = false
                                showMenuOptions = false
                            }
                        }
                }

                VStack {
                    HStack {
                        // The circular button
                        Button(action: {
                            withAnimation {
                                showOptions.toggle()
                                showMenuOptions = false // Ensure menu options are hidden
                            }
                        }) {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding()
                                .background(Color(.systemGreen).opacity(0.2))
                                .clipShape(Circle())
                        }
                        .zIndex(1) // Ensure this button is on top
                        .opacity(showMenuOptions ? 0.4 : 1) // Fade out when menu options are shown
                        .disabled(showMenuOptions) // Disable when menu options are shown

                        Spacer()

                        // Menu button
                        Button(action: {
                            withAnimation {
                                showMenuOptions.toggle()
                                showOptions = false // Ensure add options are hidden
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .resizable()
                                .frame(width: 24, height: 16)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Circle())
                        }
                        .zIndex(1) // Ensure this button is on top
                        .opacity(showOptions ? 0.4 : 1) // Fade out when add options are shown
                        .disabled(showOptions) // Disable when add options are shown
                    }
                    .padding()

                    Spacer()
                }

                // The pop-up options for adding new transactions
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
                                    Text(category.name)
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
                    .padding(.top, 80) // Adjust padding to position below the button
                    .padding(.leading, 16) // Adjust padding to position to the right
                }

                // The pop-up options for menu
                if showMenuOptions {
                    VStack(alignment: .trailing, spacing: 10) {
                        Button(action: {
                            do {
                                try authState.signOut()
                                CoreDataManager.shared.deleteAllPersistentStores()
                                // Set showSignInView to true when signed out
                                showSignInView = true
                            } catch {
                                // Handle error appropriately, e.g., show an alert
                                print("Error signing out: \(error.localizedDescription)")
                            }
                        }) {
                            Text("Log Out")
                                .padding()
                                .frame(minWidth: 150)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .transition(AnyTransition.scale(scale: 0.5).combined(with: .opacity))
                    .padding(.top, 80) // Adjust padding to position below the button
                    .padding(.trailing, 16) // Align to the right with some padding
                    .frame(maxWidth: .infinity, alignment: .trailing) // Align to the right edge
                }
            }
        }
        .task {
            TransactionManager.shared.transactionState = transactionState
            await fetchFirebaseTransactions()
        }
    }

    private func fetchFirebaseTransactions() async {
        do {
            let _ = try await TransactionManager.shared.fetchTransactions(authState: authState)
        } catch {
            print("Failed to fetch transactions from Firebase: \(error.localizedDescription)")
        }
    }

    private func selectedCategory(for name: String?) -> TransactionCategory? {
        guard let name = name else { return nil }
        return transactionState.transactionItems.first(where: { $0.category?.name == name })?.category
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
