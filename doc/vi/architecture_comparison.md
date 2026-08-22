# So sánh Kiến trúc và Hiệu năng

Tài liệu này so sánh đặc tính kiến trúc của Duet với Provider, Riverpod,
BLoC/Cubit và GetX. Đây không phải bảng xếp hạng tốc độ tuyệt đối. Kết quả thực
tế phải được đo với cùng widget tree, workload, Flutter SDK và thiết bị.

## Cơ chế của Duet

Mỗi `Duet<D, B>` có hai `DuetValueNotifier` độc lập:

- `dataNotifier` giữ dữ liệu nghiệp vụ lâu dài;
- `behaviorNotifier` giữ trạng thái UI tạm thời;
- event stream broadcast dùng cho side effect một lần;
- reference counting quản lý vòng đời instance được widget sử dụng.

Khi một channel thay đổi, `ValueNotifier` dispatch đồng bộ tới listener của
channel đó theo O(N listeners). `DuetBuilder` và `DuetWatch` gọi `setState` khi
channel được nghe phát notification. `DuetSelector` luôn tính lại selector trên
notification, nhưng chỉ gọi `setState` nếu selected value thay đổi.

Exact typed lookup qua `DuetScope.of<VM>` dùng inherited-element index. API tra
theo cặp `<D, B>` có ancestor fallback để tương thích. Shared state có chủ đích
được lookup trong registry theo type và optional key.

## So sánh đặc tính

| Tiêu chí | Duet | Provider | Riverpod | BLoC/Cubit | GetX |
| --- | --- | --- | --- | --- | --- |
| Reactive core | Hai `ValueNotifier` | Thường là `ChangeNotifier`/`Listenable` | Provider dependency graph | State stream/subscription | Rx hoặc explicit update |
| Phạm vi cập nhật | Data, UI hoặc selected value | Provider/selected value | Provider/selected dependency | State hoặc selected value | Rx dependency hoặc update ID |
| Lookup | Typed scope hoặc registry rõ ràng | Inherited provider | Provider container | `BlocProvider` | Global dependency registry |
| Async composition | Method Dart trực tiếp, `SimpleDuet` helpers | Do ứng dụng tổ chức | Provider async primitives | Event/state pipeline | Controller/workers |
| Lifecycle | Scope + reference counting | Provider ownership | Container + auto-dispose policies | Provider ownership | Binding/smart-management policies |
| Base machinery mỗi unit | 2 notifier + event stream | Phụ thuộc provider type | Provider nodes/dependencies | Bloc/Cubit + state stream | Rx/controller machinery |
| Selective rebuild | `DuetSelector` | `Selector`/`context.select` | `.select()` | `BlocSelector`/`buildWhen` | `Obx`/IDs |

Các lựa chọn trên có trade-off khác nhau. Duet ưu tiên engine nhỏ, synchronous và
dễ lần theo. Riverpod mạnh về dependency composition; BLoC mạnh về event pipeline
và governance; Provider gần Flutter primitives; GetX ưu tiên API ngắn và hệ sinh
thái tích hợp. Không thể suy ra app nào nhanh hơn chỉ từ bảng kiến trúc.

## Batching và widget rebuild

`batch()` gom notification đang chờ thành một notification cho mỗi channel đã
thay đổi. Nó giảm listener dispatch và selector evaluation. Nó không loại bỏ
việc tạo state trung gian bên trong batch.

Số notification không phải số widget build. Nhiều `setState()` đồng bộ trước
frame kế tiếp có thể được Flutter coalesce thành một build. Vì vậy benchmark chỉ
đếm `notifyListeners()` không đủ để tuyên bố giảm cùng tỷ lệ widget rebuild hoặc
jank.

Xem [Đo lường Hiệu năng](performance.md) để đo dispatch, selector và frame timing
riêng biệt.

## Lưu ý khi dùng trong dự án lớn

- Duet chỉ phụ thuộc Flutter SDK, giúp bề mặt dependency nhỏ nhưng không loại bỏ
  rủi ro supply chain của toàn ứng dụng.
- `DuetObserver` và `DuetLogger` quan sát state/effect trong debug mode. Audit log
  production vẫn cần transport, redaction, persistence và security do ứng dụng
  thiết kế.
- Duet không bắt buộc event class cho mọi intent; team lớn nên thống nhất public
  intent methods và coding conventions.
- Dùng `DuetView`/`DuetScope` cho state cục bộ và `Duets.shared` cho state dùng
  chung có chủ đích. Không dùng API service-locator legacy cho code mới.
- Tách state có tần suất cập nhật hoặc vòng đời khác nhau thành các Duet nhỏ hơn
  thay vì một application-wide Duet khổng lồ.
