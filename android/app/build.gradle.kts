plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.learn_flutter1"
    compileSdk = flutter.compileSdkVersion

    ndkVersion = "27.0.12077973" // 👈 nếu không build native thì có thể bỏ

    defaultConfig {
        applicationId = "com.example.learn_flutter1"
        minSdk = 23  // 👈 Firebase Auth yêu cầu minSdk >= 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BoM (quản lý version đồng bộ cho tất cả lib Firebase)
    implementation(platform("com.google.firebase:firebase-bom:33.1.2"))

    // Các thư viện Firebase bạn dùng
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
}
