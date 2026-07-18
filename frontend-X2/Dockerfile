# ---- Build stage ----
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

ARG API_BASE_URL=http://localhost:8080
ARG USE_MOCK_BACKEND=false

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release \
    --dart-define=API_BASE_URL=${API_BASE_URL} \
    --dart-define=USE_MOCK_BACKEND=${USE_MOCK_BACKEND}

# ---- Serve stage ----
FROM nginx:alpine AS serve

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
