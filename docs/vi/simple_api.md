# API đơn giản theo cấp độ

Duet giữ nguyên kiến trúc hai notifier: data nghiệp vụ và behavior UI không bị
trộn vào nhau. API mới chỉ ẩn các kiểu và trạng thái mà màn hình nhỏ không cần
tự định nghĩa.

## Chọn đúng cấp độ

| Nhu cầu | Công cụ |
| --- | --- |
| Toggle, tab hoặc animation hoàn toàn cục bộ | API Flutter như `StatefulWidget` hoặc `ValueNotifier` |
| Màn hình nhỏ/vừa với idle, loading, success, error | `SimpleDuet<D>` |
| Quy trình có behavior nghiệp vụ riêng | `Duet<D, B>` |

Không cần dùng Duet cho mọi biến UI cục bộ. Duet phù hợp khi state cần action,
vòng đời rõ ràng, chia sẻ cho widget con hoặc kiểm thử độc lập.

## Màn hình nhỏ: chỉ một class

```dart
class CounterDuet extends SimpleDuet<int> {
  CounterDuet() : super(initialData: 0);

  void increment() => emitData(data + 1);
}

class CounterScreen extends DuetView<CounterDuet> {
  const CounterScreen({super.key});

  @override
  CounterDuet bindDuet() => CounterDuet();

  @override
  Widget build(BuildContext context, CounterDuet duet) {
    return duet.watchData(
      builder: (context, count) => TextButton(
        onPressed: duet.increment,
        child: Text('$count'),
      ),
    );
  }
}
```

`duet.watchData` chỉ nghe data notifier, `duet.watchUi` chỉ nghe behavior
notifier và `duet.watchBoth` nghe cả hai. Duet được truyền trực tiếp từ
`DuetView` xuống widget con nên dependency luôn rõ ràng, không cần tìm qua
`BuildContext` và không phải lặp lại cặp generic data/behavior.

## Tác vụ bất đồng bộ

```dart
class ProductsDuet extends SimpleDuet<List<Product>> {
  ProductsDuet() : super(initialData: const []);

  Future<void> load() async {
    await runData(repository.fetchProducts);
  }
}
```

`runData()` thực hiện tuần tự:

1. Chuyển status sang `UiLoading` nhưng giữ data hiện tại.
2. Chạy `Future`.
3. Thành công: cập nhật data và `UiSuccess` trong cùng transaction.
4. Thất bại: giữ data và phát `UiError` chứa error cùng stack trace.

Khi kết quả cần được kết hợp với data hiện tại, dùng `runTask()`:

```dart
await runTask(
  task: () => repository.fetchNextPage(page),
  reduce: (current, nextPage) => [...current, ...nextPage],
  successState: (_) => const UiSuccess('Đã tải thêm'),
);
```

## Khi nào chuyển sang full Duet

Nếu behavior mang ý nghĩa nghiệp vụ như `requestingOtp`, `verifyingOtp`,
`awaitingApproval` hoặc `transferCompleted`, hãy định nghĩa sealed hierarchy và
dùng `Duet<TransferData, TransferBehavior>`. Đây là lúc behavior chuẩn bốn trạng
thái không còn diễn đạt đủ domain.

API cũ `DuetBuilder<D, B>` và `DuetWatch<VM>` vẫn được hỗ trợ. Code mới nên ưu
tiên API gắn trực tiếp trên instance như `duet.watchData`, `duet.selectData` và
`duet.listen` để giữ phong cách Duet rõ ràng và dependency tường minh.
