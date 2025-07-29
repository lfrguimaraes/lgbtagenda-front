
import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var error = ""
    @AppStorage("token") var token: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Login").font(.largeTitle)
            TextField("Email", text: $email).textFieldStyle(RoundedBorderTextFieldStyle()).autocapitalization(.none)
            SecureField("Password", text: $password).textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Login") {
                login()
            }.padding()
            Text(error).foregroundColor(.red)
        }.padding()
    }

    func login() {
        APIClient.shared.login(email: email, password: password) { success, tokenValue in
            if success, let t = tokenValue {
                token = t
            } else {
                error = "Login failed"
            }
        }
    }
}
