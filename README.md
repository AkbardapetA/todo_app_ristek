# todo_app_ristek

Through this repository, i'm documenting my first steps in learning mobdev flutter from zero with help from various online instances.

This project is a Flutter-based To-Do application developed as part of the RISTEK Fasilkom UI 2026 Mobile Development Open Recruitment assignment.
The application will allow users to manage daily tasks using fundamental mobile development practices.

## Lesson Learned
Selama membangun aplikasi to-do ini, saya belajar bahwa Flutter bukan hanya soal menulis widget, tapi juga soal cara berpikir terstruktur. Di awal, saya menaruh semua kode dalam satu file agar cepat jadi. Itu membantu untuk memahami alur dasar (state, `setState`, navigasi, dan komponen UI), tapi ketika fitur bertambah, file menjadi sulit dibaca dan rawan error. Dari situ saya belajar pentingnya memecah proyek berdasarkan tanggung jawab: `models` untuk data, `features` untuk layar utama, `widgets` untuk komponen reusable, dan `shared/sheets` untuk bottom sheet yang dipakai ulang.

Saya juga belajar praktik debugging yang lebih rapi melalui `flutter analyze` dan `dart format`. Banyak warning kecil (misalnya async context, gaya penulisan `if`, atau API yang deprecated) ternyata berpengaruh pada kualitas kode jangka panjang. Selain itu, saya memahami pentingnya validasi input dan empty state agar aplikasi terasa lebih aman dan nyaman dipakai, bukan hanya “berjalan”.

Menggunakan AI membantu saya mempercepat proses belajar: dari memecah task menjadi part-part kecil, merapikan struktur folder, sampai mengecek kualitas implementasi. Namun, saya tetap harus memahami alasan di balik setiap perubahan, bukan sekadar copy-paste.

Referensi yang saya gunakan:
- Dokumentasi resmi Flutter: https://docs.flutter.dev/
- Dokumentasi widget Flutter API: https://api.flutter.dev/
- Cookbook Flutter (contoh implementasi): https://docs.flutter.dev/cookbook
- Bantuan AI assistant (iterasi desain, refactor, dan review kode) selama pengembangan proyek ini.
