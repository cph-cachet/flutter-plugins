package com.example.pedometer

import android.Manifest
import androidx.core.content.ContextCompat
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import com.example.pedometer.PermissionResultCallback
import android.os.Build
import android.content.Context
import android.app.Activity
import android.util.Log

class PermissionManager : RequestPermissionsResultListener {
    private val ACTIVITRY_PERMISSION: String = Manifest.permission.ACTIVITY_RECOGNITION
    private val PERMISSION_REQUEST_CODE = 1120

    private var activity: Activity? = null
    private lateinit var resultCallback: PermissionResultCallback

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResult: IntArray) : Boolean {
        val requestedPermissionIndex: Int = permissions.indexOf(ACTIVITRY_PERMISSION)
        Log.e("pedometer", "$requestCode")
        if (requestCode != PERMISSION_REQUEST_CODE || activity == null || requestedPermissionIndex < 0 || grantResult.size < requestedPermissionIndex) {
            resultCallback.onResult(false)
            return false
        }

        if (grantResult[requestedPermissionIndex] == PackageManager.PERMISSION_GRANTED) {
            resultCallback.onResult(true)
            return true
        }

        resultCallback.onResult(false)
        return false
    }

    public fun checkPermission(context: Context) : Boolean {
        val permissionStatus : Int = ContextCompat.checkSelfPermission(context, ACTIVITRY_PERMISSION);
        return permissionStatus == PackageManager.PERMISSION_GRANTED
    }

    public fun requestPermission(activity: Activity?, resultCallback: PermissionResultCallback) {
        if (activity == null) {
            resultCallback.onResult(false)
            return
        }

        /// only needed after Android API 28
        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.P) {
            resultCallback.onResult(true)
            return
        }

        this.activity = activity
        this.resultCallback = resultCallback
        val permissionsToRequest: Array<String> = Array(1) { ACTIVITRY_PERMISSION }
        ActivityCompat.requestPermissions(activity!!, permissionsToRequest, PERMISSION_REQUEST_CODE)
    }
}