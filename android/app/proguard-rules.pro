# ── Google Maps ───────────────────────────────────────────────────────────────
# google_maps_flutter uses reflection to load the Maps SDK bridge. Without
# these rules R8 strips the bridge classes and the map view crashes on release.
-keep class com.google.android.gms.maps.** { *; }
-keep class com.google.maps.android.** { *; }
-keep class com.google.android.gms.common.** { *; }

# ── Google Sign-In ────────────────────────────────────────────────────────────
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.signin.** { *; }

# ── Firebase ──────────────────────────────────────────────────────────────────
# Firebase AAR files ship their own consumer ProGuard rules, but keeping the
# top-level package prevents any edge-case stripping during minification.
-keep class com.google.firebase.** { *; }

# ── Flutter plugin host ───────────────────────────────────────────────────────
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ── Flutter deferred components (Play Core split install) ─────────────────────
# Flutter engine references Play Core split install APIs for deferred component
# support. Since this app doesn't use Play Store dynamic delivery these classes
# are absent; suppress R8 missing-class errors rather than adding the full dep.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# ── Suppress transitive warnings from GMS / Firebase ─────────────────────────
-dontwarn com.google.android.gms.**
-dontwarn com.google.firebase.**
