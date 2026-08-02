import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:duet/src/core/duet_observer.dart';
import 'package:duet/src/core/ui_state.dart';

/// Top-level custom ValueNotifier h�?tr�?Gom thông báo (Batching) và phát thông báo cưỡng ch�?(forceNotify).
class DuetValueNotifier<T> extends ValueNotifier<T> {
  DuetValueNotifier(super.value);

  bool _isBatching = false;
  bool _hasPendingNotify = false;

  void beginBatch() {
    _isBatching = true;
  }

  void endBatch() {
    _isBatching = false;
    if (_hasPendingNotify) {
      _hasPendingNotify = false;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (_isBatching) {
      _hasPendingNotify = true;
    } else {
      super.notifyListeners();
    }
  }

  /// Ép buộc phát thông báo tới tất c�?listener k�?c�?khi [value] không thay đổi reference.
  void forceNotify() {
    notifyListeners();
  }
}

/// Alias cho DuetValueNotifier
typedef ReactiveValueNotifier<T> = DuetValueNotifier<T>;

/// {@template duet}
/// Class cơ s�?abstract quản lý State cho tất c�?các ViewModel/Controller trong ứng dụng theo kiến trúc Duet.
///
/// Quản lý 2 đối tượng [ValueNotifier] riêng biệt:
/// - [dataNotifier]: Quản lý d�?liệu nghiệp v�?thuộc kiểu [D].
/// - [behaviorNotifier]: Quản lý trạng thái hành vi giao diện UI thuộc kiểu [B].
///
/// H�?tr�?cơ ch�?đếm tham chiếu (Reference Counting) đ�?t�?động giải phóng b�?nh�?RAM ([autoDispose])
/// khi không còn bất k�?Widget nào theo dõi.
/// {@endtemplate}
abstract class Duet<D, B> {
  /// Giá tr�?khởi tạo ban đầu cho d�?liệu nghiệp v�?[D].
  final D initialData;

  /// Giá tr�?khởi tạo ban đầu cho trạng thái UI [B].
  final B initialBehavior;

  /// Quản lý và phát thông báo khi d�?liệu nghiệp v�?[D] thay đổi.
  late final DuetValueNotifier<D> dataNotifier;

  /// Quản lý và phát thông báo khi trạng thái hành vi UI [B] thay đổi.
  late final DuetValueNotifier<B> behaviorNotifier;

  /// Biến đếm nội b�?s�?lượng Widget đang ch�?động theo dõi ViewModel này.
  int _refCount = 0;

  /// C�?đánh dấu ViewModel này đã b�?hủy hoàn toàn hay chưa.
  bool _isDisposed = false;

  /// Tr�?v�?`true` nếu ViewModel này đã b�?giải phóng b�?nh�?
  bool get isDisposed => _isDisposed;

  /// S�?lượng Widget hiện tại đang kết nối tới ViewModel (Dành cho kiểm th�?.
  @visibleForTesting
  int get refCount => _refCount;

  /// Cấu hình tính năng t�?động giải phóng b�?nh�?khi không còn Widget lắng nghe.
  bool get autoDispose => true;

  /// Cấu hình đánh dấu ViewModel này có phải là Global Singleton (dùng chung toàn app) hay không.
  bool get isGlobal => false;

  /// Khởi tạo một [Duet] với d�?liệu ban đầu [initialData] và trạng thái UI [initialBehavior].
  Duet({
    required this.initialData,
    required this.initialBehavior,
  }) {
    dataNotifier = DuetValueNotifier<D>(initialData);
    behaviorNotifier = DuetValueNotifier<B>(initialBehavior);
  }

  /// Tr�?v�?đồng b�?giá tr�?d�?liệu nghiệp v�?hiện tại.
  D get dataState => dataNotifier.value;

  /// Tr�?v�?đồng b�?giá tr�?trạng thái UI hiện tại.
  B get behaviorState => behaviorNotifier.value;

  /// Getter viết tắt ngắn gọn cho [dataState].
  D get data => dataNotifier.value;

  /// Getter viết tắt ngắn gọn cho [behaviorState].
  B get ui => behaviorNotifier.value;

  /// Thực thi một nhóm các cập nhật State ([action]) dưới dạng 1 Giao dịch duy nhất (Transaction/Batch).
  @protected
  void batch(void Function() action) {
    if (_isDisposed) return;
    dataNotifier.beginBatch();
    behaviorNotifier.beginBatch();
    try {
      action();
    } finally {
      dataNotifier.endBatch();
      behaviorNotifier.endBatch();
    }
  }

