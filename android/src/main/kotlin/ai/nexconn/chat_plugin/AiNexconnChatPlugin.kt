package ai.nexconn.chat_plugin

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.lang.reflect.InvocationTargetException

class AiNexconnChatPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var applicationContext: Context? = null
    private var channel: MethodChannel? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME).also {
            it.setMethodCallHandler(this)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        applicationContext = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "push:init" -> {
                if (call.argument<Boolean>("enablePush") == true) {
                    initPushPlugin()
                }
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun initPushPlugin() {
        val context = applicationContext ?: return
        try {
            val pluginClass = Class.forName("io.rong.push.RongPushPlugin")
            val initMethod = pluginClass.getMethod("init", Context::class.java)
            initMethod.invoke(null, context)
        } catch (throwable: Throwable) {
            val cause =
                if (throwable is InvocationTargetException && throwable.targetException != null) {
                    throwable.targetException
                } else {
                    throwable
                }
            Log.w(TAG, "Nexconn push plugin init failed.", cause)
        }
    }

    private companion object {
        private const val CHANNEL_NAME = "ai.nexconn.chat_plugin/native"
        private const val TAG = "AiNexconnChatPlugin"
    }
}
