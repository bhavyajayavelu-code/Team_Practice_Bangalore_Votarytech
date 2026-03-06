// Top-level Gradle file (Kotlin DSL)
/*plugins {
    id("com.android.application") version "8.9.1" apply false
    id("com.android.library") version "8.9.1" apply false
    kotlin("android") version "1.9.10" apply false
    id("com.google.gms.google-services") version "4.4.0" apply false // use 4.4.0 instead of 4.4.15
}*/
plugins {
    id("com.android.application") version "8.3.2" apply false
    id("com.android.library") version "8.3.2" apply false
    kotlin("android") version "1.9.22" apply false
    id("com.google.gms.google-services") version "4.4.0" apply false
}


allprojects {
    repositories {
        google()      // must include this
        mavenCentral()
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
