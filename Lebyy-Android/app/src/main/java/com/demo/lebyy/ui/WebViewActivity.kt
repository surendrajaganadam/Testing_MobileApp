package com.demo.lebyy.ui

import android.annotation.SuppressLint
import android.os.Bundle
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity
import com.demo.lebyy.databinding.ActivityWebviewBinding

class WebViewActivity : AppCompatActivity() {
    private lateinit var binding: ActivityWebviewBinding

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityWebviewBinding.inflate(layoutInflater)
        setContentView(binding.root)

        DrawerHelper.setup(this, binding.drawerLayout, binding.navigationView, binding.toolbar, "webview")

        WebView.setWebContentsDebuggingEnabled(true)

        binding.lebyyWebView.contentDescription = "test-WebView"
        binding.lebyyWebView.setBackgroundColor(0xFFFFFFFF.toInt())
        binding.lebyyWebView.settings.javaScriptEnabled = true
        binding.lebyyWebView.settings.domStorageEnabled = true
        binding.lebyyWebView.webViewClient = WebViewClient()
        binding.lebyyWebView.webChromeClient = WebChromeClient()

        loadStarter(withJsAlert = false)

        binding.loadJsAlertPage.setOnClickListener {
            loadStarter(withJsAlert = true)
            binding.webResult.text = "Web: JS alert page"
        }
        binding.loadStarterPage.setOnClickListener {
            loadStarter(withJsAlert = false)
            binding.webResult.text = "Web: starter"
        }

        binding.buttonGo.setOnClickListener { loadEnteredUrl() }
        binding.inputUrl.setOnEditorActionListener { _, _, _ ->
            loadEnteredUrl()
            true
        }
    }

    private fun loadStarter(withJsAlert: Boolean) {
        val alertBlock = if (withJsAlert) {
            """
            <p><button id='jsAlertBtn' onclick="alert('Lebyy JS Alert')">Show JS Alert</button></p>
            <p><button id='jsConfirmBtn' onclick="var r=confirm('Continue?'); document.getElementById('jsOut').innerText='Confirm:'+r">Show JS Confirm</button></p>
            <p id='jsOut'>JS: —</p>
            """.trimIndent()
        } else {
            """
            <p>Enter a URL above and tap <b>GO TO SITE</b>.</p>
            <p><a href="https://www.google.com" style="color:#0d6efd">Open Google</a></p>
            """.trimIndent()
        }
        binding.lebyyWebView.loadDataWithBaseURL(
            "https://lebyy.local/",
            """
            <!DOCTYPE html>
            <html>
            <head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
            <title>Lebyy WebView</title></head>
            <body style="font-family: sans-serif; padding: 16px; background:#ffffff; color:#0f2144;">
              <h1 style="color:#0d1f3a;">Lebyy</h1>
              <p style="color:#4a6080;">Learn by yourself</p>
              $alertBlock
            </body>
            </html>
            """.trimIndent(),
            "text/html",
            "UTF-8",
            null,
        )
    }

    private fun loadEnteredUrl() {
        var url = binding.inputUrl.text?.toString()?.trim().orEmpty()
        if (url.isEmpty()) return
        if (!url.startsWith("http://") && !url.startsWith("https://")) {
            url = "https://$url"
        }
        binding.lebyyWebView.loadUrl(url)
    }

    override fun onDestroy() {
        binding.lebyyWebView.destroy()
        super.onDestroy()
    }
}
