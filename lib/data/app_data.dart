/// ═══════════════════════════════════════════════════
/// QiblaHub — Data Aplikasi
/// Semua data statis / mock tersimpan di sini
/// ═══════════════════════════════════════════════════
library;

/// ---------- Konstanta lokasi ----------
class Kaaba {
  static const double lat = 21.422487;
  static const double lon = 39.826206;
}

class DefaultLocation {
  static const double lat = -6.1751;
  static const double lon = 106.8650;
  static const String name = 'Jakarta, Indonesia';
}

/// ---------- Model masjid ----------
class Mosque {
  final int id;
  final String name;
  final String address;
  final double lat;
  final double lon;

  const Mosque({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
  });
}

/// ---------- Data masjid (mock) ----------
const List<Mosque> mosques = [
  Mosque(
    id: 1,
    name: 'Masjid Istiqlal',
    address: 'Jl. Taman Wijaya Kusuma, Ps. Baru, Sawah Besar, Jakarta Pusat',
    lat: -6.1702,
    lon: 106.8311,
  ),
  Mosque(
    id: 2,
    name: 'Masjid Agung Sunda Kelapa',
    address: 'Jl. Taman Sunda Kelapa No.16, Menteng, Jakarta Pusat',
    lat: -6.1994,
    lon: 106.8329,
  ),
  Mosque(
    id: 3,
    name: 'Masjid Cut Meutia',
    address: 'Jl. Cut Mutia No.1, Menteng, Jakarta Pusat',
    lat: -6.1856,
    lon: 106.8352,
  ),
  Mosque(
    id: 4,
    name: 'Masjid Al-Azhar',
    address: 'Jl. Sisingamangaraja, Kebayoran Baru, Jakarta Selatan',
    lat: -6.2380,
    lon: 106.7995,
  ),
  Mosque(
    id: 5,
    name: 'Masjid Raya Jakarta Islamic Centre',
    address: 'Jl. Kramat Jaya Raya, Tugu Utara, Koja, Jakarta Utara',
    lat: -6.1163,
    lon: 106.9057,
  ),
  Mosque(
    id: 6,
    name: 'Masjid At-Tin',
    address: 'Jl. Taman Mini I, Pinang Ranti, Makasar, Jakarta Timur',
    lat: -6.2891,
    lon: 106.8830,
  ),
  Mosque(
    id: 7,
    name: "Masjid Raya KH Hasyim Asy'ari",
    address: 'Jl. Daan Mogot KM.14,5 No.6, Semanan, Kalideres, Jakarta Barat',
    lat: -6.1583,
    lon: 106.7095,
  ),
  Mosque(
    id: 8,
    name: 'Masjid Babussalam',
    address: 'Jl. Kebon Sirih Timur Dalam, Kb. Sirih, Menteng, Jakarta Pusat',
    lat: -6.1830,
    lon: 106.8290,
  ),
];

/// ---------- Hari besar Islam ----------
class IslamicHoliday {
  final int day;
  final int month; // 1 = Muharram … 12 = Dzulhijjah
  final String name;
  final String nameEn;

  const IslamicHoliday(this.day, this.month, this.name, this.nameEn);
}

const List<IslamicHoliday> islamicHolidays = [
  IslamicHoliday(1, 1, 'Tahun Baru Hijriah', 'Islamic New Year'),
  IslamicHoliday(10, 1, 'Hari Asyura', 'Day of Ashura'),
  IslamicHoliday(12, 3, 'Maulid Nabi Muhammad ﷺ', 'Mawlid an-Nabi'),
  IslamicHoliday(27, 7, "Isra' Mi'raj", 'Isra and Mi\'raj'),
  IslamicHoliday(15, 8, "Nisfu Sya'ban", 'Mid-Sha\'ban'),
  IslamicHoliday(1, 9, 'Awal Ramadan', 'First day of Ramadan'),
  IslamicHoliday(17, 9, "Nuzulul Qur'an", 'Nuzul al-Quran'),
  IslamicHoliday(1, 10, 'Idulfitri', 'Eid al-Fitr'),
  IslamicHoliday(9, 12, 'Hari Arafah', 'Day of Arafah'),
  IslamicHoliday(10, 12, 'Iduladha', 'Eid al-Adha'),
];

/// ---------- Nama bulan Hijriah ----------
const List<String> hijriMonths = [
  '',
  'Muharram',
  'Safar',
  "Rabi'ul Awal",
  "Rabi'ul Akhir",
  'Jumadil Awal',
  'Jumadil Akhir',
  'Rajab',
  "Sya'ban",
  'Ramadan',
  'Syawal',
  "Dzulqa'dah",
  'Dzulhijjah',
];

