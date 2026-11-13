<div align="center">

# 🕌 QiblaHub

**Islamic companion app — arah kiblat, jadwal salat, kalender Hijriah, dan masjid terdekat dalam satu aplikasi**

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=flat-square&logo=android&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
[![spruce](https://gh-spruce.vercel.app/api/badge?repo=Emil-02/QiblaHub)](https://gh-spruce.vercel.app/u/Emil-02)

📥 **[Download APK (Releases)](https://github.com/Emil-02/QiblaHub/releases/latest)** — pilih `arm64-v8a` untuk kebanyakan HP Android

</div>

---

## ✨ Fitur

- 🧭 **Kompas Kiblat** — arah kiblat realtime berbasis sensor magnetometer + GPS, lengkap dengan derajat & jarak ke Ka'bah
- 🕐 **Jadwal Salat** — perhitungan Muslim World League (Fajr 18°, Isha 17°) sesuai lokasi, dengan hitung mundur salat berikutnya
- 🔔 **Notifikasi Adzan** — pengingat otomatis tiap waktu salat (terjadwal 2 hari ke depan, timezone-aware)
- 🗓️ **Kalender Hijriah** — konversi Umm al-Qura, penanda hari Jumat & hari besar Islam
- 🕌 **Masjid Terdekat** — data asli OpenStreetMap (radius 4 km, diurutkan berdasar jarak), jarak tempuh via rute jalan (OSRM), dan peta interaktif
- 📍 **Deteksi Lokasi Akurat** — GPS high-accuracy + reverse geocoding nama kota
- 🌙 **Mode Gelap & Dwibahasa** — tema terang/gelap, Bahasa Indonesia & English, tersimpan lokal

## 🏗️ Struktur Project

```
lib/
├── main.dart      # Entry point
├── theme.dart     # Tema aplikasi (light/dark)
├── data/          # Model & data statis (masjid, hari besar, i18n)
├── screens/       # Halaman UI (home, kiblat, salat, kalender, masjid, pengaturan)
├── services/      # Kompas, lokasi, notifikasi adzan
├── state/         # State management (Provider) + integrasi API
├── utils/         # Perhitungan waktu salat, kiblat, haversine
└── widgets/       # Komponen reusable
```

## 🚀 Menjalankan

### Prasyarat

- Flutter SDK 3.11+
- Perangkat Android fisik dengan sensor kompas (magnetometer)

### Langkah

```bash
# 1. Clone repository
git clone https://github.com/Emil-02/QiblaHub.git
cd QiblaHub

# 2. Install dependencies
flutter pub get

# 3. Jalankan di device
flutter run

# 4. (Opsional) Build APK release
flutter build apk --release --split-per-abi
```

> 🔑 Untuk menandatangani build release dengan keystore sendiri, buat `android/key.properties`
> (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`). Tanpa file itu build memakai debug key.

> ⚠️ Fitur kompas membutuhkan perangkat fisik — emulator tidak memiliki magnetometer.

## 🧰 Tech Stack

| Fungsi              | Package                                                 |
| ------------------- | ------------------------------------------------------- |
| State management    | provider                                                |
| Lokasi & GPS        | geolocator, geocoding                                   |
| Sensor kompas       | flutter_compass                                         |
| Peta                | flutter_map, latlong2                                   |
| Notifikasi adzan    | flutter_local_notifications, timezone, flutter_timezone |
| Penyimpanan lokal   | shared_preferences                                      |
| HTTP client         | http                                                    |
| Buka Maps eksternal | url_launcher                                            |

## 🌍 Sumber Data (gratis, tanpa API key)

| Data                    | Layanan                      |
| ----------------------- | ---------------------------- |
| Masjid terdekat         | OpenStreetMap Overpass API   |
| Jarak tempuh rute jalan | OSRM                         |
| Nama kota / alamat      | Geocoder perangkat (Android) |
| Peta                    | OpenStreetMap tiles          |

## 🌐 Versi Web

Tersedia juga versi web (HTML/CSS/JS murni, tanpa framework): [Web-QiblaHub](https://github.com/Emil-02/Web-QiblaHub)

## 📄 Lisensi

MIT

---

<div align="center">

Dibuat dengan ❤️ oleh <a href="https://github.com/Emil-02">Emil-02</a>

</div>
