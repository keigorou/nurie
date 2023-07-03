package com.example.nurie_3

import android.annotation.SuppressLint
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import androidx.core.content.ContextCompat.getSystemService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.opencv.android.Utils
//import org.opencv.android.BaseLoaderCallback
//import org.opencv.android.LoaderCallbackInterface
import org.opencv.android.OpenCVLoader
import org.opencv.core.Mat
import org.opencv.core.Core
import org.opencv.core.Size
import org.opencv.imgproc.Imgproc
import java.io.ByteArrayOutputStream


class MainActivity: FlutterActivity() {
    private val NURIE_CHANNEL = "nurie_3.com/nurie"
    private lateinit var channel : MethodChannel


    @SuppressLint("WrongThread")
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        if (!OpenCVLoader.initDebug()) {
            // Handle initialization error
            println("error")
        }

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NURIE_CHANNEL)
        
        channel.setMethodCallHandler { call, result ->
            val imagepath = call.arguments.toString()
            var bitmapImgSource : Bitmap = BitmapFactory.decodeFile(imagepath)

            when (call.method) {
                "image2NurieKernelSize5" -> image2Nurie(bitmapImgSource, 5.0)
                "image2NurieKernelSize3" -> image2Nurie(bitmapImgSource, 3.0)
                "image2Dilate" -> image2Dilate(bitmapImgSource)
                "noiseRemoval" -> noiseRemoval(bitmapImgSource)
                "image2Threshold" -> image2Threshold(bitmapImgSource)
            }

            var baos = ByteArrayOutputStream()
                bitmapImgSource.compress(Bitmap.CompressFormat.JPEG, 100, baos)
                var byte = baos.toByteArray()
                result.success(byte)
        }
    }

    private fun image2Nurie(bitmapImgSource: Bitmap, kernelSize: Double) {
        val matSource = Mat()
        Utils.bitmapToMat(bitmapImgSource, matSource)

        val matGray = Mat()
        Imgproc.cvtColor(matSource, matGray, Imgproc.COLOR_BGR2GRAY)

        val matDilated = Mat()
        val kernel = Imgproc.getStructuringElement(Imgproc.MORPH_RECT, Size(kernelSize, kernelSize))
        Imgproc.dilate(matGray, matDilated, kernel)

        val matDiff = Mat()
        Core.absdiff(matGray, matDilated, matDiff)
        
        val matResult = Mat()
        Core.bitwise_not(matDiff, matResult)

        Utils.matToBitmap(matResult, bitmapImgSource)
    }

    private fun image2Dilate(bitmapImgSource: Bitmap) {
        val matSource = Mat()
        Utils.bitmapToMat(bitmapImgSource, matSource)

        val matGray = Mat()
        Core.bitwise_not(matSource, matGray)

        val matDilated = Mat()
        val kernel = Imgproc.getStructuringElement(Imgproc.MORPH_RECT, Size(5.0, 5.0))
        Imgproc.dilate(matGray, matDilated, kernel)

        val matResult = Mat()
        Core.bitwise_not(matDilated, matResult)

        Utils.matToBitmap(matResult, bitmapImgSource)
    }

    private fun noiseRemoval(bitmapImgSource: Bitmap) {
        val matSource = Mat()
        Utils.bitmapToMat(bitmapImgSource, matSource)

        val matResult = Mat()
        val kernel = Imgproc.getStructuringElement(Imgproc.MORPH_RECT, Size(3.0, 3.0))
        Imgproc.morphologyEx(matSource,matResult,Imgproc.MORPH_OPEN,kernel)

        Utils.matToBitmap(matResult, bitmapImgSource)
    }

    private fun image2Threshold(bitmapImgSource: Bitmap) {
        val matSource = Mat()
        Utils.bitmapToMat(bitmapImgSource, matSource)

        val matResult = Mat()

        Imgproc.threshold(matSource, matResult, 100.0, 255.0, Imgproc.THRESH_BINARY)

        Utils.matToBitmap(matResult, bitmapImgSource)
    }

    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }
        return batteryLevel
    }
}
