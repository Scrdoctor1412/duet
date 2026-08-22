# Đo lường Hiệu năng Duet

Hiệu năng phải được đo với widget tree thật của ứng dụng, Flutter SDK đang dùng
và thiết bị mục tiêu. Listener microbenchmark chạy nhanh không tự động chứng
minh màn hình không jank; số notification cũng không phải số widget build.

## Chạy bằng profile mode

```shell
flutter run --profile
```

Debug mode có assertions, service extensions và có thể có log từ
`DuetObserver`. Release mode gần người dùng nhất nhưng ít công cụ quan sát.
Profile mode là lựa chọn mặc định để phân tích hiệu năng.

## Đo riêng ba tầng

### 1. Listener dispatch

Đo thời gian cho một workload cố định gồm số state update và số listener. Phép
đo nên kéo dài ít nhất khoảng 100 ms, hoặc được lặp lại nhiều lần rồi lấy median.
Callback rỗng chỉ phản ánh overhead của notifier, không phản ánh nghiệp vụ app.

### 2. Selector và widget build

Ghi riêng selector evaluations và builder invocations. Nếu 60 selector cùng
nghe data channel, mỗi notification sẽ đánh giá cả 60 selector. Khi chỉ một
field được chọn thay đổi, chỉ selector tương ứng nên rebuild.

- Evaluations cao nhưng builds thấp: cân nhắc chia state quá rộng hoặc làm
  selector rẻ hơn nếu CPU time đã đáng kể.
- Builds cao: đặt reactive widget sát phần UI thay đổi hoặc chọn một giá trị
  immutable nhỏ hơn.

### 3. Frame timing

Dùng Flutter `FrameTiming` hoặc DevTools Performance và báo cáo:

- average build duration;
- average raster duration;
- average và P95 total frame time;
- worst frame để hỗ trợ chẩn đoán;
- số frame vượt budget của màn hình mục tiêu.

Budget phổ biến của 60 Hz là 16,67 ms. Màn hình 120 Hz chỉ có 8,33 ms, nên cùng
một workload có thể đạt ở 60 Hz nhưng trễ frame ở 120 Hz.

## Quy trình đo ổn định

1. Dùng thiết bị vật lý và profile mode.
2. Đóng tác vụ nền nặng và giữ điều kiện nhiệt tương đương.
3. Warm-up shader và màn hình test trong 30–60 frame.
4. Đo ít nhất 300 frame cho workload liên quan UI.
5. Lặp lại từ năm lần trở lên.
6. So sánh median và P95; không kết luận từ một worst frame đơn lẻ.
7. Giữ nguyên Flutter version, thiết bị, refresh rate và workload khi so sánh
   các state-management implementation.

Chênh lệch vài phần mười mili-giây trong phép đo rất ngắn thường đến từ timer,
scheduler, xung CPU hoặc garbage collection. Chỉ coi là regression khi kết quả
lặp lại cho thấy xu hướng ổn định.

## Hiểu đúng batching

`batch()` gom notification đang chờ thành một notification cho mỗi channel Duet
đã thay đổi. Nó giảm listener dispatch và selector evaluation, nhưng không loại
bỏ reducer work hoặc allocation state trung gian. Khi có thể, vẫn nên tính state
cuối cùng rồi emit một lần.
