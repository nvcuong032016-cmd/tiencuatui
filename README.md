# Tiền của tui

**Slogan:** Tiền tui, tui quản.

Flutter MVP 0.1 cho ứng dụng quản lý tài chính cá nhân.

## Chức năng MVP

- Dashboard dark/premium.
- Quản lý thẻ tín dụng, tự sắp xếp theo số ngày miễn lãi tăng dần.
- Quản lý khoản vay, checklist từng kỳ trả góp, tự tính đã trả/còn lại.
- Quản lý cho vay và tiết kiệm.
- Dữ liệu lưu local bằng SQLite.
- Hiển thị tiền theo định dạng Việt Nam.
- GitHub Actions tự kiểm tra code và build APK release.

## Build Android

Workflow `.github/workflows/build-apk.yml` chạy khi push vào `main`, tự cài Flutter/Java, chạy `flutter analyze`, build APK và upload artifact `tien-cua-tui-apk`.

## Chưa có trong MVP 0.1

- Thuật toán lịch âm Việt Nam chính xác.
- Notification nhắc sao kê/thanh toán.
- Backup/sync cloud.
- PIN/sinh trắc học.
