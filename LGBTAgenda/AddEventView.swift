import SwiftUI
import PhotosUI

struct AddEventView: View {
    @AppStorage("token") var token: String = ""
    @Environment(\.presentationMode) var presentationMode
    var onSave: () -> Void

    @State private var name = ""
    @State private var description = ""
    @State private var instagram = ""
    @State private var website = ""
    @State private var ticketLink = ""
    @State private var address = ""
    @State private var city = ""
    @State private var price = ""
    @State private var date = Date()
    @State private var imageData: Data? = nil
    @State private var showingImagePicker = false

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Description", text: $description)
                TextField("Instagram", text: $instagram)
                TextField("Website", text: $website)
                TextField("Ticket Link", text: $ticketLink)
                TextField("Address", text: $address)
                TextField("City", text: $city)
                TextField("Price", text: $price)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                Button("Select Image") { showingImagePicker.toggle() }
            }
            .navigationTitle("Add Event")
            .navigationBarItems(trailing: Button("Save") { saveEvent() })
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(imageData: $imageData)
            }
        }
    }

    func saveEvent() {
        guard let url = URL(string: "http://localhost:5050/api/events") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let event: [String: Any] = [
            "name": name,
            "description": description,
            "instagram": instagram,
            "website": website,
            "ticketLink": ticketLink,
            "address": address,
            "city": city,
            "price": price,
            "date": ISO8601DateFormatter().string(from: date),
            "image": imageData?.base64EncodedString() ?? ""
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: event)

        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                DispatchQueue.main.async {
                    onSave()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }.resume()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                if let uiImage = image as? UIImage, let data = uiImage.jpegData(compressionQuality: 0.8) {
                    DispatchQueue.main.async {
                        self.parent.imageData = data
                    }
                }
            }
        }
    }
}
