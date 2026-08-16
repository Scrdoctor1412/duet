# 📜 QUY ƯỚC LẬP TRÌNH (TEAM CONVENTIONS & GUIDELINES) - DUET

> **Dành cho**: Tất cả Lập trình viên trong dự án.  
> **Mục tiêu**: Đảm bảo toàn bộ mã nguồn tuân thủ 1 phong cách chuẩn hóa, chống rò rỉ bộ nhớ (Memory Leak), triệt tiêu lỗi trùng Key và tối ưu 100% hiệu năng UI.

---

## 📋 4 QUY ƯỚC CỐT LÕI (CORE RULES)

### 📌 Quy ước 1: Mỗi Màn hình (Screen/Page) = 1 `DuetView` (hoặc `buildScope`)

Ở gốc của mọi Màn hình (Top-level Screen), bạn **bắt buộc** áp dụng 1 trong 2 cách viết sau:

- **Cách A (Khuyên dùng cho StatelessWidget/Screen thuần)**: Kế thừa `DuetView<MyViewModel>`.
- **Cách B (Khuyên dùng cho StatefulWidget có Controller cục bộ)**: Sử dụng mixin `with DuetStateMixin<MyScreen, MyViewModel>` và bọc cây UI bằng `buildScope(...)`.

#### ❌ Không nên:
```dart
// Không tạo hoặc tra cứu Duet cục bộ thủ công trong build().
class ProfileScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    final vm = ProfileViewModel();
    ...
  }
}
```

#### ✅ Chuẩn quy ước:
```dart
// Kế thừa DuetView - Tự động tạo Key độc bản 100%, tự động bơm Scope!
class ProfileScreen extends DuetView<ProfileViewModel> {
  const ProfileScreen({super.key});

  @override
  ProfileViewModel bindDuet() => ProfileViewModel();

  @override
  Widget build(BuildContext context, ProfileViewModel duet) {
    return Scaffold(...);
  }
}
```

---

### 📌 Quy ước 2: Các Widget con KHÔNG ĐƯỢC điền tham số `viewModel:`

Khi Màn hình cha đã tuân thủ **Quy ước 1**, tất cả các Widget con bên dưới (`DuetBuilder`, `DuetSelector`, `DuetListener`, `DuetBehaviorListener`) **tự động tìm thấy ViewModel từ Context**.

#### ❌ Không nên (Thừa thãi & rườm rà):
```dart
DuetBuilder<ProfileData, ProfileUiBehavior>(
  viewModel: vm, // 👈 THỪA! Không cần điền!
  builder: (context, data) => Text(data.name),
)
```

#### ✅ Chuẩn quy ước:
```dart
DuetBuilder<ProfileData, ProfileUiBehavior>(
  // 👈 Tự động tìm thấy ProfileViewModel từ Màn hình cha!
  builder: (context, data) => Text(data.name),
)
```

---

### 📌 Quy ước 3: Cập nhật song song cả Data & UI phải dùng `emit(data: ..., ui: ...)`

Khi một Action trong ViewModel làm thay đổi cả dữ liệu (`Data`) lẫn trạng thái giao diện (`UiSuccess`, `UiError`...), bạn **bắt buộc dùng `emit()`** thay vì gọi 2 hàm tách rời.

#### ❌ Không nên (Dễ gây chớp giật UI / Reactive Glitch):
```dart
updateData((current) => current.copyWith(name: newName));
emitUi(const ProfileUiSuccess());
```

#### ✅ Chuẩn quy ước (Gom 1 đợt notify, mượt 100%):
```dart
emit(
  data: data.copyWith(name: newName),
  ui: const ProfileUiSuccess('Cập nhật thành công!'),
);
```

---

### 📌 Quy ước 4: Phân biệt Rạch ròi Màn hình chính vs Widget con nhỏ

- **`DuetView` / `DuetStateMixin`**: **Chỉ được dùng ở Cấp Màn hình chính (Screen Level)**.
- **Widget con nhỏ lẻ nằm bên trong màn hình** (như UserAvatar, ProductItemCard...): **Không được tự tạo ViewModel mới**, mà hãy dùng `DuetBuilder` hoặc `context.vm<MyViewModel>()` để dùng chung ViewModel của màn hình cha.

---

## 📊 BẢNG CHECKLIST DO'S & DON'TS CHO DEV MỚI

| Hành động | Do (Nên làm) | Don't (Tránh làm) |
| :--- | :--- | :--- |
| **Tạo Màn hình mới** | Kế thừa `DuetView<MyVM>` | Tạo Duet cục bộ trong `build()` |
| **Dùng Widget phản ứng** | Viết `DuetBuilder<Data, Behavior>()` | Điền `viewModel: vm` dư thừa vào Widget con |
| **Cập nhật State kép** | Dùng `emit(data: ..., ui: ...)` | Gọi `emitData()` rồi gọi `emitUi()` ở 2 dòng riêng |
| **Sự kiện Toast/SnackBar** | Dùng `DuetBehaviorListener` | Tự `addListener` thủ công trong `initState` |
| **Truy cập VM ở Widget con** | Dùng `context.vm<MyVM>()` | Khởi tạo một ViewModel mới trong widget con |

---

## 💡 Mẹo Nhanh Bắt Lỗi
Nếu bạn vi phạm quy ước (ví dụ: dùng `DuetBuilder` ở một màn hình chưa được bọc `DuetView`/`buildScope` và cũng không điền `viewModel:`), ứng dụng sẽ **dừng lại ngay lập tức và in thông báo lỗi Assertion kèm hướng dẫn sửa lỗi rõ ràng trên Console**.

