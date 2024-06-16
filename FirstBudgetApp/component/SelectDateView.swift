import SwiftUI

struct SelectDateView: View {
    @Binding var selectedDate: Date
    @State private var currentMonth: Date = Date()

    private let calendar = Calendar.current
    private let colors = (selected: Color.blue, default: Color.clear, text: Color.black)

    var body: some View {
        VStack {
            // Month navigation
            HStack {
                Button(action: {
                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                }) {
                    Image(systemName: "arrow.left")
                }
                Spacer()
                Text(monthYearString(from: currentMonth))
                    .font(.headline)
                Spacer()
                Button(action: {
                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                }) {
                    Image(systemName: "arrow.right")
                }
            }
            .padding()

            // Day names
            let dayNames = calendar.shortStandaloneWeekdaySymbols
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(dayNames, id: \.self) { dayName in
                    Text(dayName)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            // Calendar month view
            let days = daysInMonth(for: currentMonth)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) {
                ForEach(days, id: \.self) { date in
                    if calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) {
                        Text(dayString(from: date))
                            .frame(width: 30, height: 30)
                            .background(isSameDay(date1: date, date2: selectedDate) ? colors.selected : colors.default)
                            .clipShape(Circle())
                            .foregroundColor(isSameDay(date1: date, date2: selectedDate) ? .white : colors.text)
                            .onTapGesture {
                                selectedDate = date
                                print("clicking")
                            }
                    } else {
                        Text("")
                            .frame(width: 30, height: 30)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            currentMonth = startOfMonth(for: selectedDate)
        }
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func dayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private func daysInMonth(for date: Date) -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        var days: [Date] = []
        var current = monthFirstWeek.start
        while current < monthInterval.end {
            days.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }

        // Add leading days from the previous month to fill the first week
        if let firstDayOfMonth = days.first, let firstWeekday = calendar.dateComponents([.weekday], from: firstDayOfMonth).weekday {
            for i in 1..<firstWeekday {
                if let previousDay = calendar.date(byAdding: .day, value: -i, to: firstDayOfMonth) {
                    days.insert(previousDay, at: 0)
                }
            }
        }

        // Add trailing days from the next month to fill the last week
        if let lastDayOfMonth = days.last, let lastWeekday = calendar.dateComponents([.weekday], from: lastDayOfMonth).weekday {
            for i in 1...(7 - lastWeekday) {
                if let nextDay = calendar.date(byAdding: .day, value: i, to: lastDayOfMonth) {
                    days.append(nextDay)
                }
            }
        }

        return days
    }

    private func startOfMonth(for date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }

    private func isSameDay(date1: Date, date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }
}

struct SelectDateView_Previews: PreviewProvider {
    static var previews: some View {
        SelectDateView(selectedDate: .constant(Date()))
    }
}
