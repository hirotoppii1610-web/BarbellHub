plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

fun localProperties(): java.util.Properties {
    val properties = java.util.Properties()
    val localPropertiesFile = project.rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        properties.load(java.io.FileInputStream(localPropertiesFile))
    }
    return properties
}

val flutterVersionCode: String by localProperties()
val flutterVersionName: String by localProperties()

android {
    namespace = "com.example.muscle_one" // あなたのアプリのパッケージ名
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.muscle_one" // あなたのアプリのパッケージ名
        minSdk = 21
        targetSdk = 34
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }

    buildTypes {
        release {
            isSigningReady = false
        }
    }
}

flutter {
    source = "../.."
}