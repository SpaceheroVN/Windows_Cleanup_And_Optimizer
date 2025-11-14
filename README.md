# 🚀 Windows Cleanup & Optimizer v5.1.5 - Pro Toolkit (WCaO) [![Download](https://img.shields.io/badge/Download-brightgreen?style=flat&logo=download&logoColor=white)](https://github.com/SpaceheroVN/Windows_Cleanup_And_Optimizer/releases/latest)


![Version](https://img.shields.io/badge/version-v5.1.5-blue?style=plastic) ![Platform](https://img.shields.io/badge/platform-Windows-0078D6?style=plastic&logo=windows&logoColor=white) ![Language](https://img.shields.io/badge/language-Batch-4D4D4D?style=plastic&logo=windows-terminal&logoColor=white) ![License](https://img.shields.io/badge/license-Open%20Source-brightgreen?style=plastic&logo=opensource&logoColor=white) ![Admin](https://img.shields.io/badge/requires-Admin-red?style=plastic&logo=powershell&logoColor=white) ![Status](https://img.shields.io/badge/status-Paused-inactive?style=plastic&logo=player-pause&logoColor=white)

> **Công cụ bảo trì toàn diện** dưới dạng Batch Script, cung cấp các tùy chọn **Tự động** và **Chuyên sâu (Expert)** để dọn dẹp, sửa lỗi và tối ưu hóa hiệu suất hệ thống Windows. Nó thuộc loại **mã nguồn mở** nên có thể **tùy chỉnh** theo *sở thích*❤️! Nếu bạn thấy tôi cập nhật **README.md** đúng phiên bản (v5.1.5) thì việc đó đồng nghĩa dự án ***đã tạm dừng vô thời hạn**...

---

## 🌟 Tổng quan & Mục đích

**Windows Cleanup & Optimizer (WCaO)** tận dụng các công cụ Command Line gốc (`DISM`, `SFC`, `cleanmgr`, `powercfg`, v.v.) của Windows để thực hiện các tác vụ bảo trì phức tạp. Mục đích chính là giúp người dùng:

1.  **Giải phóng dung lượng** ổ đĩa bị lãng phí do tệp rác.
2.  **Sửa chữa** các lỗi và tệp hệ thống cốt lõi.
3.  **Tối ưu hóa** hiệu suất khởi động, đồ họa và mạng.
4.  **Tự động hóa** quy trình bảo trì hàng tháng.

---

## ✨ Chi Tiết Chức Năng (Features Breakdown)

WCaO được chia thành 5 nhóm chức năng chính, mỗi nhóm phục vụ một mục tiêu bảo trì cụ thể:

### 1. 🧹 Quick Cleanup (Menu [1])

Tác vụ dọn dẹp hàng ngày, an toàn và nhanh chóng.

* **Xóa tệp tạm thời:** Dọn dẹp thư mục `%temp%` (User) và `%SystemRoot%\Temp` (System).
* **Xóa Prefetch:** Xóa các tệp Prefetch để làm mới dữ liệu khởi động ứng dụng.
* **Dọn dẹp Thùng rác (Recycle Bin):** Xóa toàn bộ nội dung của thùng rác.
* **Xóa Lịch sử truy cập gần đây:** Dọn dẹp các shortcut trong thư mục Recent.

### 2. 🌊 Deep Cleanup (Menu [2])

Tác vụ sửa chữa hệ thống và dọn dẹp chuyên sâu. **Thích hợp khi máy có dấu hiệu chậm, lag hoặc lỗi đột ngột**.

* **DISM /RestoreHealth:** Kiểm tra và sửa chữa kho chứa ảnh hệ thống Windows.
* **SFC /scannow:** Quét và sửa chữa các tệp hệ thống Windows bị hỏng hoặc thiếu.
* **cleanmgr /autoclean:** Chạy công cụ Disk Cleanup gốc để dọn dẹp các mục hệ thống thiết yếu.

*(Lưu ý: Chức năng dọn dẹp cache trình duyệt tự động đã bị loại bỏ (được comment lại) khỏi menu này trong v5.1.5).*

### 3. ⚙️ System Optimization (Menu [3])

Các tùy chỉnh để tăng tốc độ phản hồi và hiệu suất.

| Chức Năng (Menu con) | Mục đích sử dụng |
| :--- | :--- |
| **[1] Check Disk Integrity** | Kiểm tra ổ đĩa hệ thống (`chkdsk /scan`) tìm lỗi mà không sửa chữa. |
| **[2] Defrag / Trim Drive** | Chống phân mảnh (HDD) hoặc tối ưu hóa (Trim cho SSD). **Nên chạy định kỳ**. |
| **[3] Rebuild System Caches** | Sửa lỗi hiển thị biểu tượng/ảnh thumbnail bị mất hoặc lỗi thời. |
| **[4] Optimize Power Plan** | Quản lý các gói năng lượng: Thêm (Ultimate/High), Xóa, Kích hoạt (Set), hoặc Khôi phục mặc định. |
| **[5] Optimize Visual Effects** | Tắt/Tùy chỉnh các hiệu ứng đồ họa để cải thiện hiệu suất. |

### 4. 🔬 Advanced Tools (Menu [4])

Các tác vụ quản trị mạnh mẽ, một số yêu cầu **Expert Mode** (Menu [6]).

| Chức Năng (Menu con) | Yêu cầu Expert Mode? | Trường hợp sử dụng |
| :--- | :--- | :--- |
| **[1] Clear Windows Update Cache** | Không | Khắc phục lỗi Windows Update không thể tải/cài đặt bản vá. |
| **[2] Uninstall Office Key**| Không | Gỡ bỏ key bản quyền Office (hỗ trợ Office 16) khi bị kẹt. |
| **[3] Remove Windows.old folder** | Có | **Giải phóng dung lượng lớn** sau khi nâng cấp Windows. (CẢNH BÁO: Không thể quay lại phiên bản cũ). |
| **[4] Manage Pagefile / Hibernation** | Có | Tắt file ngủ đông (`hiberfil.sys`) hoặc quản lý pagefile. |
| **[5] Network Reset & Flush DNS** | Không | Khắc phục lỗi mạng, DNS, hoặc không thể truy cập internet. |
| **[6] Create System Restore Point** | Không | **Tạo điểm an toàn** trước khi chạy bất kỳ công cụ tối ưu hóa nào khác. |

### 5. 🏃 Auto Run Full Maintenance (Menu [5])

Tự động thực hiện toàn bộ quy trình bảo trì quan trọng (Quick $\to$ Deep $\to$ Defrag $\to$ Caches $\to$ Update Cache). **Lý tưởng để chạy hàng tháng**.

---

## 🛠 Hướng Dẫn Sử Dụng Chi Tiết

### 1. Yêu Cầu

* **Hệ điều hành:** Windows 7/8/10/11.
* **Quyền:** BẮT BUỘC phải chạy với quyền **Administrator** (Quản trị viên).

### 2. Bắt Đầu

1.  **Download** file `.bat` về máy tính.
2.  **Right-click** (Chuột phải) vào file script.
3.  Chọn **Run as administrator** (Chạy với quyền quản trị viên).

### 3. Điều Hướng & Chế Độ Expert

* **Lựa chọn:** Nhập số tương ứng (1-8) với chức năng bạn muốn và nhấn **Enter**. 
* **Expert Mode:** Để sử dụng các chức năng nguy hiểm hơn (như xóa Windows.old), bạn phải chọn **[6] Toggle Expert Mode** để chuyển trạng thái sang **On** trước khi vào menu **Advanced Tools [4]**.

### 4. Xuất Báo Cáo (Menu [7])

* Sử dụng tùy chọn này để lưu lại nhật ký chi tiết của phiên làm việc hiện tại dưới dạng tệp **Log\_YYYYMMDDHHmm.txt** trong thư mục `%LocalAppData%\WCaO_Toolkit` để dễ dàng kiểm tra lịch sử hành động và gỡ lỗi.

---

## 📖 Các Trường Hợp Nên Sử Dụng

| Tình huống | Hành động khuyến nghị |
| :--- | :--- |
| **Máy tính chậm, đầy ổ C** | Chạy **[1] Quick Cleanup** và **Deep Cleanup** (chạy `cleanmgr /autoclean`). |
| **Sau khi cài đặt phần mềm/driver mới** | Chạy **[6] Create System Restore Point** (trong Menu [4]). |
| **Máy bị lỗi hiển thị biểu tượng/hình ảnh** | Chạy **[3] Rebuild System Caches** (trong Menu [3]). |
| **Mất kết nối mạng đột ngột hoặc lỗi DNS** | Chạy **[5] Network Reset & Flush DNS** (trong Menu [4]). |
| **Cần bảo trì định kỳ hàng tháng** | Chạy **[5] Auto Run Full Maintenance**. |
| **Sau khi nâng cấp Windows lớn** | Bật **Expert Mode** rồi chạy **[3] Remove Windows.old folder** (trong Menu [4]). |
