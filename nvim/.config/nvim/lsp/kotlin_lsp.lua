-- JetBrains' official Kotlin LSP (pre-alpha), built on the IntelliJ Kotlin
-- resolver. Used instead of kotlin-language-server (fwcd) because that one
-- can't resolve Android Gradle Plugin dependencies (android.*, androidx.*,
-- and similar), which makes it useless for react-native/Expo native modules.
return {
  cmd = { "intellij-server", "--stdio" },
  filetypes = { "kotlin" },
  root_markers = {
    "settings.gradle",
    "settings.gradle.kts",
    "build.gradle",
    "build.gradle.kts",
    "pom.xml",
    ".git",
  },
}
