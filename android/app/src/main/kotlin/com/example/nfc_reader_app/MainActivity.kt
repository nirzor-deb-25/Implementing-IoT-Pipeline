package com.example.nfc_reader_app

import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.IsoDep
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.nio.charset.Charset

class MainActivity : FlutterActivity(), NfcAdapter.ReaderCallback {

    private val CHANNEL = "nfc_reader_channel"
    private var methodChannel: MethodChannel? = null
    private var nfcAdapter: NfcAdapter? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )

        nfcAdapter = NfcAdapter.getDefaultAdapter(this)
    }

    override fun onResume() {
        super.onResume()

        nfcAdapter?.enableReaderMode(
            this,
            this,
            NfcAdapter.FLAG_READER_NFC_A or
                    NfcAdapter.FLAG_READER_NFC_B or
                    NfcAdapter.FLAG_READER_SKIP_NDEF_CHECK,
            null
        )
    }

    override fun onPause() {
        super.onPause()
        nfcAdapter?.disableReaderMode(this)
    }

    override fun onTagDiscovered(tag: Tag?) {
        if (tag == null) {
            runOnUiThread {
                methodChannel?.invokeMethod("onNfcError", "No NFC tag found")
            }
            return
        }

        val isoDep = IsoDep.get(tag)

        if (isoDep == null) {
            runOnUiThread {
                methodChannel?.invokeMethod("onNfcError", "IsoDep not supported")
            }
            return
        }

        try {
            isoDep.connect()

            val selectAidCommand = byteArrayOf(
                0x00.toByte(),
                0xA4.toByte(),
                0x04.toByte(),
                0x00.toByte(),
                0x07.toByte(),
                0xF0.toByte(),
                0x39.toByte(),
                0x41.toByte(),
                0x48.toByte(),
                0x14.toByte(),
                0x81.toByte(),
                0x00.toByte()
            )

            val response = isoDep.transceive(selectAidCommand)

            val cleanResponse = if (response.size >= 2) {
                response.copyOfRange(0, response.size - 2)
            } else {
                response
            }

            val studentId = String(cleanResponse, Charset.forName("UTF-8"))

            isoDep.close()

            runOnUiThread {
                methodChannel?.invokeMethod("onStudentIdRead", studentId)
            }
        } catch (e: Exception) {
            try {
                isoDep.close()
            } catch (_: Exception) {
            }

            runOnUiThread {
                methodChannel?.invokeMethod(
                    "onNfcError",
                    e.message ?: "Unknown NFC error"
                )
            }
        }
    }
}