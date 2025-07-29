
# LGBT Agenda App

### ✅ Features
- Admin-only event creation (name, address, QR ticket link, geo support)
- Public users see events on a map (pins + heatmap)
- Users upload tickets with QR codes (viewable in app)
- Profile with tribe, position, name, image, age
- Ticket vault for event check-in
- SwiftUI iOS frontend
- React admin panel
- Node/Express backend with MongoDB Atlas and Cloudinary

### 🛠 Setup
1. Copy `.env.example` to `.env` in `backend/`, fill with your credentials
2. Run backend:
```bash
cd backend
npm install
node server.js
```
3. Run admin dashboard:
```bash
cd admin-dashboard
npm install
npm run dev
```
4. Run iOS app:
Open `iosApp/LGBTApp.xcodeproj` in Xcode and run on a simulator.

Ensure you have MongoDB Atlas and Cloudinary accounts set up.
