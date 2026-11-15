# LAPORAN TUGAS ATS PRAKTIKUM PEMROGRAMAN PERANGKAT BERGERAK
## APLIKASI CERTIFY — PERSONAL CERTIFICATE & ACHIEVEMENT MANAGER

---

### IDENTITAS MAHASISWA & PROYEK
- **Nama Aplikasi**: CERTIFY (Personal Certificate & Achievement Manager)
- **Tagline**: *"Your Achievements, Organized in One Place"*
- **Mata Kuliah**: Praktikum Pemrograman Perangkat Bergerak
- **Platform**: Android / Flutter Cross-Platform
- **Bahasa & Framework**: Dart, Flutter 3.x (Material 3)
- **State Management**: Provider (`ChangeNotifier`)
- **Penyimpanan Data**: SharedPreferences (Metadata JSON) & Internal App Storage (`path_provider`)

---

## 1. PENDAHULUAN & GAMBARAN UMUM
Certify adalah aplikasi mobile yang dirancang untuk menyimpan, mengarsipkan, mengelompokkan, dan menampilkan kembali sertifikat atau bukti pencapaian pribadi pengguna. Pengguna dapat menyimpan dokumen dalam format **JPG**, **PNG**, dan **PDF**, mengaitkannya dengan penyelenggara (*organizer*), menandai sertifikat favorit, serta memantau perkembangan prestasi melalui grafik statistik dan lini masa (*timeline*).

Fokus aplikasi adalah pengelolaan dokumen dan portofolio secara lokal di perangkat (*offline-first*), tanpa memerlukan backend internet eksternal sehingga cepat, aman, dan hemat daya.

---

## 2. PEMENUHAN KETENTUAN ATS PRAKTIKUM

### 2.1 Arsitektur dan Halaman (Wajib Minimal 5 Halaman)
Aplikasi Certify memiliki **10 halaman/screen** dengan alur navigasi hierarkis dan bottom navigation bar:
1. **Splash Screen (`SplashScreen`)**: Menampilkan identitas dan logo aplikasi, animasi fade & scale, serta menginisialisasi metadata dan session lokal.
2. **Onboarding / Autentikasi (`LoginScreen`)**: Halaman masuk modern dengan validasi input email/kata sandi, checkbox "Ingat Saya", dialog pemulihan kata sandi, opsi Google Sign-In, serta modal pendaftaran akun baru.
3. **Main Navigation Wrapper (`MainNavigationScreen`)**: Pengendali *Bottom Navigation Bar* (Beranda, Sertifikat, Tambah (+), Favorit, Profil).
4. **Beranda / Dashboard (`HomeScreen`)**: Menampilkan kartu ringkasan portofolio (Total Sertifikat, Favorit, Kategori, Penyelenggara), banner aksi cepat, dan daftar sertifikat terbaru.
5. **Daftar Sertifikat (`CertificatesScreen`)**: Pencarian *real-time*, filter modal lanjutan (kategori, penyelenggara, tahun), pengurutan data (*sorting*), serta *toggle* tampilan Grid/List.
6. **Tambah & Ubah Sertifikat (`AddEditCertificateScreen`)**: Form input dinamis dengan *file picker* (JPG/PNG/PDF), pemilihan preset sampel, pemilih tanggal (*DatePicker*), dan dialog tambah penyelenggara baru secara *inline*.
7. **Detail Sertifikat (`CertificateDetailScreen`)**: Tampilan preview dokumen interaktif (zoom gambar, kanvas sertifikat resmi PDF), informasi kredensial, tautan penyelenggara, fitur bagikan (*Share*), dan hapus dokumen.
8. **Favorit (`FavoritesScreen`)**: Daftar sertifikat yang telah dibintangi/disukai oleh pengguna dengan fungsi pencarian dan *unfavorite* cepat.
9. **Kelola Penyelenggara (`OrganizersScreen`)**: Fitur pengelolaan penyelenggara (*Organizer Management*) dengan relasi *one-to-many*, penghitungan jumlah sertifikat per instansi, edit nama, dan proteksi hapus jika masih terpakai.
10. **Statistik & Timeline (`StatisticsTimelineScreen`)**: Tab grafik batang distribusi sertifikat per tahun, progress bar kategori, dan *vertical chronological timeline* pencapaian dari terbaru ke terlama.
11. **Profil & Pengaturan (`ProfileScreen`)**: Informasi profil mahasiswa/pengguna, menu reset data sampel awal praktikum, dialog info aplikasi, dan fungsi *logout*.

