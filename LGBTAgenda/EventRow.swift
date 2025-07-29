import SwiftUI

struct EventRow: View {
    let event: Event

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(event.name).bold()
                if let price = event.price {
                    Text("Price: \(price)").font(.subheadline).foregroundColor(.gray)
                }
            }
            Spacer()
            if let imageUrl = event.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipped()
                        .cornerRadius(8)
                } placeholder: {
                    Color.gray.frame(width: 50, height: 50).cornerRadius(8)
                }
            }
        }
    }
}
