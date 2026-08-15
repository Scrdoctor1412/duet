# 💡 Core Concepts & Detailed Guide

Tài liệu này giải thích chi tiết cách vận hành và mã nguồn triển khai của từng thành phần trong `duet`.

---

## 1. `Duet<D, B>` (Concept "Song Tấu" Data & UI)

`Duet` là class cơ sở abstract cho mọi ViewModel/Controller theo kiến trúc Dual-Notifier. Bạn có thể sử dụng trực tiếp tên `Duet<D, B>` hoặc dùng các typedef aliases tiện lợi như `ViewModel<D, B>`, `DuetViewModel<D, B>`, `DuetController<D, B>`, `BaseViewModel<D, B>`.

### Cấu trúc cơ bản:
```dart
abstract class Duet<D, B> {
  final D initialData;
  final B initialBehavior;

  late final DuetValueNotifier<D> dataNotifier;
  late final DuetValueNotifier<B> behaviorNotifier;

  Duet({required this.initialData, required this.initialBehavior}) {
    dataNotifier = DuetValueNotifier<D>(initialData);
    behaviorNotifier = DuetValueNotifier<B>(initialBehavior);
  }

  // Getters tiện lợi
  D get data => dataNotifier.value;
  B get ui => behaviorNotifier.value;

  // Cập nhật State (Chỉ dùng nội bộ Duet/ViewModel)
  @protected
  void emitData(D newData) => dataNotifier.value = newData;

  @protected
  void emitBehavior(B newBehavior) => behaviorNotifier.value = newBehavior;

  @protected
  void emit({D? data, B? ui}) => emitState(data: data, ui: ui);

  // Resets state về ban đầu
  @mustCallSuper
  void invalidate() {
    emitData(initialData);
    emitBehavior(initialBehavior);
  }
}

// 🎭 Typedef Aliases hỗ trợ linh hoạt phong cách lập trình:
typedef ViewModel<D, B> = Duet<D, B>;
typedef DuetViewModel<D, B> = Duet<D, B>;
typedef DuetController<D, B> = Duet<D, B>;
typedef BaseViewModel<D, B> = Duet<D, B>;
```

### Phương thức & Annotation quan trọng:
* `@protected updateData(D Function(D current) transform)`: Cập nhật dữ liệu nghiệp vụ một cách an toàn. Tự động kiểm tra `assert` trong chế độ Debug để cảnh báo nếu dev mutate biến trực tiếp thay vì tạo bản sao mới.
* `@protected notifyDataChanged()`: Ép buộc phát lại thông báo tới UI khi dữ liệu bị mutate trực tiếp (in-place mutation).
* `bool get isGlobal => false;`: Đánh dấu ViewModel có phải Singleton toàn cục hay không. Mặc định là `false` (ViewModel cục bộ). Các ViewModel toàn cục như `AuthViewModel`, `CartViewModel` ghi đè trả về `true` để cho phép dùng `getVM()` không cần `key`.
* `@protected emitData(D newData)`: Cho phép class con phát trực tiếp đối tượng dữ liệu mới.
* `@mustCallSuper invalidate()`: Reset state về `initialData` và `initialBehavior`. Khi subclass override phải gọi `super.invalidate()`.
* `bool get autoDispose => true;`: Ghi đè getter này và trả về `false` nếu muốn ViewModel sống vĩnh viễn trong RAM (KeepAlive).

---

## 2. `UiState` & Sealed Class (Dart 3)

`duet` cung cấp sẵn một Sealed Class `UiState` chuẩn hóa toàn cục, hoặc bạn có thể tự khai báo Sealed Class tùy chỉnh cho từng tính năng bằng từ khóa `sealed` và `factory` của Dart 3.

### Class `UiState` dựng sẵn của Package:
```dart
@immutable
sealed class UiState {
  const UiState();

  factory UiState.idle() = UiIdle;
  factory UiState.loading() = UiLoading;
  factory UiState.success() = UiSuccess;
  factory UiState.error(String message) = UiError;
}

final class UiIdle extends UiState { const UiIdle(); }
final class UiLoading extends UiState { const UiLoading(); }
final class UiSuccess extends UiState { const UiSuccess(); }
final class UiError extends UiState {
  final String message;
  const UiError(this.message);
}
```

### Sử dụng Pattern Matching ở UI:
```dart
return switch (viewModel.behaviorState) {
  UiLoading() => const CircularProgressIndicator(),
  UiError(message: final msg) => Text("Lỗi: $msg"),
  UiIdle() || UiSuccess() => const SizedBox.shrink(),
};
```

---

## 3. `getVM()` & Context Auto-Keying

`getVM()` là hàm trợ giúp định vị dịch vụ (Lazy Service Locator).

