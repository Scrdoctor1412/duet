# 🎯 Best Practices & Production Guidelines

Tài liệu này tập hợp các nguyên tắc thiết kế tốt nhất khi sử dụng `duet` trong các dự án thực tế.

---

## 1. Kỹ thuật chống chớp giật giao diện (No UI Flickering)

Trong ứng dụng di động, khi người dùng thực hiện thao tác làm mới (Pull-to-refresh) hoặc tải thêm trang tiếp theo (Pagination), việc xóa dữ liệu cũ để hiện icon Loading sẽ khiến màn hình bị giật trắng xóa.

### Cách xử lý đúng với Dual-Notifier:
```dart
class ProductViewModel extends Duet<ProductData, ProductUiBehavior> {
  Future<void> refresh() async {
    // 1. CHỈ chuyển behaviorState sang Loading, DỮ LIỆU CŨ VẪN ĐƯỢC GIỮ NGUYÊN trong dataState
    emitBehavior(ProductUiBehavior.loading());

    try {
      final newProducts = await repository.fetchLatestProducts();
      
      // 2. Cập nhật dataState mới
      emitData(ProductData(products: newProducts));
      emitBehavior(ProductUiBehavior.success());
    } catch (e) {
      emitBehavior(ProductUiBehavior.error(e.toString()));
    }
  }
}
```

 Ở UI, danh sách sản phẩm cũ vẫn hiển thị bình thường, chỉ có lớp Overlay Spinner mờ đè lên trên. Trải nghiệm ứng dụng sẽ cực kỳ mượt mà.

---

## 2. Áp dụng Tính bất biến (Immutability) & Kết hợp `freezed`

### Tại sao phải dùng Immutable State?
`ValueNotifier` so sánh giá trị cũ và mới bằng toán tử `==`. Với class không
override `==`, kết quả thường tương đương so sánh identity; với `freezed` hoặc
class có value equality, hai object khác nhau nhưng bằng nhau vẫn không phát
notification.

Nếu bạn sửa trực tiếp danh sách cũ:
```dart
// ❌ SAI: Mutate state cũ rồi gán lại cùng giá trị -> có thể không notification.
dataState.products.add("New Item");
emitData(dataState); 
```

Bạn bắt buộc phải tạo một đối tượng MỚI:
```dart
// ✅ ĐÚNG: Tạo state immutable mới với nội dung đã cập nhật.
emitData(ProductData(products: [...dataState.products, "New Item"]));
```

### Kết hợp với `freezed` package:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_state.freezed.dart';

@freezed
class ProductData with _$ProductData {
  const factory ProductData({
    required List<String> products,
    @Default(true) bool hasMore,
  }) = _ProductData;
}
```
*Lợi ích:* `freezed` sinh `copyWith()` và value equality. Lưu ý rằng equality
trên collection lớn cũng có chi phí; không nên deep-compare dữ liệu lớn trong
selector nếu chưa đo.

---

## 3. Selector và batching

- Mỗi notification khiến mọi `DuetSelector` trên channel tương ứng chạy lại
  hàm `selector`.
- Chỉ selector có kết quả thay đổi mới gọi `setState()`.
- Selector nên là phép đọc O(1); tránh sort, filter hoặc parse trong selector.
- `batch()` giảm notification và selector evaluation, nhưng không loại bỏ chi
  phí tạo các state trung gian.
- Nhiều lần `setState()` đồng bộ có thể được Flutter gộp vào cùng một frame, vì
  vậy số notification không được gọi là số widget rebuild.

Để đánh giá jank, chạy profile mode theo [hướng dẫn hiệu năng](performance.md).

---

## 4. Quản lý Bộ nhớ & Tắt AutoDispose khi cần (KeepAlive)

### Khi nào nên dùng `autoDispose` (Mặc định = `true`)?
- Tất cả các màn hình chi tiết, màn hình form nhập liệu, màn hình popup/dialog ngắn hạn.
- Giúp RAM tự động giải phóng ngay khi người dùng thoát màn hình.

### Khi nào nên tắt AutoDispose (`autoDispose = false`)?
- State dùng chung như `AuthViewModel`, `ThemeViewModel` hoặc `CartViewModel`.
- Đăng ký các instance này bằng `Duets.shared()` để registry sở hữu vòng đời rõ ràng.

```dart
class AuthViewModel extends Duet<UserData, UiState> {
  AuthViewModel() : super(...);

  // 💡 Giữ ViewModel trong RAM vĩnh viễn
  @override
  bool get autoDispose => false; 
}
```

---

## 5. Hướng dẫn Unit Test cho `duet`

Duet cục bộ có thể test trực tiếp như object Dart thông thường. Với test dùng
`Duets.shared()`, gọi `Duets.resetAll()` trong `tearDown()` để tránh state dùng
chung rò rỉ giữa các test case:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:duet/duet.dart';

void main() {
  tearDown(Duets.resetAll);

  test('ProductViewModel fetchProducts emits loading and success', () async {
    final viewModel = ProductViewModel();

    expect(viewModel.behaviorState, isA<ProductUiIdle>());

    final future = viewModel.fetchProducts();
    expect(viewModel.behaviorState, isA<ProductUiLoading>());

    await future;
    expect(viewModel.behaviorState, isA<ProductUiSuccess>());
    expect(viewModel.dataState.products.isNotEmpty, true);
    viewModel.dispose();
  });
}
```

