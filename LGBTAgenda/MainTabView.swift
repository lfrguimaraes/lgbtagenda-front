
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            MapView().tabItem {
                Label("Map", systemImage: "map")
            }
            CalendarView().tabItem {
                Label("Calendar", systemImage: "calendar")
            }
            TicketsView().tabItem {
                Label("Tickets", systemImage: "qrcode")
            }
            ProfileView().tabItem {
                Label("Profile", systemImage: "person.circle")
            }
        }
    }
}