### 2.2 Fungsionalitas Utama (Minimal 3 Fitur Dinamis)
Certify mengimplementasikan lebih dari 5 fitur dinamis utama:
1. **CRUD Sertifikat Penuh**: Menambah, menampilkan, mengubah, dan menghapus sertifikat beserta berkas fisik terkait.
2. **Organizer Management (Relasi One-to-Many & Validasi Duplikasi)**: Penyelenggara baru dapat ditambahkan saat mengisi form sertifikat atau pada halaman khusus. Aplikasi secara cerdas mencegah duplikasi nama (*case-insensitive & trimmed*). Jika nama penyelenggara diubah, semua sertifikat yang terhubung otomatis diperbarui.
3. **Pencarian Dinamis & Multi-Filter Terpadu**: Pengguna dapat mencari kata kunci pada judul, penyelenggara, nomor sertifikat, atau deskripsi, digabungkan dengan filter kategori, penyelenggara, dan tahun.
4. **Pengelolaan & Preview Berkas Dokumen (PDF, JPG, PNG)**:
   - File disalin ke direktori internal aplikasi dengan nama unik UUID.
   - Preview interaktif dokumen gambar dapat di-zoom/pan dan dibuka penuh.
   - Dokumen PDF dapat dibuka menggunakan *external viewer* atau dibagikan melalui `share_plus`.
5. **Statistik Visual & Timeline Interaktif**: Menghitung distribusi persentase per kategori dan visualisasi bar chart jumlah sertifikat per tahun penerbitan.
6. **Sistem Favorit Dinamis**: Toggle bookmark secara langsung dengan pembaruan *state* seketika.

### 2.3 Pengelolaan Data (Dummy Data Awal)
Data awal telah disiapkan sesuai rancangan spesifikasi dokumen (Halaman 9 PDF):
- **4 Penyelenggara Awal**:
  1. *Dicoding Indonesia*
  2. *Politeknik Negeri Batam*
  3. *Binar Academy*
  4. *Himpunan Mahasiswa*
- **6 Sertifikat Sampel Awal**:
  1. *Flutter Development Workshop* (Dicoding, Workshop, 2026, PDF)
  2. *National Programming Competition* (Politeknik Negeri Batam, Competition, 2025, JPG)
  3. *UI/UX Design Webinar* (Binar Academy, Webinar, 2026, PNG)
  4. *Basic Python Programming* (Dicoding, Certification, 2025, PDF)
  5. *Student Leadership Training* (Himpunan Mahasiswa, Organization, 2025, JPG)
  6. *National Seminar on Technology* (Politeknik Negeri Batam, Academic, 2026, PDF)
- Terdapat fitur **"Reset ke Data Dummy Awal"** pada menu profil untuk memudahkan penguji/dosen menguji ulang alur aplikasi.

### 2.4 Manajemen State dan Lifecycle
- Menggunakan arsitektur **Provider + ChangeNotifier** (`AuthProvider`, `OrganizerProvider`, `CertificateProvider`).
- Seluruh *state* diletakkan pada level root di atas `MaterialApp` menggunakan `MultiProvider`.
- **Ketahanan Rotasi Layar & Perpindahan Halaman**: Saat layar diputar (*portrait* / *landscape*) atau pengguna berpindah antar halaman, state data tidak hilang karena tidak disimpan di variabel lokal State widget, melainkan dipertahankan oleh Provider dan secara kontinu tersinkronisasi ke SharedPreferences.

### 2.5 Desain Antarmuka (UI/UX)
- Mengadopsi palet warna modern sesuai standar dokumen perancangan:
  - **Primary**: `#7663E8` (Ungu Modern)
  - **Secondary**: `#A99BFF`
  - **Background**: `#F4F3FA`
  - **Dark Text**: `#22213A`
  - **Muted Text**: `#7A7893`
- Komponen konsisten: Card dengan sudut melengkung 16px, outline border lembut `#E6E5F2`, chip kategori warna-warni, SnackBar mengambang (*floating*), form field terstandar, dan status visual yang jelas.
- Tersedia **Empty State** informatif dengan ikon dan tombol reset ketika data kosong atau hasil pencarian tidak ditemukan.

