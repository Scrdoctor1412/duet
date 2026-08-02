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
│ 2. HYBRID SCOPING        : Không Context (getVM) hoặc Cây Widget (DuetScope)│
│ 3. PARAMETRIC KEY        : Phân biệt Instance bằng ID/Object (key: id) │
│ 4. REFERENCE COUNTING    : Tự động giải phóng RAM (autoDispose)        │
│ 5. DART 3 SEALED CLASS   : An toàn Compile-time với Pattern Matching   │
└────────────────────────────────────────────────────────────────────────┘
```

### 🔹 Trụ cột 1: Dual-Notifier State (Phân tách Data & Behavior)
`Duet<D, B>` (hay `ViewModel`, `DuetViewModel`, `DuetController`) quản lý 2 `ValueNotifier` riêng biệt:
- `dataNotifier`: Quản lý dữ liệu nghiệp vụ `D` (Ví dụ: Danh sách sản phẩm, Thông tin User).
- `behaviorNotifier`: Quản lý trạng thái UI `B` (Ví dụ: `UiIdle`, `UiLoading`, `UiError`).
*Lợi ích:* Tránh mất dữ liệu cũ trên giao diện khi người dùng thao tác Reload (No UI Flickering).

### 🔹 Trụ cột 2: Hybrid Scoping (Tự do lựa chọn có/không Context)
- **Không cần `BuildContext`:** Dùng `getDuet(() => MyViewModel())` để lấy ViewModel/Duet ở bất kỳ đâu (Service, Repository, UI).
- **Phân vùng bằng `BuildContext`:** Dùng `DuetScope` và `context.duetOf<MyViewModel>()` khi muốn phân vùng theo Cây Widget.

### 🔹 Trụ cột 3: Parametric Scoping (`key: Object?`)
Cho phép tạo nhiều Instance độc lập của cùng một kiểu ViewModel trên cùng một màn hình mà **không cần gõ chuỗi Magic String**:
```dart
final vmA = getDuet(() => ProductItemViewModel(productA), key: productA.id);
final vmB = getDuet(() => ProductItemViewModel(productB), key: productB.id);
```

### 🔹 Trụ cột 4: Reference Counting AutoDispose
Tự động đếm số lượng `DuetBuilder` hoặc `DuetSelector` đang theo dõi ViewModel (`_refCount`). Khi người dùng thoát màn hình (`_refCount == 0`), ViewModel sẽ tự động giải phóng khỏi RAM mà không cần dọn dẹp thủ công.

### 🔹 Trụ cột 5: Sealed Class & Dart 3 Pattern Matching
Tích hợp với từ khóa `sealed` và `factory` của Dart 3. Ép buộc trình biên dịch phải kiểm tra đầy đủ mọi nhánh UI (`switch (behavior)`), mang lại trải nghiệm gõ code gợi ý (IntelliSense) siêu tốc.

---

## 3. Bảng so sánh tính năng tổng quan

| Tính năng | `duet` | GetX | Riverpod | BLoC |
| :--- | :--- | :--- | :--- | :--- |
| **Bản chất hạ tầng** | 100% Native (`ValueNotifier`) | Khung sinh thái đóng | Dependency Graph | Stream State Machine |
| **Không cần Context** | ✅ Có (`getVM()`) | ✅ Có (`Get.find()`) | ❌ Cần `WidgetRef` | ❌ Cần `context.read()` |
| **Loại bỏ Event Boilerplate** | ✅ Có (Gọi hàm async trực tiếp) | ✅ Có | ✅ Có | ❌ Phải tạo Event Class |
| **Tự động AutoDispose** | ✅ Có (Reference Counting) | 🟡 Bán tự động | ✅ Có (`.autoDispose`) | ✅ Tự động theo cây |
| **Chống giật UI khi Reload** | ✅ Tự nhiên nhất | ❌ Khó xử lý | ✅ Có (`previousData`) | ❌ Dễ trắng màn hình |
| **Lắng nghe từng Field (Selector)** | ✅ Có (`DuetSelector`) | ✅ Có (`Obx`) | ✅ Có (`select`) | ✅ Có (`BlocSelector`) |
| **Tự do Scoping** | 🏆 Rất cao (Global/Key/Scope) | 🟡 Dùng Tag String | 🟢 Cao | 🔴 Gắn chặt Cây Widget |