### Cách 1: Tự động quản lý Key theo State màn hình (`key: this`) - KHUYÊN DÙNG
Trong `StatefulWidget`, truyền `key: this` để đảm bảo mỗi khi một màn hình mới được push lên, một ViewModel riêng biệt sẽ được khởi tạo dựa trên địa chỉ bộ nhớ RAM của `State` đó:
```dart
class _MyScreenState extends State<MyScreen> {
  late final viewModel = getVM(() => MyViewModel(), key: this);
}
```

### Cách 2: Tự động lấy Key qua BuildContext (`context.getVM(...)`)
Sử dụng extension `context.getVM()` giúp tự động lấy tên Route/URI hiện tại làm Key nếu bạn không truyền Key thủ công:
```dart
final viewModel = context.getVM(() => ProductDetailViewModel());
```

### Cách 3: ViewModel Toàn cục (`isGlobal = true`)
Dành cho các ViewModel dùng chung toàn app (Auth, Theme, Cart):
```dart
class AuthViewModel extends Duet<UserData, UiState> {
  @override
  bool get isGlobal => true;
}

// Khởi tạo mà không cần truyền key ở bất kỳ đâu
final authVm = getVM(() => AuthViewModel());
```

---

## 4. `DuetScope` & `context.vm` (Cây Widget Scope)

Khi bạn muốn phân vùng ViewModel theo cây Widget mà không cần truyền `viewModel` qua nhiều tầng Constructor:

### Khai báo ở Widget Cha:
```dart
DuetScope(
  viewModel: getVM(() => ProductItemViewModel(productA), key: productA.id),
  child: const ProductCardWidget(),
)
```

### Truy cập ở Widget Con:
```dart
class ProductCardWidget extends StatelessWidget {
  const ProductCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Tự động tìm DuetScope gần nhất trên cây Widget!
    final viewModel = context.vm<ProductItemViewModel>();

    return DuetBuilder(
      viewModel: viewModel,
      builder: (context, data) => Text(data.name),
    );
  }
}
```

---

## 5. `DuetBuilder` & AutoDispose Lifecycle

`DuetBuilder` là Widget khoanh vùng rebuild chính xác cho từng nhóm Widget và tự động đếm tham chiếu `autoDispose`.

```dart
// 1. Lắng nghe Dữ liệu nghiệp vụ (dataNotifier)
DuetBuilder(
  builder: (context, data) {
    return Text(data.title);
  },
)

// 2. Lắng nghe Trạng thái UI (behaviorNotifier)
DuetBuilder.ui(
  builder: (context, ui) {
    return switch (ui) { ... };
  },
)

// 3. Lắng nghe CẢ Data và UI cùng lúc
DuetBuilder.both(
  builder: (context, data, ui) {
    return Column(children: [...]);
  },
)
```

### Vòng đời AutoDispose (Reference Counting):
1. **Khi `DuetBuilder` mounted (`initState`):** Gọi `viewModel.retain()` $\rightarrow$ Biến đếm `_refCount++`.
2. **Khi `DuetBuilder` unmounted (`dispose`):** Gọi `viewModel.release()` $\rightarrow$ Biến đếm `_refCount--`.
3. **Khi `_refCount == 0`:** Nếu `autoDispose == true`, ViewModel sẽ tự động gọi `dispose()` và bị hủy khỏi Registry RAM.

---

## 6. `DuetSelector` (Tối ưu hóa Selective Rebuilding)

Khi `dataState` của bạn chứa nhiều trường thông tin nhưng một Widget **chỉ quan tâm duy nhất 1 trường**, hãy sử dụng `DuetSelector<VM, T>` (với 2 kiểu generic: ViewModel `VM` và giá trị trích xuất `T`) để chỉ rebuild khi trường đó thay đổi:

```dart
// Chỉ rebuild khi count thay đổi, bỏ qua nếu title hay các thuộc tính khác thay đổi!
DuetSelector<CounterViewModel, int>(
  selector: (vm) => vm.data.count,
  builder: (context, count) {
    return Text('Số lượng: $count');
  },
)

// Hoặc selector cho UI state:
DuetSelector<CounterViewModel, bool>.ui(
  selector: (vm) => vm.ui is UiLoading,
  builder: (context, isLoading) {
    return isLoading ? const CircularProgressIndicator() : const SizedBox();
  },
)
```

---

## 7. `DuetListenableBuilder`

Dùng khi muốn lắng nghe các đối tượng `Listenable` thông thường của Flutter (như `AnimationController`, `TextEditingController`, `ScrollController`) không thuộc ViewModel:

```dart
DuetListenableBuilder(
  listenTo: [myTextController, myAnimationController],
  builder: (context) {
    return Text(myTextController.text);
  },
)
```
