import SwiftUI

struct EventList: View {
    let events: [Event]
    let selectedFilters: Set<String>
    let selectedDate: Date?

    var body: some View {
        List {
            ForEach(groupedEvents.keys.sorted(), id: \.self) { key in
                Section(header: Text(sectionTitle(for: key))) {
                    ForEach(groupedEvents[key] ?? []) { event in
                        EventRow(event: event)
                    }
                }
            }
        }
    }

    var groupedEvents: [Date: [Event]] {
        let calendar = Calendar.current
        let filtered = events.filter { event in
            guard let date = event.date else { return false }

            if let selectedDate = selectedDate {
                return calendar.isDate(date, inSameDayAs: selectedDate)
            }

            if selectedFilters.isEmpty { return true }

            for filter in selectedFilters {
                let weekday = calendar.component(.weekday, from: date)
                switch filter {
                case "today":
                    if calendar.isDateInToday(date) { return true }
                case "tomorrow":
                    if calendar.isDateInTomorrow(date) { return true }
                case "friday":
                    if weekday == 6 { return true }
                case "saturday":
                    if weekday == 7 { return true }
                case "sunday":
                    if weekday == 1 { return true }
                default: break
                }
            }
            return false
        }
        return Dictionary(grouping: filtered) {
            calendar.startOfDay(for: $0.date ?? Date())
        }
    }

    func sectionTitle(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInTomorrow(date) { return "Tomorrow" }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"

        return formatter.string(from: date)
    }
}
