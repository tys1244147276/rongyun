package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.camera.CameraPlugin;
import com.mr.flutter.plugin.filepicker.FilePickerPlugin;
import com.zeno.flutter_audio_recorder.FlutterAudioRecorderPlugin;
import com.flutter.keyboardvisibility.KeyboardVisibilityPlugin;
import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin;
import com.dooboolab.fluttersound.FlutterSoundPlugin;
import com.flutter_webview_plugin.FlutterWebviewPlugin;
import io.github.ponnamkarthik.toast.fluttertoast.FluttertoastPlugin;
import com.example.imagegallerysaver.ImageGallerySaverPlugin;
import io.flutter.plugins.imagepicker.ImagePickerPlugin;
import com.crazecoder.openfile.OpenFilePlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;
import com.baseflow.permissionhandler.PermissionHandlerPlugin;
import io.rong.flutter.imlib.RongcloudImPlugin;
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;
import com.tekartik.sqflite.SqflitePlugin;
import io.flutter.plugins.videoplayer.VideoPlayerPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    CameraPlugin.registerWith(registry.registrarFor("io.flutter.plugins.camera.CameraPlugin"));
    FilePickerPlugin.registerWith(registry.registrarFor("com.mr.flutter.plugin.filepicker.FilePickerPlugin"));
    FlutterAudioRecorderPlugin.registerWith(registry.registrarFor("com.zeno.flutter_audio_recorder.FlutterAudioRecorderPlugin"));
    KeyboardVisibilityPlugin.registerWith(registry.registrarFor("com.flutter.keyboardvisibility.KeyboardVisibilityPlugin"));
    FlutterLocalNotificationsPlugin.registerWith(registry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"));
    FlutterSoundPlugin.registerWith(registry.registrarFor("com.dooboolab.fluttersound.FlutterSoundPlugin"));
    FlutterWebviewPlugin.registerWith(registry.registrarFor("com.flutter_webview_plugin.FlutterWebviewPlugin"));
    FluttertoastPlugin.registerWith(registry.registrarFor("io.github.ponnamkarthik.toast.fluttertoast.FluttertoastPlugin"));
    ImageGallerySaverPlugin.registerWith(registry.registrarFor("com.example.imagegallerysaver.ImageGallerySaverPlugin"));
    ImagePickerPlugin.registerWith(registry.registrarFor("io.flutter.plugins.imagepicker.ImagePickerPlugin"));
    OpenFilePlugin.registerWith(registry.registrarFor("com.crazecoder.openfile.OpenFilePlugin"));
    PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
    PermissionHandlerPlugin.registerWith(registry.registrarFor("com.baseflow.permissionhandler.PermissionHandlerPlugin"));
    RongcloudImPlugin.registerWith(registry.registrarFor("io.rong.flutter.imlib.RongcloudImPlugin"));
    SharedPreferencesPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));
    SqflitePlugin.registerWith(registry.registrarFor("com.tekartik.sqflite.SqflitePlugin"));
    VideoPlayerPlugin.registerWith(registry.registrarFor("io.flutter.plugins.videoplayer.VideoPlayerPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
