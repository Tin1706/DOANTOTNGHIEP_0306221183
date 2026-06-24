# === GIAI ĐOẠN 1: Giữ nguyên cấu trúc cực chuẩn của bạn ===
FROM ghcr.io/cirruslabs/flutter:3.27.0 AS build-env

WORKDIR /app
USER root

COPY pubspec.yaml ./
RUN flutter pub get

COPY . .

RUN flutter config --enable-web
RUN flutter build web --release

# === GIAI ĐOẠN 2: Sửa lại để tương thích với Cổng động của Render ===
FROM nginx:alpine

COPY --from=build-env /app/build/web /usr/share/nginx/html

# 🟢 SỬA DÒNG NÀY: Dùng lệnh vỏ shell để bắt Nginx ghi đè cổng động từ Render vào cấu hình trước khi chạy
CMD ["sh", "-c", "sed -i 's/listen[:[:space:]]*80;/listen '\"$PORT\"';/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]