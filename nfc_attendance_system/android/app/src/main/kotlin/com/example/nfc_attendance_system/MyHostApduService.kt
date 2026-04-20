package com.example.nfc_attendance_system

import android.content.Context
import android.nfc.cardemulation.HostApduService
import android.os.Bundle

class MyHostApduService : HostApduService() {

    private val OK = byteArrayOf(0x90.toByte(), 0x00.toByte())

    override fun processCommandApdu(commandApdu: ByteArray?, extras: Bundle?): ByteArray {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        val studentId = prefs.getString("flutter.studentId", "") ?: ""
        val bioVerified = prefs.getBoolean("flutter.bio_verified", false)
        val bioTimeInt = prefs.getLong("flutter.bio_time", 0L)
        val currentTime = System.currentTimeMillis()

        val isValid = bioVerified && (currentTime - bioTimeInt <= 15000)

        return if (isValid && studentId.isNotEmpty()) {
            prefs.edit().putBoolean("flutter.bio_verified", false).apply()
            studentId.toByteArray(Charsets.UTF_8) + OK
        } else {
            "ACCESS_DENIED".toByteArray(Charsets.UTF_8) + OK
        }
    }

    override fun onDeactivated(reason: Int) {
        // NFC link lost
    }
}