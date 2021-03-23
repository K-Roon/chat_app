package io.flutter.plugins

import androidx.annotation.Keep
import com.baseflow.permissionhandler.PermissionHandlerPlugin
import com.benjaminabel.vibration.VibrationPlugin
import com.crazecoder.openfile.OpenFilePlugin
import com.example.flutterimagecompress.FlutterImageCompressPlugin
import com.mr.flutter.plugin.filepicker.FilePickerPlugin
import com.tekartik.sqflite.SqflitePlugin
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry
import io.flutter.plugins.firebase.auth.FlutterFirebaseAuthPlugin
import io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin
import io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin
import io.flutter.plugins.firebase.storage.FlutterFirebaseStoragePlugin
import io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin
import io.flutter.plugins.googlesignin.GoogleSignInPlugin
import io.flutter.plugins.pathprovider.PathProviderPlugin
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin
import it.nplace.downloadspathprovider.DownloadsPathProviderPlugin

/**
 * Generated file. Do not edit.
 * This file is generated by the Flutter tool based on the
 * plugins that support the Android platform.
 */
@Keep
object GeneratedPluginRegistrant {
    fun registerWith(flutterEngine: FlutterEngine) {
        val shimPluginRegistry = ShimPluginRegistry(flutterEngine)
        flutterEngine.plugins.add(FlutterFirebaseFirestorePlugin())
        DownloadsPathProviderPlugin.registerWith(shimPluginRegistry.registrarFor("it.nplace.downloadspathprovider.DownloadsPathProviderPlugin"))
        flutterEngine.plugins.add(FilePickerPlugin())
        flutterEngine.plugins.add(FlutterFirebaseAuthPlugin())
        flutterEngine.plugins.add(FlutterFirebaseCorePlugin())
        flutterEngine.plugins.add(FlutterFirebaseStoragePlugin())
        flutterEngine.plugins.add(FlutterImageCompressPlugin())
        flutterEngine.plugins.add(FlutterAndroidLifecyclePlugin())
        flutterEngine.plugins.add(GoogleSignInPlugin())
        flutterEngine.plugins.add(OpenFilePlugin())
        flutterEngine.plugins.add(PathProviderPlugin())
        flutterEngine.plugins.add(PermissionHandlerPlugin())
        flutterEngine.plugins.add(SharedPreferencesPlugin())
        flutterEngine.plugins.add(SqflitePlugin())
        flutterEngine.plugins.add(VibrationPlugin())
    }
}