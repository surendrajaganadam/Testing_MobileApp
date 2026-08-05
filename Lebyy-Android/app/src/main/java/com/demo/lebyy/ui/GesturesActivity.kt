package com.demo.lebyy.ui

import android.os.Bundle
import android.os.SystemClock
import android.view.GestureDetector
import android.view.MotionEvent
import android.view.ScaleGestureDetector
import android.widget.PopupMenu
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.GestureDetectorCompat
import com.demo.lebyy.databinding.ActivityGesturesBinding

class GesturesActivity : AppCompatActivity() {
    private lateinit var binding: ActivityGesturesBinding
    private var multiTapCount = 0
    private var scaleFactor = 1f

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

        binding.dragItem.setOnTouchListener { view, event ->
            when (event.actionMasked) {
                MotionEvent.ACTION_MOVE -> {
                    view.translationX = event.rawX - binding.dropTarget.width / 2f
                    view.translationY = event.rawY - binding.dropTarget.top - view.height
                    true
                }
                MotionEvent.ACTION_UP -> {
                    val inTarget = event.rawY > binding.dropTarget.top &&
                        event.rawY < binding.dropTarget.bottom
                    if (inTarget) {
                        binding.dropLabel.text = "Dropped!"
                        binding.dropLabel.contentDescription = "Dropped"
                        binding.gestureResult.text = "Result: Drag Dropped"
                    } else {
                        binding.gestureResult.text = "Result: Drag Missed"
                    }
                    view.animate().translationX(0f).translationY(0f).start()
                    true
                }
                else -> true
            }
        }
        binding.resetDragDrop.setOnClickListener {
            binding.dropLabel.text = "Drop here"
            binding.dropLabel.contentDescription = "Drop here"
            binding.dragItem.translationX = 0f
            binding.dragItem.translationY = 0f
            binding.gestureResult.text = "Result: —"
        }

        val scaleDetector = ScaleGestureDetector(
            this,
            object : ScaleGestureDetector.SimpleOnScaleGestureListener() {
                override fun onScale(detector: ScaleGestureDetector): Boolean {
                    scaleFactor = (scaleFactor * detector.scaleFactor).coerceIn(0.5f, 3f)
                    binding.pinchImage.scaleX = scaleFactor
                    binding.pinchImage.scaleY = scaleFactor
                    binding.pinchValue.text = "Zoom: ${"%.2f".format(scaleFactor)}x"
                    binding.gestureResult.text = "Result: Pinch ${"%.2f".format(scaleFactor)}x"
                    return true
                }
            },
        )
        binding.pinchImage.setOnTouchListener { _, event ->
            scaleDetector.onTouchEvent(event)
            true
        }
        binding.resetPinch.setOnClickListener {
            scaleFactor = 1f
            binding.pinchImage.scaleX = 1f
            binding.pinchImage.scaleY = 1f
            binding.pinchValue.text = "Zoom: 1.00x"
            binding.gestureResult.text = "Result: Pinch reset"
        }

        binding.multiTouch.setOnTouchListener { _, event ->
            if (event.pointerCount >= 2 && event.actionMasked == MotionEvent.ACTION_POINTER_DOWN) {
                multiTapCount++
                binding.gestureResult.text = "Result: Multi-touch $multiTapCount"
            }
            true
        }
        binding.simulateMultiTouch.setOnClickListener {
            multiTapCount++
            binding.gestureResult.text = "Result: Multi-touch $multiTapCount"
        }

        binding.contextMenuTarget.setOnLongClickListener {
            PopupMenu(this, binding.contextMenuTarget).apply {
                menu.add(0, 1, 0, "Copy")
                menu.add(0, 2, 1, "Share")
                menu.add(0, 3, 2, "Delete")
                setOnMenuItemClickListener { item ->
                    binding.gestureResult.text = when (item.itemId) {
                        1 -> "Result: Context Copy"
                        2 -> "Result: Context Share"
                        else -> "Result: Context Delete"
                    }
                    true
                }
                show()
            }
            true
        }
    }
}
