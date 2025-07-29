import Foundation

class EventFetcher {
    static func fetch(token: String, completion: @escaping ([Event]) -> Void) {
        guard let url = URL(string: "http://localhost:5050/api/events") else { return }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                DispatchQueue.main.async { completion([]) }
                return
            }

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            let mapped = json.compactMap { dict -> Event? in
                guard let id = dict["_id"] as? String,
                      let name = dict["name"] as? String,
                      let location = dict["location"] as? [String: Any],
                      let lat = location["lat"] as? Double,
                      let lon = location["lng"] as? Double else { return nil }

                let imageUrl = dict["imageUrl"] as? String
                let price = dict["price"] as? String
                let dateString = dict["date"] as? String
                let date = dateString.flatMap { formatter.date(from: $0) }
                return Event(id: id, name: name, latitude: lat, longitude: lon, imageUrl: imageUrl, price: price, date: date)
            }

            DispatchQueue.main.async {
                completion(mapped)
            }
        }.resume()
    }
}
