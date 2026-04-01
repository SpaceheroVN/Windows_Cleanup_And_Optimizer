# 🚀 Windows Cleanup & Optimizer v5.2.4 - Pro Toolkit (WCaO) <a href="https://github.com/SpaceheroVN/Windows_Cleanup_And_Optimizer/releases/download/5.2.4/WCaO.bat"><img src="https://img.shields.io/badge/Download-brightgreen?style=flat&logo=download&logoColor=white" alt="Latest Release" width="85"></a>

![Version](https://img.shields.io/badge/version-v5.2.4-blue?style=plastic) ![Platform](https://img.shields.io/badge/platform-Windows-0078D6?style=plastic&logo=windows&logoColor=white) ![Language](https://img.shields.io/badge/language-Batch-4D4D4D?style=plastic&logo=windows-terminal&logoColor=white) ![License](https://img.shields.io/badge/license-Open%20Source-brightgreen?style=plastic&logo=opensource&logoColor=white) ![Admin](https://img.shields.io/badge/requires-Admin-Optional-yellow?style=plastic&logo=powershell&logoColor=white) ![Status](https://img.shields.io/badge/status-Active-success?style=plastic&logo=rocket&logoColor=white)

> **Công cụ bảo trì toàn diện** dưới dạng Batch Script, cung cấp các tùy chọn **Tự động** và **Chuyên sâu (Expert)** để dọn dẹp, sửa lỗi và tối ưu hóa hệ thống. Ở phiên bản **v5.2.4** này, dự án đã chính thức được hồi sinh với một "lớp giáp chống đạn" hoàn toàn mới: không còn văng đột ngột, hỗ trợ kéo thả thư mục siêu mượt, chạy được cả khi không có quyền Admin, và giao diện màu ANSI cực kỳ đã mắt! ❤️

---

## 🔥 Có gì mới trong bản v5.2.4? (What's New)

* 🛡️ **Giáp "Anti-Crash" Tuyệt Đối:** Khắc phục triệt để các "đặc sản" của Batch. Bạn có thể thoải mái kéo thả thư mục chứa dấu ngoặc kép `""`, ký tự đặc biệt (`&`, `<`, `>`, `!`), tool vẫn xử lý trơn tru mà không bao giờ bị văng (crash) ngang.
* 🔓 **Cơ Chế Non-Admin Thông Minh:** Không còn ép buộc phải chạy quyền Quản trị ngay từ đầu! Nếu bạn mở bình thường, tool vẫn cho phép sử dụng các tính năng cơ bản (Quick Clean, Rename, Visual Effects). Các tính năng can thiệp sâu sẽ được báo khóa an toàn.
* 🏷️ **Siêu Công Cụ Quick Rename:** Bổ sung tính năng đổi tên File/Folder hàng loạt bằng Regex siêu tốc. Xử lý gọn gàng cả những file đang bị khóa (Locked) và hiển thị log real-time ngay trên màn hình.
* 🎨 **Giao Diện Chuẩn Hóa:** Tối ưu hóa hiệu suất hiển thị với Bảng màu (Color Palette) mới, phân chia cấp độ cảnh báo (Xanh lá - An toàn, Đỏ - Nguy hiểm, Vàng - Cảnh báo) giúp trải nghiệm thị giác chuyên nghiệp hơn.

---

## ✨ Chi Tiết Chức Năng (Features Breakdown)

WCaO được cấu trúc thành 5 nhóm chức năng chính, mỗi nhóm phục vụ một mục tiêu cụ thể:

### 1. 🧹 Quick Cleanup (Menu [1])
Tác vụ dọn dẹp hàng ngày, **hoàn toàn an toàn** (không yêu cầu Admin).
* Dọn dẹp thư mục tạm thời `%temp%` (User) và `%SystemRoot%\Temp` (System).
* Dọn dẹp Prefetch để làm mới dữ liệu khởi động.
* Dọn dẹp Thùng rác (Recycle Bin) triệt để bằng PowerShell.
* Xóa Lịch sử truy cập gần đây (Recent shortcuts).

### 2. 🌊 Deep Cleanup (Menu [2])
Tác vụ sửa chữa hệ thống và dọn dẹp chuyên sâu. **(Yêu cầu Admin)**.
* **DISM /RestoreHealth:** Kiểm tra và sửa chữa kho chứa ảnh hệ thống Windows.
* **SFC /scannow:** Quét và phục hồi các tệp hệ thống Windows bị hỏng hoặc thiếu.
* **cleanmgr /autoclean:** Chạy Disk Cleanup gốc để quét sâu các mục hệ thống thiết yếu.

### 3. ⚙️ System Optimization (Menu [3])
Tùy chỉnh để tăng tốc độ phản hồi và hiệu suất phần cứng.

| Chức Năng | Mục đích sử dụng | Yêu cầu Admin? |
| :--- | :--- | :--- |
| **Check Disk Integrity** | Quét (`chkdsk /scan`) tìm lỗi phân vùng ổ cứng. | Có |
| **Defrag / Trim Drive** | Chống phân mảnh (HDD) hoặc tối ưu hóa (Trim) SSD. | Có |
| **Rebuild System Caches** | Sửa lỗi mất icon, hỏng thumbnail hoặc lỗi tìm kiếm WSearch. | Không |
| **Optimize Power Plan** | Thêm gói (Ultimate/High), kích hoạt hoặc quản lý nguồn điện. | Có |
| **Optimize Visual Effects** | Tắt/Tùy chỉnh hiệu ứng đồ họa Windows để giảm giật lag. | Không |

### 4. 🔬 Advanced Tools (Menu [4])
Trạm điều khiển các công cụ quản trị mạnh mẽ. Các tính năng rủi ro cao sẽ được ẩn sau **Expert Mode** (Menu [6]).

| Chức Năng | Chế độ Expert? | Trường hợp sử dụng |
| :--- | :--- | :--- |
| **Clear Windows Update Cache** | Không | Xóa cache khi Windows Update bị kẹt, không tải được bản vá. |
| **Uninstall Office Key**| Không | Gỡ bỏ key bản quyền Office 2016 bị lỗi/kẹt. |
| **Remove Windows.old** | **Có** | Giải phóng hàng chục GB dung lượng sau khi cài/nâng cấp Win. |
| **Manage Pagefile/Hibernation** | **Có** | Tắt file ngủ đông (`hiberfil.sys`) để tiết kiệm ổ C. |
| **Network Reset & Flush DNS** | Không | Khắc phục rớt mạng, lỗi DNS không lướt được web. |
| **Create Restore Point** | Không | Tạo điểm sao lưu an toàn trước khi "vọc vạch" hệ thống. |
| **Quick Rename Files/Folders** | Không | Đổi tên hàng loạt, xóa số tự động, định dạng lại file trong chớp mắt. |

### 5. 🏃 Auto Run Full Maintenance (Menu [5])
Tự động hóa toàn bộ quy trình: *Quick Clean* $\to$ *Deep Clean* $\to$ *Defrag* $\to$ *Caches* $\to$ *Update Cache*. Giải pháp "1-click" hoàn hảo để bảo trì máy tính mỗi tháng một lần.

---

## 🛠 Hướng Dẫn Sử Dụng Chi Tiết

### 1. Bắt Đầu
1. **Download** file `WCaO.bat` về máy tính.
2. Click đúp để mở (Chế độ Cơ bản) **HOẶC** Chuột phải $\to$ chọn **Run as administrator** (Chế độ Đầy đủ - Khuyên dùng).

### 2. Thao Tác Cơ Bản & Expert Mode
* **Điều hướng:** Gõ số tương ứng (1-8) và nhấn `Enter`. Giao diện hỗ trợ kéo thả thư mục (Drag & Drop) siêu tiện lợi ở tính năng Rename.
* **Expert Mode:** Để sử dụng các tính năng nguy hiểm (xóa Windows.old, chỉnh Pagefile), bạn phải về Menu Chính, gõ `6` để bật trạng thái **Expert Mode: On**.

### 3. Trích Xuất Báo Cáo (Menu [7])
Mọi thao tác thành công/thất bại của tool đều được ghi ngầm trong bộ nhớ. Bạn có thể xuất ra file **Log\_YYYYMMDDHHmm.txt** tại `%LocalAppData%\WCaO_Toolkit` để dễ dàng tra cứu xem máy tính đã được dọn dẹp những gì.

---

## 📖 Các Trường Hợp Nên Sử Dụng

| Tình huống | Hành động khuyến nghị |
| :--- | :--- |
| **Máy tính rác đầy ổ C, chạy ì ạch** | Mở quyền Admin $\to$ Chạy **[5] Auto Run Full Maintenance**. |
| **Tên file tải về có quá nhiều ký tự thừa** | Vào Advanced Tools $\to$ Chạy **[7] Quick Rename Files/Folders**. |
| **Mất kết nối mạng đột ngột hoặc lỗi DNS** | Vào Advanced Tools $\to$ Chạy **[5] Network Reset & Flush DNS**. |
| **Màn hình đen, mất icon thư mục** | Vào System Optimization $\to$ Chạy **[3] Rebuild System Caches**. |
| **Vừa cài xong Windows Update bản lớn** | Bật **Expert Mode** $\to$ Chạy **[3] Remove Windows.old folder**. |
