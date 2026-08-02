# 🔬 In-depth Architecture & Performance Comparison

Tài liệu này phân tích chi tiết cơ chế vận hành bên dưới (Internal Working Mechanics) và so sánh hiệu năng giữa `duet` với **GetX**, **Riverpod**, và **BLoC**.

---

## 1. So sánh Cơ chế Hoạt động bên dưới (Internal Mechanics)

```text
┌────────────────────────────────────────────────────────────────────────┐
│                      INTERNAL ENGINE COMPARISON                        │
├───────────────────┬────────────────────────────────────────────────────┤
│ duet              │ ValueNotifier<T> + Reference Counting + Selector    │
│ GetX              │ RxProxy + Direct Element.markNeedsBuild()          │
│ Riverpod          │ Independent Reactive Dependency Graph Node         │
│ BLoC / Cubit      │ Async StreamController + InheritedWidget           │
└───────────────────┴────────────────────────────────────────────────────┘
```

### 🔹 `duet`:
- **Động cơ:** Dùng `ValueNotifier<T>` chuẩn của Flutter.
- **Lookup:** Dùng `Map<Object, Duet>` lưu trong RAM. Key được tính bằng `Object.hash(Type, key)`.
- **Rebuild:** `DuetBuilder` đăng ký callback `_rebuild` (chứa `setState()`) vào `ValueNotifier`. Khi dữ liệu đổi, `ValueNotifier` gọi `notifyListeners()` chạy vòng lặp đồng bộ `O(N)` thực thi `setState()`.
- **Selective Rebuild:** `DuetSelector<VM, T>` lưu vết `_selectedValue` và so sánh khác biệt (`!=`). Thiết kế tối ưu DX rút gọn chỉ còn 2 Generics `<VM, T>`, truy vấn ViewModel qua `InheritedWidget` trong $O(1)$ mà không làm hao phí hiệu năng. Nếu giá trị được chọn không thay đổi, `setState()` sẽ bị hủy bỏ, ngăn ngừa render lãng phí.
- **Lifecycle:** Thuật toán Reference Counting đếm số `DuetBuilder` / `DuetSelector` đang xem. Khi `_refCount == 0`, ViewModel tự gọi `dispose()` và bị xóa khỏi RAM.

### 🔹 GetX:
- **Động cơ:** Can thiệp trực tiếp vào `Element` tree.
- **Lookup:** Dùng bảng băm `Get.put()` toàn cục.
- **Rebuild:** Bỏ qua `setState()`. Khi dùng `Obx`, GetX dùng một proxy `RxProxy` toàn cục để tự động "rình" biến `.obs` được truy cập, sau đó gọi `element.markNeedsBuild()` ép Flutter vẽ lại.
- **Lifecycle:** Bắt buộc dùng `GetMaterialApp` để hook vào Router lifecycle.

### 🔹 Riverpod:
- **Động cơ:** Đồ thị phụ thuộc reactive (Reactive Dependency Graph) hoàn toàn độc lập với cây Widget.
- **Lookup:** Đồ thị lưu trong `ProviderContainer` thuộc `UncontrolledProviderScope`.
- **Rebuild:** Khi dùng `ref.watch(provider.select(...))`, Riverpod tạo một cạnh (edge) liên kết giữa Node dữ liệu và Widget. Khi dữ liệu đổi, Riverpod chạy thuật toán đồ thị đánh dấu đúng Widget bị ảnh hưởng.
- **Lifecycle:** Dùng Garbage Collection trên đồ thị. Node nào không có ai `watch` sẽ tự đánh dấu là "Rác" và tự hủy (`autoDispose`).

### 🔹 BLoC:
- **Động cơ:** Luồng bất đồng bộ Dart `Stream`.
- **Lookup:** Gắn chặt vào cây Widget bằng `BlocProvider` (bản chất là `InheritedWidget`).
- **Rebuild:** `BlocBuilder` tạo `StreamSubscription` lắng nghe Stream. Mỗi State mới phát ra từ Stream sẽ kích hoạt `setState()`.
- **Lifecycle:** Phụ thuộc vào Cây Widget. Khi Node `BlocProvider` bị unmount, hàm `dispose()` tự đóng `Stream`.

---

## 2. Phân tích Hiệu năng (Performance Benchmarks)

| Chỉ số | `duet` | GetX | Riverpod | BLoC |
| :--- | :--- | :--- | :--- | :--- |
| **Tốc độ CPU Dispatch** | ⚡ **Nhanh nhất (O(1))** | ⚡ Rất nhanh | ⚡ Rất nhanh | 🐢 Chậm hơn (Asynchronous Microtask Queue) |
| **Dung lượng RAM** | 🟢 **Thấp nhất** | 🟡 Vừa phải (Tốn RAM Proxy) | 🟡 Vừa phải (Tốn RAM Graph Node) | 🔴 Cao nhất (Tốn RAM Stream & Event Object) |
| **Tần suất Garbage Collection** | 🟢 **Cực ít** | 🟡 Vừa phải | 🟢 Ít | 🔴 Nhiều (Tạo Event object liên tục khi gửi event) |
| **Tối ưu Rebuild khoanh vùng** | 🏆 **Cực mượt (`DuetSelector<VM, T>`)** | 🟢 Rất mượt | 🏆 **Đỉnh nhất** (`.select()`) | 🟡 Vừa phải (`BlocSelector`) |

---

## 3. Đánh giá mức độ phù hợp cho Dự án Ngân hàng & Fintech Enterprise

Khi xây dựng ứng dụng Tài chính / Ngân hàng quy mô lớn (Team 50-100 Lập trình viên), tiêu chí đánh giá không chỉ nằm ở Tốc độ CPU mà còn ở **Quản trị Rủi ro (Governance) và Nhật ký Kiểm toán (Audit Trail)**.

### 🟢 Nơi `duet` thể hiện xuất sắc:
1. **Bảo mật mã nguồn 100%:** Code thuần Flutter Native, 0% package bên ngoài, loại bỏ hoàn toàn nguy cơ tấn công chuỗi cung ứng (Supply Chain Attack).
2. **UX Chuyển tiền không bị giật:** Nhờ tách biệt Data & Behavior Notifier, quá trình xử lý OTP / Loading không làm mất dữ liệu tài khoản trên màn hình.
3. **An toàn bộ nhớ RAM:** `DuetBuilder` yêu cầu bắt buộc truyền `viewModel`, bảo đảm 100% không rò rỉ RAM khi thoát màn hình.
4. **Sealed Class an toàn:** Ép buộc xử lý đủ 100% các trạng thái giao dịch (Thành công, Lỗi mạng, Timeout).

### 🔴 Những điểm cần lưu ý khi áp dụng cho Ngân hàng Enterprise:
1. **Thiếu Global Audit Observer:** BLoC có `BlocObserver` tự động ghi log 100% lịch sử giao dịch/event của user khi gặp sự cố tra soát. Với `duet`, bạn cần tự viết thêm một lớp Middleware Logger nếu cần audit log toàn cục.
2. **Không ép buộc Event Class:** BLoC ép dev phải tạo class `TransferEvent`, ngăn ngừa việc dev gọi lén hàm nghiệp vụ. Với `duet`, cần quy định rõ ràng coding convention trong team.
3. **Quy định dùng `DuetScope`:** Với dự án lớn, nên khuyến khích team dùng `DuetScope` & `context.vm` để đảm bảo tính đóng gói theo nhánh cây Widget thay vì lạm dụng `getVM()` tự do.

