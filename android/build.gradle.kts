allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    if (project.name != "app") {
        val configureAndroid = Action<Project> {
            if (plugins.hasPlugin("com.android.library") || plugins.hasPlugin("com.android.application")) {
                val androidExt = extensions.findByName("android")
                if (androidExt != null) {
                    try {
                        // Use reflection to bypass AGP 9.0 strict type removal while still fixing older plugins
                        androidExt.javaClass.getMethod("setCompileSdkVersion", Int::class.java).invoke(androidExt, 36)
                        androidExt.javaClass.getMethod("setBuildToolsVersion", String::class.java).invoke(androidExt, "36.0.0")
                        
                        val namespace = androidExt.javaClass.getMethod("getNamespace").invoke(androidExt)
                        if (namespace == null) {
                            androidExt.javaClass.getMethod("setNamespace", String::class.java).invoke(androidExt, group.toString())
                        }
                    } catch (e: Exception) {
                        // Ignore if a modern plugin is already using the newer DSL structure
                    }
                }
            }
        }
        
        if (state.executed) {
            configureAndroid.execute(this)
        } else {
            afterEvaluate(configureAndroid)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}