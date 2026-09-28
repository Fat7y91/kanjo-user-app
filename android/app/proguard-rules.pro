# ============================================
# Flutter Wrapper
# ============================================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# Flutter embedding
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.common.** { *; }

# ============================================
-keep class dev.fluttercommunity.** { *; }
-keep class io.flutter.plugins.** { *; }

# ============================================
# Firebase Rules
# ============================================
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class io.flutter.plugins.firebase.** { *; }
-keep class io.flutter.plugins.firebase.core.** { *; }
-keep class io.flutter.plugins.firebase.firestore.** { *; }
-keep class io.flutter.plugins.firebase.messaging.** { *; }
-keep class io.flutter.plugins.firebase.storage.** { *; }
-keep class io.flutter.plugins.firebase.crashlytics.** { *; }
-keep class io.flutter.plugins.firebase.analytics.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
-dontwarn io.flutter.plugins.firebase.**

# Firebase Crashlytics
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class com.google.firebase.crashlytics.** { *; }
-dontwarn com.google.firebase.crashlytics.**

# ============================================
# Gson (for JSON serialization)
# ============================================
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# ============================================
# Kotlin
# ============================================
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}
-keepclassmembers class kotlin.reflect.jvm.internal.** {
    <methods>;
}
-dontwarn kotlin.reflect.jvm.internal.**

# ============================================
# HTTP Clients (Dio, OkHttp, Okio)
# ============================================
-keep class dio.** { *; }
-dontwarn dio.**
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-keep class okio.** { *; }
-dontwarn okio.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# ============================================
# Retrofit (if used)
# ============================================
-keepattributes Signature, InnerClasses, EnclosingMethod
-keepattributes RuntimeVisibleAnnotations, RuntimeVisibleParameterAnnotations
-keepclassmembers,allowshrinking,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement
-dontwarn javax.annotation.**
-dontwarn kotlin.Unit
-dontwarn retrofit2.KotlinExtensions
-dontwarn retrofit2.KotlinExtensions$*

# ============================================
# Google Maps & Location
# ============================================
-keep class com.google.android.gms.maps.** { *; }
-keep class com.google.android.gms.location.** { *; }
-keep class com.lyokone.location.** { *; }
-dontwarn com.google.android.gms.**
-dontwarn com.lyokone.location.**
-keep class com.google.maps.android.** { *; }
-keep class io.flutter.plugins.googlemaps.** { *; }
-dontwarn io.flutter.plugins.googlemaps.**

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Play Core (deferred components / install referrer)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Lottie
-keep class com.airbnb.lottie.** { *; }
-dontwarn com.airbnb.lottie.**

# GetStorage / Hive-like MMKV alternatives
-keep class com.flutter.getx.** { *; }

# Image picker
-keep class io.flutter.plugins.imagepicker.** { *; }
-dontwarn io.flutter.plugins.imagepicker.**

# ============================================
# Image & File Handling
# ============================================
-keep class com.baseflow.permissionhandler.** { *; }
-keep class com.yalantis.ucrop.** { *; }
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-keep class com.fluttercandies.extended_image.** { *; }
-keep class io.flutter.plugins.photoview.** { *; }
-dontwarn com.yalantis.ucrop.**
-dontwarn com.mr.flutter.plugin.filepicker.**
-dontwarn com.fluttercandies.extended_image.**
-dontwarn io.flutter.plugins.photoview.**

# ============================================
# Permission Handler
# ============================================
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# ============================================
# State Management (Riverpod, GetX)
# ============================================
-keep class io.flutter.plugins.riverpod.** { *; }
-keep class * extends io.flutter.plugins.riverpod.** { *; }
-keep class com.github.jonataslaw.** { *; }
-dontwarn com.github.jonataslaw.**

# ============================================
# Storage & Database
# ============================================
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**
-keep class com.tekartik.sqfliteflutter.** { *; }
-dontwarn com.tekartik.sqfliteflutter.**

# ============================================
# WebView
# ============================================
-keep class io.flutter.plugins.webviewflutter.** { *; }
-dontwarn io.flutter.plugins.webviewflutter.**

# ============================================
# Share & URL Launcher
# ============================================
-keep class dev.fluttercommunity.plus.share.** { *; }
-keep class dev.fluttercommunity.plus.launcher.** { *; }
-dontwarn dev.fluttercommunity.plus.share.**
-dontwarn dev.fluttercommunity.plus.launcher.**

# ============================================
# HTML Editor
# ============================================
-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }
-dontwarn com.pichillilorenzo.flutter_inappwebview.**

# ============================================
# Story View
# ============================================
-keep class com.bluechilli.flutterstoryview.** { *; }
-dontwarn com.bluechilli.flutterstoryview.**

# ============================================
# Local Auth (Biometric)
# ============================================
-keep class io.flutter.plugins.localauth.** { *; }
-dontwarn io.flutter.plugins.localauth.**

# ============================================
# Geocoding
# ============================================
-keep class com.baseflow.geocoding.** { *; }
-dontwarn com.baseflow.geocoding.**

# ============================================
# Country Picker
# ============================================
-keep class com.joshuadeguzman.country_picker.** { *; }
-dontwarn com.joshuadeguzman.country_picker.**

# ============================================
# Connectivity Plus
# ============================================
-keep class dev.fluttercommunity.plus.connectivity.** { *; }
-dontwarn dev.fluttercommunity.plus.connectivity.**

# ============================================
# Path Provider
# ============================================
-keep class io.flutter.plugins.pathprovider.** { *; }
-dontwarn io.flutter.plugins.pathprovider.**

# ============================================
# Package Info Plus
# ============================================
-keep class dev.fluttercommunity.plus.packageinfo.** { *; }
-dontwarn dev.fluttercommunity.plus.packageinfo.**

# ============================================
# Native Methods
# ============================================
-keepclasseswithmembernames class * {
    native <methods>;
}

# ============================================
# Parcelable Implementations
# ============================================
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# ============================================
# Serializable Classes
# ============================================
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ============================================
# R Classes
# ============================================
-keepclassmembers class **.R$* {
    public static <fields>;
}

# ============================================
# Application Package Classes
# ============================================
-keep class com.qeema.kingo.** { *; }
-keep class com.qeema.kingo.user.** { *; }

# ============================================
# Android Support & AndroidX
# ============================================
-keep class android.support.** { *; }
-keep class androidx.** { *; }
-dontwarn android.support.**
-dontwarn androidx.**

# ============================================
# View Classes
# ============================================
-keepclassmembers public class * extends android.view.View {
    void set*(***);
    *** get*();
}

-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}

-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# ============================================
# Activity Classes
# ============================================
-keepclassmembers class * extends android.app.Activity {
    public void *(android.view.View);
}

-keep public class * extends android.app.Application
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# ============================================
# Enumeration Classes
# ============================================
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ============================================
# JavaScript Interface
# ============================================
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# ============================================
# Annotations
# ============================================
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes AnnotationDefault
-keep @androidx.annotation.Keep class *
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}

# ============================================
# Crash Reporting
# ============================================
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ============================================
# Remove Logging in Release (reduces size + security)
# ============================================
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

# ============================================
# Suppress Warnings for Optional Dependencies
# ============================================
-dontwarn javax.**
-dontwarn org.w3c.dom.**
-dontwarn org.xml.sax.**
-dontwarn org.apache.commons.**
-dontwarn org.apache.http.**
-dontwarn org.apache.logging.**
-dontwarn org.slf4j.**

# Keep XML-related classes that might be referenced
-keep class javax.xml.** { *; }
-keep class org.w3c.dom.** { *; }
-keep class org.xml.sax.** { *; }
