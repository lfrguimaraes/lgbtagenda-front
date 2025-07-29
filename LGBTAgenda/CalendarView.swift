import SwiftUI

struct CalendarView: View {
    @AppStorage("token") var token: String = ""
    @AppStorage("isAdmin") var isAdmin: Bool = false

    @State private var events: [Event] = []
    @State private var selectedFilters: Set<String> = []
    @State private var selectedDate: Date? = nil
    @State private var showDatePicker: Bool = false
    @State private var showAddEvent = false

    var body: some View {
        NavigationView {
            EventList(events: events, selectedFilters: selectedFilters, selectedDate: selectedDate)
                .navigationTitle("Events")
                .toolbar {
                    CalendarFilters(
                        selectedFilters: $selectedFilters,
                        selectedDate: $selectedDate,
                        showDatePicker: $showDatePicker,
                        showAddEvent: $showAddEvent,
                        isAdmin: isAdmin
                    )
                }
        }
        .sheet(isPresented: $showDatePicker) {
            DatePicker("Select Date", selection: Binding(
                get: { selectedDate ?? Date() },
                set: { selectedDate = $0; selectedFilters.removeAll() }
            ), displayedComponents: .date)
            .datePickerStyle(GraphicalDatePickerStyle())
            .padding()
        }
        .sheet(isPresented: $showAddEvent) {
            AddEventView(onSave: fetchEvents)
        }
        .onAppear(perform: fetchEvents)
    }

    func fetchEvents() {
        EventFetcher.fetch(token: token) { events in
            self.events = events
        }
    }
}
