# Flutter App
**Tugas Praktikum Pemrograman Berbasis Mobile**

---

Berikut adalah tampilan dari setiap halaman dalam aplikasi:

<div align="center">
  <table>
    <tr>
      <td align="center">
        <img src="./login.png" width="200" alt="Halaman Login"/>
        <br/><b>Login Page</b>
      </td>
      <td align="center">
        <img src="./product%20catalog.png" width="200" alt="Katalog Produk"/>
        <br/><b>Product Catalog</b>
      </td>
    </tr>
    <tr>
      <td align="center">
        <img src="./add%20product.png" width="200" alt="Tambah Produk"/>
        <br/><b>Add Product</b>
      </td>
      <td align="center">
        <img src="./submit%20tugas.png" width="200" alt="Halaman Submit Tugas"/>
        <br/><b>Submit Tugas</b>
      </td>
    </tr>
  </table>
</div>

---

## Struktur Project
```
lib/
├── models/
│   ├── user_model.dart      
│   └── product_model.dart   
├── controllers/
│   ├── auth_controller.dart     
│   └── product_controller.dart  
├── views/
│   ├── login_page.dart          
│   ├── product_list_page.dart  
│   └── add_product_page.dart   
|   └── submit_page.dart
├── services/
│   └── api_service.dart         
└── main.dart
```


## Setup & Cara Menjalankan

### 1. Pastikan Flutter SDK sudah terinstall
```bash
flutter --version
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Jalankan aplikasi
```bash
flutter run
```

