package com.example.dicoding_flutter_intermediate

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val isPaid = BuildConfig.IS_PAID_VERSION

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "my_channel/config"
        ).setMethodCallHandler { call, result ->
            if (call.method == "getPaidVersionStatus") {
                result.success(isPaid)
            } else {
                result.notImplemented()
            }
        }
    }
}
