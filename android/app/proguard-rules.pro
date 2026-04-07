# Flutter
-keep class io.flutter.** { *; }
-keep class com.example.vcardiocare.** { *; }

# Networking
-dontwarn okhttp3.**
-dontwarn javax.annotation.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# SQLite
-keep class org.sqlite.** { *; }

# Keep all models and data classes
-keep class com.example.vcardiocare.models.** { *; }

# JSON serialization
-keepclassmembers class * {
  *** *FromJson(...);
  *** toJson(...);
}

# Preserve line numbers for debugging
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable
