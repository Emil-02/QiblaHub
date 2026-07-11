package com.qiblahub.qiblahub

import android.content.Context
import android.hardware.GeomagneticField
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.view.Surface
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlin.math.PI

class MainActivity : FlutterActivity() {

    private var sensorManager: SensorManager? = null
    private var compassListener: SensorEventListener? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── Deklinasi magnetik (World Magnetic Model) ──
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "qiblahub/geomag"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                // Deklinasi magnetik (derajat) dari World Magnetic Model.
                // Positif = utara magnetik berada di timur utara sejati.
                "declination" -> {
                    val lat = call.argument<Double>("lat")
                    val lon = call.argument<Double>("lon")
                    val alt = call.argument<Double>("alt") ?: 0.0
                    if (lat == null || lon == null) {
                        result.error("ARG", "lat/lon wajib diisi", null)
                    } else {
                        val field = GeomagneticField(
                            lat.toFloat(),
                            lon.toFloat(),
                            alt.toFloat(),
                            System.currentTimeMillis()
                        )
                        result.success(field.declination.toDouble())
                    }
                }
                else -> result.notImplemented()
            }
        }

        // ── Kompas native: sensor fusi TYPE_ROTATION_VECTOR ──
        // Gyro + akselerometer + magnetometer difusikan oleh sistem;
        // jauh lebih stabil & akurat daripada plugin kompas lama,
        // plus estimasi akurasi heading bawaan sensor.
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "qiblahub/compass"
        ).setStreamHandler(object : EventChannel.StreamHandler {

            override fun onListen(args: Any?, events: EventChannel.EventSink) {
                val sm = getSystemService(Context.SENSOR_SERVICE) as SensorManager
                sensorManager = sm

                // Cadangan bila ROTATION_VECTOR (butuh gyro) tidak ada.
                val sensor = sm.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
                    ?: sm.getDefaultSensor(Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR)

                if (sensor == null) {
                    events.error("NO_SENSOR", "Sensor rotasi tidak tersedia", null)
                    return
                }

                val rotationMatrix = FloatArray(9)
                val remapped = FloatArray(9)
                val orientation = FloatArray(3)

                var magnetometerStatus = SensorManager.SENSOR_STATUS_ACCURACY_MEDIUM

                compassListener = object : SensorEventListener {
                    override fun onSensorChanged(event: SensorEvent) {
                        if (event.sensor.type == Sensor.TYPE_MAGNETIC_FIELD) return

                        SensorManager.getRotationMatrixFromVector(rotationMatrix, event.values)

                        // Remap sumbu sesuai rotasi layar agar heading tetap
                        // benar pada orientasi apa pun.
                        val rotation =
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R)
                                display?.rotation ?: Surface.ROTATION_0
                            else
                                @Suppress("DEPRECATION")
                                windowManager.defaultDisplay.rotation
                        val (axisX, axisY) = when (rotation) {
                            Surface.ROTATION_90 ->
                                SensorManager.AXIS_Y to SensorManager.AXIS_MINUS_X
                            Surface.ROTATION_180 ->
                                SensorManager.AXIS_MINUS_X to SensorManager.AXIS_MINUS_Y
                            Surface.ROTATION_270 ->
                                SensorManager.AXIS_MINUS_Y to SensorManager.AXIS_X
                            else -> SensorManager.AXIS_X to SensorManager.AXIS_Y
                        }
                        SensorManager.remapCoordinateSystem(rotationMatrix, axisX, axisY, remapped)
                        SensorManager.getOrientation(remapped, orientation)

                        var azimuth = orientation[0] * 180.0 / PI
                        azimuth = ((azimuth % 360.0) + 360.0) % 360.0

                        // values[4] = estimasi akurasi heading (radian), -1 jika tak ada
                        val headingAccuracyDeg =
                            if (event.values.size > 4 && event.values[4] >= 0)
                                event.values[4] * 180.0 / PI
                            else -1.0

                        events.success(
                            mapOf(
                                "azimuth" to azimuth,
                                "status" to minOf(event.accuracy, magnetometerStatus),
                                "headingAccuracy" to headingAccuracyDeg
                            )
                        )
                    }

                    override fun onAccuracyChanged(s: Sensor, accuracy: Int) {
                        if (s.type == Sensor.TYPE_MAGNETIC_FIELD) {
                            magnetometerStatus = accuracy
                        }
                    }
                }

                sm.registerListener(compassListener, sensor, SensorManager.SENSOR_DELAY_GAME)
                // Magnetometer hanya untuk memantau status kalibrasi.
                sm.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)?.let {
                    sm.registerListener(compassListener, it, SensorManager.SENSOR_DELAY_UI)
                }
            }

            override fun onCancel(args: Any?) {
                compassListener?.let { sensorManager?.unregisterListener(it) }
                compassListener = null
            }
        })
    }
}
