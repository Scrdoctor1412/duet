# 🚀 Duet Documentation

Chào mừng bạn đến với tài liệu chính thức của **`duet`** — một thư viện quản lý trạng thái (State Management) và định vị dịch vụ (Service Locator) siêu nhẹ, 100% thuần Flutter Native, không phụ thuộc vào bất kỳ package bên thứ ba nào.

---

## 📚 Mục lục Tài liệu

1. 📖 **[Tổng quan & Kiến trúc Core](overview.md)**
   * Triết lý thiết kế (Philosophy)
   * 5 Trụ cột cốt lõi của `duet`
   * Bảng so sánh tính năng với BLoC, Riverpod, GetX
2. 💡 **[Các Khái niệm Cốt lõi & Hướng dẫn Sử dụng](core_concepts.md)**
   * `Duet<D, B>` (hay `ViewModel`, `DuetViewModel`, `DuetController` — Tách biệt Data State & UI Behavior State)
   * `UiState` & `Sealed Class` (Dart 3 Pattern Matching & Redirecting Factories)
   * `getVM()` (Lazy Service Locator & Parametric Scoping với `key:`)
   * `DuetScope` & `context.vm` (Phân vùng theo Cây Widget)
   * `DuetBuilder` (Khoanh vùng Rebuild mượt mà, Tự động quản lý AutoDispose)
   * `DuetSelector` (Lắng nghe tối ưu duy nhất 1 field/thuộc tính)
   * `DuetListenableBuilder` (Lắng nghe các Listenable độc lập)
   * Cơ chế `autoDispose` & `keepAlive` (Reference Counting)
3. 🎯 **[Best Practices & Hướng dẫn Thực tế](best_practices.md)**
   * Kỹ thuật chống chớp giật UI (No UI Flickering) khi Reload
   * Sử dụng Immutability & Kết hợp với `freezed`
   * Quản lý bộ nhớ RAM & Hướng dẫn Unit Test
4. 🔬 **[So sánh Chuyên sâu & Đánh giá Hiệu năng](architecture_comparison.md)**
   * So sánh cơ chế vận hành bên dưới (Internal Working Mechanics)
   * Phân tích hiệu năng CPU, RAM, GC, và Render Tree
   * Đánh giá mức độ phù hợp cho App Ngân hàng & Fintech Enterprise
5. 📜 **[Quy ước Lập trình cho Team (Team Conventions)](conventions.md)**
   * 4 Quy tắc cốt lõi giúp Dev mới nắm vững dự án trong 2 phút
   * Bảng Checklist Do's & Don'ts chuẩn hóa mã nguồn
6. 📖 **[Báo cáo Kỹ thuật Từng bước Chi tiết (Technical Step-by-Step Doc)](duet_technical_doc.md)**
   * Ghi lại thiết kế Reference Counting, registry key dạng record và cơ chế batching với `emit()`.
7. ✨ **[API đơn giản theo cấp độ](simple_api.md)**
   * `SimpleDuet<D>` cho màn hình nhỏ và vừa
   * `DuetWatch<VM>` chỉ cần khai báo một kiểu ViewModel
   * `runTask()` và `runData()` chuẩn hóa tác vụ bất đồng bộ

---

## ⚡ Quick Start (Bắt đầu nhanh trong 3 bước)

### Bước 1: Khai báo State với Sealed Class (Dart 3)
```dart
import 'package:flutter/foundation.dart';
import 'package:testing_things/duet/duet.dart';

@immutable
sealed class ProductUiBehavior {
  const ProductUiBehavior();

  factory ProductUiBehavior.idle() = ProductUiIdle;
  factory ProductUiBehavior.loading() = ProductUiLoading;
  factory ProductUiBehavior.success() = ProductUiSuccess;
  factory ProductUiBehavior.error(String message) = ProductUiError;
}

class ProductUiIdle extends ProductUiBehavior { const ProductUiIdle(); }
class ProductUiLoading extends ProductUiBehavior { const ProductUiLoading(); }
class ProductUiSuccess extends ProductUiBehavior { const ProductUiSuccess(); }
class ProductUiError extends ProductUiBehavior {
  final String message;
  const ProductUiError(this.message);
}

class ProductData {
  final List<String> products;
  final int totalCount;
  ProductData({required this.products, this.totalCount = 0});
}
```

### Bước 2: Tạo ViewModel / Duet
```dart
import 'package:testing_things/duet/duet.dart';

class ProductViewModel extends Duet<ProductData, ProductUiBehavior> {
  ProductViewModel()
      : super(
          initialData: ProductData(products: []),
          initialBehavior: const ProductUiIdle(),
        );

  Future<void> fetchProducts() async {
    if (behaviorState is ProductUiLoading) return;

    emitBehavior(const ProductUiLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      final list = ["iPhone 15", "MacBook M3"];
      emitData(ProductData(products: list, totalCount: list.length));
      emitBehavior(const ProductUiSuccess());
    } catch (e) {
      emitBehavior(ProductUiError(e.toString()));
    }
  }
}
```

### Bước 3: Xây dựng UI An toàn & Ngắn gọn
```dart
import 'package:flutter/material.dart';
import 'package:testing_things/duet/duet.dart';

class ProductScreen extends DuetView<ProductViewModel> {
  const ProductScreen({super.key});

  @override
  ProductViewModel bindDuet() => ProductViewModel();

  @override
  Widget build(BuildContext context, ProductViewModel vm) {
    return Scaffold(
      appBar: AppBar(
        title: DuetSelector<ProductViewModel, int>(
          selector: (vm) => vm.data.totalCount,
          builder: (context, total) => Text("Sản phẩm ($total)"),
        ),
      ),
      body: Stack(
        children: [
          // 🟢 Rebuild duy nhất ListView khi Data thay đổi (Tự động retain/release ViewModel)
          DuetBuilder(
            builder: (context, data) {
              if (data.products.isEmpty) {
                return const Center(child: Text("Bấm nút + để tải sản phẩm"));
              }
              return ListView.builder(
                itemCount: data.products.length,
                itemBuilder: (ctx, i) => ListTile(title: Text(data.products[i])),
              );
            },
          ),
          
          // 🟢 Rebuild duy nhất Overlay Loading khi Behavior thay đổi
          DuetBuilder.ui(
            builder: (context, behavior) {
              return switch (behavior) {
                ProductUiLoading() => const Center(child: CircularProgressIndicator()),
                ProductUiError(message: final msg) => Center(child: Text("Lỗi: $msg")),
                ProductUiIdle() || ProductUiSuccess() => const SizedBox.shrink(),
              };
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: vm.fetchProducts,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```
