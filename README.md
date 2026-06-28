## Setup

1. Nyalain MySQL lewat XAMPP
2. Backend:
   ```bash
   cd server
   npm install
   cp .env.example .env
   npm run migrate   # auto setup database + tabel
   npm start
   ```
3. Flutter:
   ```bash
   flutter pub get
   flutter run
   ```
`FEATURES.md` ada list feature
