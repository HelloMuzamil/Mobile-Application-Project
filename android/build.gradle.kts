buildscript {

    val kotlinVersion = "1.9.22"

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.1.4")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
        classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = file("../build")

subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
