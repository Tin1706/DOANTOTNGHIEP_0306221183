# === GIAI ĐOẠN 1: Dùng Flutter SDK để build code sang HTML/JS ===
FROM ghcr.io/cirruslabs/flutter:3.24.0 AS build-env

WORKDIR /app
USER root

# Copy file cấu hình để tải thư viện trước
COPY pubspec.yaml ./
RUN flutter pub get

# Copy toàn bộ source code vào container
COPY . .

# Build Flutter Web thành sản phẩm tĩnh (nằm trong thư mục build/web)
RUN flutter config --enable-web
RUN flutter build web --release

# === GIAI ĐOẠN 2: Dùng Nginx gọn nhẹ để host trang web ===
FROM nginx:alpine

# Copy toàn bộ file tĩnh đã build từ Giai đoạn 1 vào thư mục gốc của Nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Mở cổng 80 bên trong container
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]