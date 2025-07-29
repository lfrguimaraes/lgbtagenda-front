import SwiftUI

struct CalendarFilters: ToolbarContent {
    @Binding var selectedFilters: Set<String>
    @Binding var selectedDate: Date?
    @Binding var showDatePicker: Bool
    @Binding var showAddEvent: Bool
    var isAdmin: Bool

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button("Clear Filters") {
                    selectedFilters.removeAll()
                    selectedDate = nil
                }
                Toggle("Today", isOn: binding(for: "today"))
                Toggle("Tomorrow", isOn: binding(for: "tomorrow"))
                Toggle("Next Friday", isOn: binding(for: "friday"))
                Toggle("Next Saturday", isOn: binding(for: "saturday"))
                Toggle("Next Sunday", isOn: binding(for: "sunday"))
                Button("Pick a Date") { showDatePicker.toggle() }
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 20))
            }
        }

        if isAdmin {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showAddEvent.toggle() }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20))

                }
            }
        }
    }

    private func binding(for filter: String) -> Binding<Bool> {
        Binding(
            get: { selectedFilters.contains(filter) },
            set: { newValue in
                if newValue {
                    selectedFilters.insert(filter)
                    selectedDate = nil
                } else {
                    selectedFilters.remove(filter)
                }
            }
        )
    }
}
