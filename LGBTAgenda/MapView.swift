// MapView.swift
import SwiftUI
import MapKit
import CoreLocation

struct Event: Identifiable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let imageUrl: String?
    let price: String?
    let date: Date?
}

struct MapView: View {
    @AppStorage("token") var token: String = ""
    @AppStorage("isAdmin") var isAdmin: Bool = false
    @State private var region: MKCoordinateRegion? = nil
    @State private var events: [Event] = []
    @State private var selectedEvent: Event? = nil
    @StateObject private var locationManager = CLLocationManagerWrapper()
    @State private var selectedFilter: String = "today"

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let region = region {
                    Map(coordinateRegion: .constant(region), annotationItems: events) { event in
                        MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)) {
                            VStack {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
                                    .onTapGesture {
                                        selectedEvent = event
                                    }
                            }
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                } else {
                    ProgressView("Loading map...")
                }
            }

            if let event = selectedEvent {
                VStack {
                    Spacer()
                    VStack(alignment: .leading) {
                        if let url = event.imageUrl, let imgURL = URL(string: url) {
                            AsyncImage(url: imgURL) { image in
                                image.resizable().aspectRatio(contentMode: .fill).frame(height: 120).clipped()
                            } placeholder: {
                                Color.gray.frame(height: 120)
                            }
                        }
                        Text(event.name).font(.headline).foregroundColor(.white)
                        if let price = event.price {
                            Text("Price: \(price)").font(.subheadline).foregroundColor(.gray)
                        }
                        NavigationLink(destination: Text("Full event details coming soon")) {
                            Text("View Details")
                                .font(.body)
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.85))
                    .cornerRadius(16)
                    .padding()
                }
                .onTapGesture {
                    selectedEvent = nil
                }
            }

            Menu {
                Button("Today") { selectedFilter = "today"; fetchUserAndEvents() }
                Button("Tomorrow") { selectedFilter = "tomorrow"; fetchUserAndEvents() }
                Button("Next Weekend") { selectedFilter = "weekend"; fetchUserAndEvents() }
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 30))
                    .foregroundColor(.accentColor) // Or remove to use system default
                    .padding(.top, 20)
                    .padding(.trailing)

            }
        }
        .onAppear(perform: initializeMap)
    }

    func initializeMap() {
        locationManager.requestWhenInUseAuthorization()
        fetchUserAndEvents()
    }

    func fetchUserAndEvents() {
        guard let url = URL(string: "http://localhost:5050/api/users/me") else { return }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }

            if let isAdminValue = json["isAdmin"] as? Bool {
                DispatchQueue.main.async {
                    self.isAdmin = isAdminValue
                }
            }

            let preferredCity = json["preferredCity"] as? String

            if let city = preferredCity {
                geocodeCity(city) { location in
                    if let loc = location {
                        DispatchQueue.main.async {
                            self.region = MKCoordinateRegion(center: loc, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                        }
                    }
                    fetchEvents()
                }
            } else {
                if let currentLocation = locationManager.location {
                    let geocoder = CLGeocoder()
                    geocoder.reverseGeocodeLocation(currentLocation) { placemarks, _ in
                        if let country = placemarks?.first?.isoCountryCode {
                            let capital = capitalCity(for: country)
                            geocodeCity(capital) { location in
                                if let loc = location {
                                    DispatchQueue.main.async {
                                        self.region = MKCoordinateRegion(center: loc, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                                    }
                                }
                                fetchEvents()
                            }
                        } else {
                            fetchEvents()
                        }
                    }
                } else {
                    fetchEvents()
                }
            }
        }.resume()
    }

    func fetchEvents() {
        guard let url = URL(string: "http://localhost:5050/api/events") else { return }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return }

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            let filtered: [[String: Any]] = json.filter { dict in
                guard let dateStr = dict["date"] as? String, let date = formatter.date(from: dateStr) else { return false }
                let calendar = Calendar.current
                switch selectedFilter {
                case "today":
                    return calendar.isDateInToday(date)
                case "tomorrow":
                    return calendar.isDateInTomorrow(date)
                case "weekend":
                    let weekday = calendar.component(.weekday, from: date)
                    return [6, 7, 1].contains(weekday)
                default:
                    return true
                }
            }

            let mapped = filtered.compactMap { dict -> Event? in
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
                self.events = mapped
            }
        }.resume()
    }

    func geocodeCity(_ city: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(city) { placemarks, _ in
            completion(placemarks?.first?.location?.coordinate)
        }
    }

    func capitalCity(for isoCountryCode: String) -> String {
        switch isoCountryCode.uppercased() {
        case "FR": return "Paris"
        case "GB": return "London"
        case "DE": return "Berlin"
        case "ES": return "Madrid"
        case "IT": return "Rome"
        case "US": return "Washington DC"
        default: return "Paris"
        }
    }
}

class CLLocationManagerWrapper: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }

    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    var locationServicesEnabled: Bool {
        CLLocationManager.locationServicesEnabled()
    }
}
