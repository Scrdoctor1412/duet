# 📖 Overview & Architecture Principles

## 1. Triết lý thiết kế (Philosophy)

Hầu hết các thư viện quản lý state hiện nay đều rơi vào một trong hai cực:
- **Quá rườm rà (Verbose):** Như BLoC, bắt buộc phải viết hàng loạt class `Event`, `State`, `BlocProvider`, làm số lượng file phình to gấp 3 lần.
- **Quá "Magic" & Đóng kín:** Như GetX, tự thay thế cả hệ thống Routing, SnackBar, làm can thiệp thô bạo vào Flutter Native và dễ gây break code khi nâng cấp Flutter SDK.

**`duet`** được ra đời với triết lý:
> **"100% Thuần Flutter Native — Tự do linh hoạt — Không lãng phí RAM — An toàn tuyệt đối."**

---

## 2. 5 Trụ cột cốt lõi của `duet`

```text
┌────────────────────────────────────────────────────────────────────────┐
│                          DUET ARCHITECTURE                             │
├────────────────────────────────────────────────────────────────────────┤
│ 1. DUAL-NOTIFIER STATE    : Tách biệt DataState & UIBehaviorState      │
│ 2. OWNERSHIP RÕ RÀNG     : State cục bộ hoặc dùng chung có chủ đích     │
│ 3. FLEXIBLE SCOPING      : DuetView, DuetScope hoặc Duets.shared       │
│ 4. REFERENCE COUNTING    : Tự động giải phóng RAM (autoDispose)        │
│ 5. DART 3 SEALED CLASS   : An toàn Compile-time với Pattern Matching   │
└────────────────────────────────────────────────────────────────────────┘
```

### 🔹 Trụ cột 1: Dual-Notifier State (Phân tách Data & Behavior)
`Duet<D, B>` (hay `ViewModel`, `DuetViewModel`, `DuetController`) quản lý 2 `ValueNotifier` riêng biệt:
- `dataNotifier`: Quản lý dữ liệu nghiệp vụ `D` (Ví dụ: Danh sách sản phẩm, Thông tin User).
- `behaviorNotifier`: Quản lý trạng thái UI `B` (Ví dụ: `UiIdle`, `UiLoading`, `UiError`).
*Lợi ích:* Tránh mất dữ liệu cũ trên giao diện khi người dùng thao tác Reload (No UI Flickering).

### 🔹 Trụ cột 2: Ownership rõ ràng
- **State cục bộ:** Tạo trong `DuetView.bindDuet` hoặc cung cấp bằng `DuetScope`.
- **State dùng chung:** Chỉ dùng `Duets.shared` cho state thực sự thuộc nhiều màn hình hoặc một flow.

### 🔹 Trụ cột 3: Flexible Scoping
`key:` cho phép tạo nhiều shared instance có chủ đích cùng kiểu:
```dart
final first = Duets.shared<AccountDuet>(() => AccountDuet('a'), key: 'a');
final second = Duets.shared<AccountDuet>(() => AccountDuet('b'), key: 'b');
```

Các API legacy `getDuet`/`getVM` đã deprecated và sẽ bị xóa ở phiên bản 2.0.0.

### 🔹 Trụ cột 4: Reference Counting AutoDispose
Tự động đếm số lượng `DuetBuilder` hoặc `DuetSelector` đang theo dõi ViewModel (`_refCount`). Khi người dùng thoát màn hình (`_refCount == 0`), ViewModel sẽ tự động giải phóng khỏi RAM mà không cần dọn dẹp thủ công.

### 🔹 Trụ cột 5: Sealed Class & Dart 3 Pattern Matching
Tích hợp với từ khóa `sealed` và `factory` của Dart 3. Ép buộc trình biên dịch phải kiểm tra đầy đủ mọi nhánh UI (`switch (behavior)`), mang lại trải nghiệm gõ code gợi ý (IntelliSense) siêu tốc.

---

## 3. Bảng so sánh tính năng tổng quan

| Tính năng | `duet` | GetX | Riverpod | BLoC |
| :--- | :--- | :--- | :--- | :--- |
| **Bản chất hạ tầng** | 100% Native (`ValueNotifier`) | Khung sinh thái đóng | Dependency Graph | Stream State Machine |
| **State dùng chung rõ ràng** | ✅ Có (`Duets.shared`) | ✅ Có (`Get.find()`) | ✅ Provider container | ✅ Repository/provider |
| **Loại bỏ Event Boilerplate** | ✅ Có (Gọi hàm async trực tiếp) | ✅ Có | ✅ Có | ❌ Phải tạo Event Class |
| **Tự động AutoDispose** | ✅ Có (Reference Counting) | 🟡 Bán tự động | ✅ Có (`.autoDispose`) | ✅ Tự động theo cây |
| **Chống giật UI khi Reload** | ✅ Tự nhiên nhất | ❌ Khó xử lý | ✅ Có (`previousData`) | ❌ Dễ trắng màn hình |
| **Lắng nghe từng Field (Selector)** | ✅ Có (`DuetSelector`) | ✅ Có (`Obx`) | ✅ Có (`select`) | ✅ Có (`BlocSelector`) |
| **Scoping** | Local scope hoặc keyed shared registry | Tag String | Provider scope | Tree/provider scope |