/// ---------- Terjemahan UI ----------
const Map<String, Map<String, String>> i18n = {
  'id': {
    'gregorian': 'Masehi',
    'hijri': 'Hijriah',
    'nextPrayer': 'Salat Berikutnya',
    'countdown': 'Hitung mundur',
    'mainFeatures': 'Fitur Utama',
    'todaySchedule': 'Jadwal Hari Ini',
    'developmentTeamTitle': 'Tim Pengembang QiblaHub',
    'teamProject': 'Proyek PKM AIK',
    'teamGroup': 'Kelompok 2',
    'teamSupervisedBy': 'Dibimbing oleh',
    'teamLecturer': 'Dosen Pendamping',
    'teamStudents': 'Mahasiswa',
    'teamStudentCount': '{count} Anggota Mahasiswa',
    'viewTeam': 'Lihat Tim',
    'downloadQiblaHubApk': 'Download QiblaHub APK',
    'downloadOpenError': 'Tidak dapat membuka halaman download',
    'sourceCode': 'Kode sumber',
    'sourceCodeOpenError': 'Tidak dapat membuka halaman kode sumber',
    'qiblaDirection': 'Arah Kiblat',
    'qiblaDesc': 'Kompas kiblat akurat',
    'prayerTimes': 'Jadwal Salat',
    'prayerDesc': 'Waktu salat hari ini',
    'nearbyMosques': 'Masjid Terdekat',
    'mosquesDesc': 'Temukan masjid sekitar',
    'hijriCalendar': 'Kalender Hijriah',
    'calendarDesc': 'Tanggal & hari besar',
    'qiblaBearing': 'Arah Kiblat',
    'heading': 'Arah Anda',
    'distanceKaaba': "Jarak ke Ka'bah",
    'qiblaInstruction':
        "Letakkan ponsel pada permukaan datar, lalu putar perlahan hingga ikon Ka'bah sejajar dengan penunjuk atas.",
    'calibrationNeeded': 'Kompas perlu kalibrasi',
    'calibrationHint':
        'Gerakkan ponsel membentuk angka 8 beberapa kali, dan jauhkan dari benda logam/magnet.',
    'sensorOff': 'Sensor kompas tidak tersedia',
    'trueNorthActive': 'Utara sejati aktif',
    'declination': 'deklinasi',
    'refreshLocation': 'Perbarui Lokasi',
    'prayerMethodNote': 'Perhitungan: Muslim World League (Fajr 18°, Isha 17°)',
    'todayHijri': 'Hari ini (Hijriah)',
    'today': 'Hari ini',
    'holiday': 'Hari besar',
    'islamicHolidays': 'Hari Besar Islam',
    'mosqueList': 'Daftar Masjid',
    'distance': 'Jarak',
    'coordinates': 'Koordinat',
    'route': 'Rute',
    'openMaps': 'Buka di Maps',
    'navigate': 'Navigasi',
    'profile': 'Pengaturan',
    'guestUser': 'QiblaHub',
    'settings': 'Pengaturan',
    'darkMode': 'Mode Gelap',
    'adhanAlarm': 'Alarm Adzan',
    'language': 'Bahasa',
    'about': 'Tentang',
    'aboutApp': 'Tentang Aplikasi',
    'privacy': 'Kebijakan Privasi',
    'version': 'Versi',
    'close': 'Tutup',
    'navHome': 'Beranda',
    'navMosque': 'Masjid',
    'navCalendar': 'Kalender',
    'navProfile': 'Pengaturan',
    'greetingMorning': 'Semoga pagimu penuh berkah',
    'greetingAfternoon': 'Semoga harimu penuh berkah',
    'greetingEvening': 'Semoga malammu penuh berkah',
    'locationUpdated': 'Lokasi berhasil diperbarui',
    'locationDenied': 'Izin lokasi ditolak — memakai lokasi default',
    'searchPlaceholder': 'Cari masjid…',
    'noMosque': 'Masjid tidak ditemukan',
    'noAddress': 'Alamat tidak tersedia',
    'loadingMosques': 'Memuat masjid di sekitar Anda…',
    'nearest': 'Terdekat',
    'now': 'Sekarang',
    'notPrayerTime': 'Bukan waktu salat',
    'detectingLocation': 'Mendeteksi lokasi…',
    'aboutBody':
        'QiblaHub adalah aplikasi pendamping ibadah digital yang membantu Anda menemukan arah kiblat, jadwal salat, kalender Hijriah, dan masjid terdekat berbasis lokasi.\n\nAplikasi ini dikembangkan sebagai proyek akhir akademik dengan fokus pada kemudahan penggunaan, aksesibilitas, dan desain modern yang elegan.',
    'privacyBody':
        'QiblaHub menghormati privasi Anda:\n\n• Data lokasi hanya digunakan di perangkat untuk menghitung arah kiblat, jadwal salat, dan jarak masjid.\n\n• Tidak ada data pribadi yang dikumpulkan, disimpan di server, atau dibagikan kepada pihak ketiga.\n\n• Preferensi tema dan bahasa disimpan secara lokal di perangkat Anda.',
  },
  'en': {
    'gregorian': 'Gregorian',
    'hijri': 'Hijri',
    'nextPrayer': 'Next Prayer',
    'countdown': 'Countdown',
    'mainFeatures': 'Main Features',
    'todaySchedule': "Today's Schedule",
    'developmentTeamTitle': 'QiblaHub Development Team',
    'teamProject': 'AIK Community Service Project',
    'teamGroup': 'Group 2',
    'teamSupervisedBy': 'Supervised by',
    'teamLecturer': 'Supervising Lecturer',
    'teamStudents': 'Students',
    'teamStudentCount': '{count} Student Members',
    'viewTeam': 'View Team',
    'downloadQiblaHubApk': 'Download QiblaHub APK',
    'downloadOpenError': 'Unable to open the download page',
    'sourceCode': 'Source Code',
    'sourceCodeOpenError': 'Unable to open the source code page',
    'qiblaDirection': 'Qibla Direction',
    'qiblaDesc': 'Accurate qibla compass',
    'prayerTimes': 'Prayer Times',
    'prayerDesc': "Today's prayer schedule",
    'nearbyMosques': 'Nearby Mosques',
    'mosquesDesc': 'Find mosques around you',
    'hijriCalendar': 'Hijri Calendar',
    'calendarDesc': 'Dates & holidays',
    'qiblaBearing': 'Qibla Bearing',
    'heading': 'Your Heading',
    'distanceKaaba': 'Distance to Kaaba',
    'qiblaInstruction':
        'Place your phone on a flat surface, then rotate slowly until the Kaaba icon aligns with the top marker.',
    'calibrationNeeded': 'Compass needs calibration',
    'calibrationHint':
        'Move your phone in a figure-8 motion a few times, away from metal/magnetic objects.',
    'sensorOff': 'Compass sensor unavailable',
    'trueNorthActive': 'True north active',
    'declination': 'declination',
    'refreshLocation': 'Refresh Location',
    'prayerMethodNote': 'Calculation: Muslim World League (Fajr 18°, Isha 17°)',
    'todayHijri': 'Today (Hijri)',
    'today': 'Today',
    'holiday': 'Holiday',
    'islamicHolidays': 'Islamic Holidays',
    'mosqueList': 'Mosque List',
    'distance': 'Distance',
    'coordinates': 'Coordinates',
    'route': 'Route',
    'openMaps': 'Open in Maps',
    'navigate': 'Navigate',
    'profile': 'Settings',
    'guestUser': 'QiblaHub',
    'settings': 'Settings',
    'darkMode': 'Dark Mode',
    'adhanAlarm': 'Adhan Alarm',
    'language': 'Language',
    'about': 'About',
    'aboutApp': 'About Application',
    'privacy': 'Privacy Policy',
    'version': 'Version',
    'close': 'Close',
    'navHome': 'Home',
    'navMosque': 'Mosque',
    'navCalendar': 'Calendar',
    'navProfile': 'Settings',
    'greetingMorning': 'May your morning be blessed',
    'greetingAfternoon': 'May your day be blessed',
    'greetingEvening': 'May your evening be blessed',
    'locationUpdated': 'Location updated successfully',
    'locationDenied': 'Location denied — using default location',
    'searchPlaceholder': 'Search mosques…',
    'noMosque': 'No mosques found',
    'noAddress': 'Address unavailable',
    'loadingMosques': 'Loading mosques around you…',
    'nearest': 'Nearest',
    'now': 'Now',
    'notPrayerTime': 'Not a prayer time',
    'detectingLocation': 'Detecting location…',
    'aboutBody':
        'QiblaHub is a digital worship companion that helps you find the qibla direction, prayer times, the Hijri calendar, and nearby mosques using location-based services.\n\nThis application was developed as an academic final project focusing on usability, accessibility, and elegant modern design.',
    'privacyBody':
        'QiblaHub respects your privacy:\n\n• Location data is only used on-device to calculate the qibla direction, prayer times, and mosque distances.\n\n• No personal data is collected, stored on servers, or shared with third parties.\n\n• Theme and language preferences are saved locally on your device.',
  },
};
