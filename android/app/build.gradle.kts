plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.solodesk.mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // applicationId must match the package name registered on the Android
        // OAuth client in Google Cloud Console (GOOGLE_ANDROID_CLIENT_ID).
        applicationId = "com.solodesk.mobile"
        // Google Sign-In (Android) requires the signing certificate SHA-1
        // fingerprint to be registered on that OAuth client. Register both the
        // debug and release keystore fingerprints:
        //   keytool -list -v -keystore <keystore> -alias <alias> | grep SHA1
        // SHA-1 (debug):   <REGISTER_IN_GOOGLE_CLOUD_CONSOLE>
        // SHA-1 (release): <REGISTER_IN_GOOGLE_CLOUD_CONSOLE>
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
