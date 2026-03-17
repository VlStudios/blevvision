import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // FlutterFire
    id("com.google.gms.google-services")
    // Flutter Gradle Plugin deve vir depois
    id("dev.flutter.flutter-gradle-plugin")
}

// Carregar keystore.properties
val keystorePropsFile = rootProject.file("app/keystore.properties")
val keystoreProps = Properties().apply {
    if (keystorePropsFile.exists()) {
        load(FileInputStream(keystorePropsFile))
    }
}

android {
    namespace = "com.blevvision.blevvision"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.blevvision.blevvision"
        minSdk = maxOf(23, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            storeFile = keystoreProps["storeFile"]?.let { file(it) }
            storePassword = keystoreProps["storePassword"] as String?
            keyAlias = keystoreProps["keyAlias"] as String?
            keyPassword = keystoreProps["keyPassword"] as String?
        }
    }

    buildTypes {
        debug {
            // usa debug key normal
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
        release {
            signingConfig = signingConfigs.getByName("release")
            // desligado por enquanto (liga só na Play Store)
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.5.1"))
}
