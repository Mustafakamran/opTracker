# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# MediaPipe
-keep class com.google.mediapipe.** { *; }
-dontwarn com.google.mediapipe.**

# Google Sign In
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Kotlin coroutines
-dontwarn kotlinx.coroutines.**
