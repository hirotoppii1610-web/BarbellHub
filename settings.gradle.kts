pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    // ▼▼▼ この重要な一行が、以前の私のコードから抜けていました ▼▼▼
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
    
    id("com.android.application") version "8.4.1" apply false
    id("org.jetbrains.kotlin.android") version "1.9.23" apply false
}

include(":app")

apply(from = "Flutter/ephemeral.settings.gradle.kts")