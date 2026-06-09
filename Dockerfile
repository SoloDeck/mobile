# ===========================================================================
# SoloDesk Mobile — multi-stage Dockerfile (CI/build only)
# Flutter apps are not served as containers; this image is used exclusively
# for CI: analyze, codegen, test, and APK builds.
# ===========================================================================

# ---------------------------------------------------------------------------
# Stage 1: deps — Flutter SDK + pub get
# ---------------------------------------------------------------------------
FROM ghcr.io/cirruslabs/flutter:stable AS deps

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get


# ---------------------------------------------------------------------------
# Stage 2: codegen — build_runner (freezed, riverpod, drift, envied)
# ---------------------------------------------------------------------------
FROM deps AS codegen

COPY . .
RUN dart run build_runner build --delete-conflicting-outputs


# ---------------------------------------------------------------------------
# Stage 3: test — format check + analyze + unit/widget tests
# ---------------------------------------------------------------------------
FROM codegen AS test

RUN dart format --output=none --set-exit-if-changed . \
 && flutter analyze --fatal-infos \
 && flutter test test/unit/ --coverage \
 && flutter test test/widget/


# ---------------------------------------------------------------------------
# Stage 4: android-build — release APK
# google-services.json and signing keystore are injected by CI before this
# stage runs (base64-decoded to filesystem via workflow steps).
# ---------------------------------------------------------------------------
FROM codegen AS android-build

RUN flutter build apk --release
