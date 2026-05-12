# PBM Task Manager — Flutter App
**Tugas Praktikum Pemrograman Berbasis Mobile 2026**

---

## Struktur Project (MVC)
```
lib/
├── models/
│   ├── user_model.dart       ← Model data user
│   └── product_model.dart    ← Model data produk
├── controllers/
│   ├── auth_controller.dart     ← Logika login & token
│   └── product_controller.dart  ← Logika CRUD produk
├── views/
│   ├── login_page.dart          ← Halaman login
│   ├── product_list_page.dart   ← Halaman daftar produk
│   └── add_product_page.dart    ← Halaman tambah produk
├── services/
│   └── api_service.dart         ← HTTP calls ke API
└── main.dart
```

## Fitur
- **Login** dengan NIM sebagai username & password
- **Simpan token** menggunakan `flutter_secure_storage`
- **Tampil daftar produk** (GET /api/products)
- **Tambah produk** (POST /api/products) dengan live preview
- **Logout** dengan konfirmasi dialog
- **Pull-to-refresh** pada halaman list

## Setup & Cara Menjalankan

### 1. Pastikan Flutter SDK sudah terinstall
```bash
flutter --version
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Konfigurasi Android (wajib untuk flutter_secure_storage)
Edit `android/app/build.gradle`, pastikan `minSdkVersion` minimal **23**:
```gradle
android {
    defaultConfig {
        minSdkVersion 23
    }
}
```

### 4. Jalankan aplikasi
```bash
flutter run
```

## API
- **Base URL:** `https://task.itprojects.web.id`
- **Login:** `POST /api/auth/login`
- **Get Products:** `GET /api/products`
- **Add Product:** `POST /api/products`
- **Submit Tugas:** `POST /api/products/submit`

## Dependencies
| Package | Kegunaan |
|---|---|
| `http` | HTTP request ke API |
| `flutter_secure_storage` | Simpan token secara aman |
| `provider` | State management (MVC) |
| `google_fonts` | Font RobotoMono (retro theme) |

## NIM
242410102036