### 2.6 Penanganan Error (Exception Handling) & Validasi
1. **Validasi Form**:
   - Judul sertifikat wajib diisi dan minimal 3 karakter.
   - Penyelenggara wajib dipilih.
   - Berkas sertifikat wajib dipilih sebelum menyimpan.
   - Email dan kata sandi pada halaman login divalidasi tidak boleh kosong.
2. **Validasi Berkas**:
   - Ekstensi berkas dibatasi hanya `jpg`, `jpeg`, `png`, dan `pdf`.
   - Ukuran berkas dibatasi maksimal 10 MB (`AppConstants.maxFileSizeBytes`), aplikasi menampilkan peringatan jika berkas melebihi kapasitas.
3. **Validasi Duplikasi Penyelenggara**:
   - Memeriksa nama instansi (*case-insensitive*) agar tidak terjadi duplikasi entri.
4. **Proteksi Integritas Relasi Data (*Foreign Key Protection*)**:
   - Menolak penghapusan instansi penyelenggara jika masih ada sertifikat yang menggunakannya.
5. **Exception Handling**:
   - Blok `try-catch` diterapkan pada seluruh operasi I/O berkas, penyimpanan lokal, pembagian berkas, dan pembukaan aplikasi eksternal untuk mencegah *force close*.

---

## 3. STRUKTUR FOLDER PROYEK
```
certify/
├── assets/
│   ├── dummy/
│   │   ├── basic_python.pdf
│   │   ├── flutter_workshop.pdf
│   │   ├── national_programming_competition.jpg
│   │   ├── national_seminar.pdf
│   │   ├── student_leadership.jpg
│   │   └── uiux_design_webinar.png
│   └── images/
│       ├── app_logo.png
│       └── default_avatar.png
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   └── app_constants.dart
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   └── utils/
│   │       ├── date_formatter.dart
│   │       ├── dialog_utils.dart
│   │       └── file_utils.dart
│   ├── models/
│   │   ├── certificate.dart
│   │   └── organizer.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── certificate_provider.dart
│   │   └── organizer_provider.dart
│   ├── repositories/
│   │   ├── certificate_repository.dart
│   │   └── organizer_repository.dart
│   ├── services/
│   │   ├── file_picker_service.dart
│   │   ├── share_service.dart
│   │   └── storage_service.dart
│   ├── screens/
│   │   ├── splash/
│   │   │   └── splash_screen.dart
│   │   ├── onboarding/
│   │   │   └── login_screen.dart
│   │   ├── main_navigation_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── certificates/
│   │   │   ├── add_edit_certificate_screen.dart
│   │   │   ├── certificate_detail_screen.dart
│   │   │   └── certificates_screen.dart
│   │   ├── favorites/
│   │   │   └── favorites_screen.dart
│   │   ├── organizers/
│   │   │   └── organizers_screen.dart
│   │   ├── profile/
│   │   │   └── profile_screen.dart
│   │   └── statistics/
│   │       └── statistics_timeline_screen.dart
│   └── widgets/
│       ├── category_chip.dart
│       ├── certificate_card.dart
│       ├── document_preview_widget.dart
│       ├── empty_state.dart
│       └── stat_card.dart
├── test/
│   └── widget_test.dart
└── pubspec.yaml
```

---

## 4. KODE SUMBER INTI FUNGSIONALITAS

### 4.1 Model Data Sertifikat & Penyelenggara
```dart
// lib/models/certificate.dart
class Certificate {
  final String id;
  final String title;
  final String category;
  final String organizerId;
  final DateTime issueDate;
  final String filePath;
  final String fileType; // 'image' atau 'pdf'
  final String? certificateNumber;
  final String? description;
  final bool isFavorite;

  Certificate({
    required this.id,
    required this.title,
    required this.category,
    required this.organizerId,
    required this.issueDate,
    required this.filePath,
    required this.fileType,
    this.certificateNumber,
    this.description,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'category': category,
    'organizerId': organizerId,
    'issueDate': issueDate.toIso8601String(),
    'filePath': filePath,
    'fileType': fileType,
    'certificateNumber': certificateNumber,
    'description': description,
    'isFavorite': isFavorite,
  };

  factory Certificate.fromMap(Map<String, dynamic> map) => Certificate(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    category: map['category'] ?? 'Lainnya',
    organizerId: map['organizerId'] ?? '',
    issueDate: DateTime.tryParse(map['issueDate'] ?? '') ?? DateTime.now(),
    filePath: map['filePath'] ?? '',
    fileType: map['fileType'] ?? 'image',
    certificateNumber: map['certificateNumber'],
    description: map['description'],
    isFavorite: map['isFavorite'] ?? false,
  );
}
```

