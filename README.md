Berikut adalah isi lengkap file `README.md` dalam format siap pakai:

---

````markdown
# 🚀 GoServ - Flutter & Laravel Integration

Project ini adalah aplikasi berbasis **Flutter** sebagai frontend dan **Laravel** sebagai backend API. Cocok untuk belajar atau dijadikan starter project.

---

## 📥 Cara Clone Project

Clone repository menggunakan perintah berikut:

```bash
git clone https://github.com/danieltampubolon29/goserv-flutter-laravel.git [nama-folder]
````

---

## 📦 Setup Backend (Laravel)

1. **Pindahkan folder `goserv-api`** ke dalam direktori web server kamu.
   Contoh jika menggunakan **Laragon**:

   * Masuk ke folder:

     ```
     C:\laragon\www
     ```
   * Tempelkan folder `goserv-api` di sana.

2. **Masuk ke folder `goserv-api`** melalui terminal:

   ```bash
   cd goserv-api
   ```

3. **Install dependency Laravel:**

   ```bash
   composer install
   ```

4. **Salin file konfigurasi environment:**

   ```bash
   copy .env.example .env
   ```

5. **Atur konfigurasi database** di file `.env` (baris 23-28):

   ```env
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=db_goserv
   DB_USERNAME=root
   DB_PASSWORD=
   ```

   > Jika menggunakan database lain, sesuaikan konfigurasi tersebut.

6. **Generate application key:**

   ```bash
   php artisan key:generate
   ```

7. **Clear konfigurasi cache (opsional):**

   ```bash
   php artisan config:clear
   ```

8. **Jalankan migrasi database:**
   (Pastikan database `db_goserv` sudah dibuat di MySQL.)

   ```bash
   php artisan migrate
   ```

9. **Jalankan server Laravel:**

   ```bash
   php artisan serve
   ```

> **Biarkan server backend Laravel berjalan** selama penggunaan aplikasi.

---

## 💻 Setup Frontend (Flutter)

1. **Masuk ke folder project Flutter:**

   ```bash
   cd goserv-flutter
   ```

2. **Install dependency Flutter:**

   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi menggunakan Chrome:**

   ```bash
   flutter run -d chrome
   ```

> **Catatan:**
> Aplikasi ini dikembangkan menggunakan **Chrome** sebagai target utama (web-based output).
> Namun, kamu juga bisa menjalankan di platform lain sesuai kebutuhan.

---

## 📸 Preview

*Screenshots coming soon...*

---

## ✨ Kontributor

* Daniel Tampubolon
* dan Tim GoServ

---