  /// Phát ra d�?liệu nghiệp v�?[newData] mới tới [dataNotifier].
  @protected
  void emitData(D newData) {
    if (_isDisposed) return;
    dataNotifier.value = newData;
  }

  /// Cập nhật d�?liệu nghiệp v�?[D] một cách an toàn bằng một hàm biến đổi [transform].
  @protected
  void updateData(D Function(D current) transform) {
    if (_isDisposed) return;
    final newData = transform(dataState);
    assert(
      !identical(newData, dataState),
      'CẢNH BÁO: updateData() tr�?v�?cùng 1 Object instance! '
      'Bạn đã mutate thuộc tính trực tiếp thay vì tạo bản sao mới với copyWith()? '
      'Nếu muốn ép re-render khi mutate trực tiếp, hãy s�?dụng notifyDataChanged().',
    );
    emitData(newData);
  }

  /// Ép buộc phát thông báo d�?liệu nghiệp v�?[D] đã thay đổi tới [dataNotifier].
  @protected
  void notifyDataChanged() {
    if (_isDisposed) return;
    dataNotifier.forceNotify();
  }

  /// Phát ra trạng thái UI [newBehavior] mới tới [behaviorNotifier].
  @protected
  void emitBehavior(B newBehavior) {
    if (_isDisposed) return;
    behaviorNotifier.value = newBehavior;
  }

  /// Getter viết tắt ngắn gọn đ�?phát ra trạng thái UI [newUi].
  @protected
  void emitUi(B newUi) => emitBehavior(newUi);

  /// Phát ra đồng thời d�?liệu nghiệp v�?[data] và trạng thái UI [ui] trong 1 dòng duy nhất.
  @protected
  void emitState({D? data, B? ui}) {
    if (_isDisposed) return;
    if (data == null && ui == null) return;

    if (kDebugMode && DuetState.observer != null) {
      DuetState.observer!.onStateEmitted(this, data: data, ui: ui);
    }

    batch(() {
      if (data != null) emitData(data);
      if (ui != null) emitBehavior(ui);
    });
  }

  /// Viết tắt ngắn gọn nhất cho [emitState].
  @protected
  void emit({D? data, B? ui}) => emitState(data: data, ui: ui);

  /// Luồng s�?kiện nội b�?cho các tác v�?Side-Effect 1 lần (Toast, Navigation, Dialog...).
  final _eventController = StreamController<Object>.broadcast();

  /// Stream công khai đ�?các [DuetListener] đăng ký lắng nghe s�?kiện 1 lần.
  Stream<Object> get eventStream => _eventController.stream;

  /// Phát ra một s�?kiện 1 lần [event] (Toast, Navigation, Dialog...).
  @protected
  void emitEvent(Object event) {
    if (_isDisposed) return;

    if (kDebugMode && DuetState.observer != null) {
      DuetState.observer!.onEffectEmitted(this, event);
    }

    _eventController.add(event);
  }

  /// Getter viết tắt ngắn gọn đ�?phát ra s�?kiện [event].
  @protected
  void emitEffect(Object event) => emitEvent(event);

  /// Khôi phục State v�?lại [initialData] và [initialBehavior] ban đầu.
  @mustCallSuper
  void invalidate() {
    if (_isDisposed) return;
    emitData(initialData);
    emitBehavior(initialBehavior);
  }

  /// Tăng s�?lượng tham chiếu khi có 1 Widget bắt đầu theo dõi ViewModel.
  @internal
  void retain() {
    if (_isDisposed) return;
    _refCount++;
  }

  /// Giảm s�?lượng tham chiếu và t�?động gọi [dispose] nếu [_refCount] giảm v�?0 và [autoDispose] = true.
  @internal
  void release(void Function() onDisposeRegistry) {
    _refCount--;
    if (_refCount <= 0 && autoDispose) {
      dispose();
      onDisposeRegistry();
    }
  }

  /// Giải phóng b�?nh�?của các [ValueNotifier] và [StreamController] nội b�?
  @mustCallSuper
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    dataNotifier.dispose();
    behaviorNotifier.dispose();
    _eventController.close();
  }
}

// ============================================================================
// 🎭 TYPEDEF ALIASES (Tùy chọn phong cách gọi cho Developer)
// ============================================================================

/// Alias kết hợp thương hiệu Duet + ViewModel
typedef DuetViewModel<D, B> = Duet<D, B>;

/// Alias cho phong cách Controller
typedef DuetController<D, B> = Duet<D, B>;

/// Alias chuẩn MVVM truyền thống
typedef ViewModel<D, B> = Duet<D, B>;

/// Alias đảm bảo backward compatibility với code cũ dùng BaseViewModel
typedef BaseViewModel<D, B> = Duet<D, B>;
