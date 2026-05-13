import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// H1: Read secrets from local.properties (gitignored — never committed).
// To set up: add MAPS_API_KEY=<your_key> to android/local.properties.
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

android {
    namespace = "com.feddan.feddan"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications for Java 8 time APIs on older Android versions.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.feddan.feddan"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // H1: Inject Maps API key into AndroidManifest at build time.
        // The manifest references it as ${mapsApiKey}.
        manifestPlaceholders["mapsApiKey"] =
            localProperties.getProperty("MAPS_API_KEY", "")
    }

    signingConfigs {
        create("release") {
            // Keys are read from android/local.properties (gitignored).
            // Required entries:
            //   KEYSTORE_PATH=../feddan-release.keystore
            //   KEYSTORE_PASSWORD=<password>
            //   KEY_ALIAS=feddan
            //   KEY_PASSWORD=<password>
            // Generate once: keytool -genkey -v -keystore feddan-release.keystore
            //   -alias feddan -keyalg RSA -keysize 2048 -validity 10000
            val keystorePath = localProperties.getProperty("KEYSTORE_PATH", "")
            if (keystorePath.isNotEmpty()) {
                storeFile = file(keystorePath)
                storePassword = localProperties.getProperty("KEYSTORE_PASSWORD", "")
                keyAlias = localProperties.getProperty("KEY_ALIAS", "")
                keyPassword = localProperties.getProperty("KEY_PASSWORD", "")
            }
        }
    }

    buildTypes {
        release {
            val releaseConfig = signingConfigs.findByName("release")
            signingConfig = if (releaseConfig?.storeFile != null) releaseConfig
                            else signingConfigs.getByName("debug")

            // H4: Enable R8 full-mode shrinking and obfuscation for release APKs.
            // proguard-rules.pro contains keep rules for Maps, Firebase, and Sign-In.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