### 4.2 State Management & Dynamic Filter Engine
```dart
// lib/providers/certificate_provider.dart (Cuplikan Filter & Pencarian)
List<Certificate> getFilteredCertificates(OrganizerProvider organizerProvider) {
  return _certificates.where((cert) {
    // 1. Filter Pencarian Teks
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      final orgName = organizerProvider.getOrganizerName(cert.organizerId).toLowerCase();
      final title = cert.title.toLowerCase();
      final desc = (cert.description ?? '').toLowerCase();
      final certNo = (cert.certificateNumber ?? '').toLowerCase();

      final matches = title.contains(query) ||
          orgName.contains(query) ||
          desc.contains(query) ||
          certNo.contains(query);
      if (!matches) return false;
    }

    // 2. Filter Kategori
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      if (cert.category.toLowerCase() != _selectedCategory!.toLowerCase()) return false;
    }

    // 3. Filter Penyelenggara
    if (_selectedOrganizerId != null && _selectedOrganizerId!.isNotEmpty) {
      if (cert.organizerId != _selectedOrganizerId) return false;
    }

    // 4. Filter Tahun Penerbitan
    if (_selectedYear != null) {
      if (cert.issueDate.year != _selectedYear) return false;
    }

    return true;
  }).toList()
    ..sort((a, b) {
      switch (_sortBy) {
        case 'oldest': return a.issueDate.compareTo(b.issueDate);
        case 'a-z': return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case 'z-a': return b.title.toLowerCase().compareTo(a.title.toLowerCase());
        case 'newest':
        default: return b.issueDate.compareTo(a.issueDate);
      }
    });
}
```

### 4.3 Logika Proteksi Hapus Penyelenggara & Pencegahan Duplikasi
```dart
// lib/providers/organizer_provider.dart
Future<Organizer> addOrganizer(String rawName) async {
  final trimmedName = rawName.trim();
  if (trimmedName.isEmpty) throw Exception('Nama penyelenggara tidak boleh kosong');

  // Pemeriksaan duplikasi nama secara case-insensitive
  final existing = _organizers.where(
    (o) => o.name.toLowerCase() == trimmedName.toLowerCase(),
  );

  if (existing.isNotEmpty) {
    return existing.first; // Mengembalikan data yang ada agar tidak menduplikasi
  }

  final newOrganizer = Organizer(
    id: _uuid.v4(),
    name: trimmedName,
    createdAt: DateTime.now(),
  );

  _organizers.add(newOrganizer);
  _organizers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  await _repository.saveOrganizers(_organizers);
  notifyListeners();
  return newOrganizer;
}
```

---

## 5. PANDUAN MENJALANKAN APLIKASI
1. Pastikan Flutter SDK telah terinstal:
   ```bash
   flutter doctor
   ```
2. Unduh dependensi:
   ```bash
   flutter pub get
   ```
3. Jalankan pengujian unit & widget:
   ```bash
   flutter test --no-pub
   ```
4. Jalankan aplikasi pada perangkat Android atau emulator:
   ```bash
   flutter run
   ```
5. Untuk demo login praktikum:
   - Klik tombol **"Masuk Akun Demo (1-Click)"** pada layar login.
   - Atau gunakan email: `mahasiswa@polibatam.ac.id` dan password: `123`.

---

## 6. KESIMPULAN
Aplikasi **CERTIFY** berhasil dirancang dan dibangun dengan memenuhi seluruh ketentuan proyek Praktikum Pemrograman Perangkat Bergerak:
- Memiliki 10 layar fungsional dengan navigasi mulus.
- Memiliki fitur CRUD lengkap, organizer management, filter gabungan dinamis, dan penampil dokumen gambar maupun PDF.
- Memiliki dummy data yang kaya dan realistis.
- Menggunakan Provider untuk penanganan state dan lifecycle saat rotasi layar.
- Mengimplementasikan validasi input serta exception handling yang aman dari *force close*.
