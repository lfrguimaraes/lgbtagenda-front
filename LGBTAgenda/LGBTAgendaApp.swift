
import SwiftUI

@main
struct LGBTAgendaApp: App {
    @AppStorage("token") var token: String = ""

    var body: some Scene {
        WindowGroup {
            if token.isEmpty {
                LoginView()
            } else {
                MainTabView()
            }
        }
    }
}
