
import Foundation

class APIClient {
    static let shared = APIClient()
    let baseURL = "http://localhost:5050/api"

    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { completion(false, nil); return }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let token = json["token"] as? String {
                completion(true, token)
            } else {
                completion(false, nil)
            }
        }.resume()
    }

    func fetchEvents(token: String, completion: @escaping ([[String: Any]]) -> Void) {
        guard let url = URL(string: "\(baseURL)/events") else { return }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                completion(json)
            }
        }.resume()
    }
}
