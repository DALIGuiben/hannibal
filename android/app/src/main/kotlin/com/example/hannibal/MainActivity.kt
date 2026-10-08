package com.example.hannibal

import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "hannibal/instagram_story")
            .setMethodCallHandler { call, result ->
                if (call.method != "shareStory") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val png = call.argument<ByteArray>("png")
                if (png == null || png.isEmpty()) {
                    result.error("EMPTY_IMAGE", "The Story image is empty.", null)
                    return@setMethodCallHandler
                }

                try {
                    // FileProvider gives Instagram temporary read access to our cache file.
                    val folder = File(cacheDir, "story_share").apply { mkdirs() }
                    val image = File(folder, "hannibal_wrapped.png").apply { writeBytes(png) }
                    val uri = FileProvider.getUriForFile(
                        this,
                        "${applicationContext.packageName}.story_file_provider",
                        image,
                    )
                    val intent = Intent("com.instagram.share.ADD_TO_STORY").apply {
                        setPackage("com.instagram.android")
                        setDataAndType(uri, "image/png")
                        putExtra("background_asset_uri", uri)
                        call.argument<String>("appId")?.takeIf { it.isNotBlank() }?.let {
                            putExtra("source_application", it)
                        }
                        clipData = ClipData.newRawUri("hannibal_wrapped", uri)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    }
                    startActivity(intent)
                    result.success("opened")
                } catch (_: ActivityNotFoundException) {
                    result.success("not_installed")
                } catch (error: Exception) {
                    result.error("STORY_SHARE_FAILED", error.message, null)
                }
            }
    }
}
