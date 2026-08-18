import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing reads from android/key.properties, which is gitignored (see
// android/key.properties.example for the template). Debug builds and CI don't
// need it, so its absence only affects the "release" signingConfig below —
// falling back to the debug key with a loud warning instead of a silent one,
// since a silent fallback is what caused release APKs to ship debug-signed before.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
} else {
    logger.warn(
        "WARNING: android/key.properties not found — release build will fall back to " +
            "debug signing. Copy android/key.properties.example to android/key.properties " +
            "and fill in your keystore details to produce a real release-signed APK.",
    )
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

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                if (keystorePropertiesFile.exists()) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }
        }
    }
}

// Kotlin phải cùng JVM target với Java. Không đặt dòng này thì Kotlin lấy
// mặc định theo JDK đang cài (JDK 21 trên máy dev), lệch với Java 17 ở trên
// và Gradle dừng với "Inconsistent JVM-target compatibility".
// Kotlin 2.3.x đã bỏ hẳn DSL `kotlinOptions`, nên dùng `compilerOptions`.
kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
