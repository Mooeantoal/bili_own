# ===================================================================
# R8 / ProGuard 规则
# ===================================================================

# --- 通用库规则 ---

# 保留 OkHttp3 需要的注解类
-keep class javax.annotation.** { *; }
-keep class org.conscrypt.** { *; }

# 保留 Google Play Core 库的类，用于 Play Feature Delivery 和 Play Asset Delivery
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# --- Flutter 相关规则 ---

# 保留 Flutter 引擎和插件相关的类，防止被过度混淆
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class androidx.lifecycle.** { *; }

# 如果您的项目使用了 Kotlin，添加以下规则以保留 Kotlin 元数据
-keep class kotlin.** { *; }
-keep class kotlinx.coroutines.** { *; }

# --- 防止警告 ---

# 忽略找不到的类和引用的警告，避免构建中断
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn com.google.android.play.core.**
