package com.demo.lebyy

import android.app.Application
import android.webkit.WebView

class LebyyApp : Application() {
    override fun onCreate() {
        super.onCreate()
        // Required for MobileWright / Chrome DevTools webview injection on debug builds
        WebView.setWebContentsDebuggingEnabled(true)
    }
}
