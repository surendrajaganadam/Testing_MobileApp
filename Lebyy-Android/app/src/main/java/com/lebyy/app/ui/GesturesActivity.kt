package com.lebyy.app.ui

import android.os.Bundle
import android.os.SystemClock
import android.view.GestureDetector
import android.view.MotionEvent
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.GestureDetectorCompat
import com.lebyy.app.databinding.ActivityGesturesBinding

class GesturesActivity : AppCompatActivity() {
    private lateinit var binding: ActivityGesturesBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityGesturesBinding.inflate(layoutInflater)
        setContentView(binding.root)
        DrawerHelper.setup(this, binding.drawerLayout, binding.navigationView, binding.toolbar, "gestures")

        binding.longPressTarget.setOnLongClickListener {
            binding.gestureResult.text = "Result: Long Pressed"
            true
        }

        val detector = GestureDetectorCompat(
            this,
            object : GestureDetector.SimpleOnGestureListener() {
                override fun onDown(e: MotionEvent): Boolean = true

                override fun onDoubleTap(e: MotionEvent): Boolean {
                    binding.gestureResult.text = "Result: Double Tapped"
                    return true
                }
            },
        )

        var lastTap = 0L
        binding.doubleTapTarget.setOnTouchListener { _, event ->
            detector.onTouchEvent(event)
            if (event.action == MotionEvent.ACTION_UP) {
                val now = SystemClock.uptimeMillis()
                if (now - lastTap < 300) {
                    binding.gestureResult.text = "Result: Double Tapped"
                }
                lastTap = now
            }
            true
        }
    }
}
