# Shared Duet giữa nhiều màn hình

Duet phân biệt rõ hai loại vòng đời:

- Local Duet được tạo trực tiếp trong `DuetView.bindDuet()` và tự dispose khi
  màn hình đóng.
- Shared Duet được lấy qua `Duets.shared()` và tồn tại cho đến khi ứng dụng gọi
  `Duets.reset()`.

Tạo một composition root để tất cả shared dependency nằm cùng một nơi:

```dart
abstract final class AppDuets {
  static ProductCatalogDuet get products {
    return Duets.shared<ProductCatalogDuet>(ProductCatalogDuet.new);
  }

  static CartDuet get cart {
    return Duets.shared<CartDuet>(CartDuet.new);
  }
}
```

Lần gọi đầu tiên tạo instance:

```dart
final first = AppDuets.cart;
```

Mọi lần gọi tiếp theo trả về chính instance đó:

```dart
final second = AppDuets.cart;
identical(first, second); // true
```

Hai màn hình có thể bind cùng shared Duet mà không truyền qua constructor:

```dart
class ProductScreen extends DuetView<ProductCatalogDuet> {
  @override
  ProductCatalogDuet bindDuet() => AppDuets.products;
}

class SearchScreen extends DuetView<ProductCatalogDuet> {
  @override
  ProductCatalogDuet bindDuet() => AppDuets.products;
}
```

Registry giữ một reference riêng nên shared state không bị dispose trong khoảng
thời gian màn hình A đã đóng nhưng màn hình B chưa mở. Không cần override
`isGlobal` hoặc `autoDispose`.

`find` không tạo instance mới:

```dart
final existing = Duets.find<CartDuet>();
```

`reset` dispose và xóa instance. Lần `shared` tiếp theo sẽ tạo instance mới:

```dart
Duets.reset<CartDuet>();
```

`initialize()` nên chỉ tải dữ liệu lần đầu, còn `refresh()` luôn tải lại:

```dart
await AppDuets.products.ensureLoaded(); // không tải trùng
await AppDuets.products.refresh();      // chủ động reload
```
