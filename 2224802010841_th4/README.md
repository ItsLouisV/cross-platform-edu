# VanLinh News 📰

Ứng dụng đọc báo sử dụng VnExpress RSS — bài tập Flutter Lab.

**Sinh viên:** Nguyễn Văn Linh  
**MSSV:** 2224802010841

---

## Cấu trúc thư mục

```
lib/
├── main.dart                    # Entry point, khởi tạo providers
├── models/
│   ├── article.dart             # Model bài báo, parse từ RSS XML
│   └── category.dart            # Model danh mục + danh sách 12 chủ đề
├── services/
│   └── rss_service.dart         # Fetch & parse XML từ VnExpress RSS
├── providers/
│   ├── news_provider.dart       # State: danh sách tin, loading, error
│   └── theme_provider.dart      # State: light/dark mode + SharedPreferences
├── screens/
│   ├── home_page.dart           # Tab 1 - Tin tổng hợp (tất cả RSS)
│   ├── detail_page.dart         # Màn hình chi tiết bài báo
│   ├── category_page.dart       # Tab 2 - Grid chủ đề + list theo chủ đề
│   ├── latest_page.dart         # Tab 3 - 10 tin mới nhất
│   └── settings_page.dart       # Tab 4 - Cài đặt, thông tin SV
├── widgets/
│   ├── main_wrapper.dart        # BottomNavigationBar container
│   ├── news_card.dart           # Card tin tức (ảnh + tiêu đề + ngày)
│   ├── news_shimmer.dart        # Loading skeleton placeholder
│   └── error_retry.dart         # Widget lỗi + nút thử lại
└── utils/
    ├── app_theme.dart           # ThemeData light & dark
    └── date_formatter.dart      # Format ngày "2 giờ trước", "hôm qua"...
```

---

## Cài đặt & chạy

### 1. Cài dependencies
```bash
flutter pub get
```

### 2. Chạy ứng dụng
```bash 
flutter run
```

### 3. Build APK
```bash
flutter build apk --release
```

---

## Các màn hình

| Màn hình | Tab | Mô tả |
|---|---|---|
| HomePage | 1 | Feed tổng hợp từ VnExpress RSS, pull-to-refresh |
| DetailPage | — | Chi tiết bài, hero image, nút mở VnExpress |
| CategoryPage | 2 | Grid 12 chủ đề → tap → load RSS chủ đề đó |
| LatestPage | 3 | 10 tin mới nhất, badge MỚI cho tin < 1 giờ |
| SettingsPage | 4 | Toggle dark/light, thông tin sinh viên |

---

## Packages sử dụng

| Package | Mục đích |
|---|---|
| `provider` | State management (NewsProvider, ThemeProvider) |
| `http` | Gọi HTTP GET lấy RSS feed |
| `xml` | Parse XML của RSS |
| `cached_network_image` | Cache & hiển thị ảnh thumbnail |
| `shimmer` | Loading skeleton animation |
| `shared_preferences` | Lưu cài đặt theme |
| `share_plus` | Chia sẻ bài viết |
| `url_launcher` | Mở link trên trình duyệt |
| `intl` | Format ngày tháng tiếng Việt |

---

## RSS Endpoints VnExpress

```
Tất cả:    https://vnexpress.net/rss/tin-moi-nhat.rss
Thế giới:  https://vnexpress.net/rss/the-gioi.rss
Thời sự:   https://vnexpress.net/rss/thoi-su.rss
Kinh doanh: https://vnexpress.net/rss/kinh-doanh.rss
Khoa học:  https://vnexpress.net/rss/khoa-hoc.rss
Giải trí:  https://vnexpress.net/rss/giai-tri.rss
Thể thao:  https://vnexpress.net/rss/the-thao.rss
Pháp luật: https://vnexpress.net/rss/phap-luat.rss
Giáo dục:  https://vnexpress.net/rss/giao-duc.rss
Sức khoẻ:  https://vnexpress.net/rss/suc-khoe.rss
Xe:        https://vnexpress.net/rss/oto-xe-may.rss
Du lịch:   https://vnexpress.net/rss/du-lich.rss
Số hoá:    https://vnexpress.net/rss/so-hoa.rss
```

---

## Lưu ý

- **Android:** Cần thêm `android:usesCleartextTraffic="true"` trong AndroidManifest.xml (đã có sẵn).
- **iOS:** Cần thêm `NSAppTransportSecurity` trong Info.plist nếu dùng HTTP.
- **Flutter Web:** VnExpress RSS bị CORS khi gọi trực tiếp từ browser — cần backend proxy.
- Đổi thông tin sinh viên trong `settings_page.dart` tại phần `// THÔNG TIN SINH VIÊN`.
