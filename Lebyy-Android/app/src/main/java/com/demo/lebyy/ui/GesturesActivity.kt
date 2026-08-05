package com.demo.lebyy.ui

import android.os.Bundle
import android.view.GestureDetector
import android.view.MotionEvent
import android.view.ScaleGestureDetector
import androidx.activity.OnBackPressedCallback
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.graphics.ColorUtils
import androidx.core.view.GestureDetectorCompat
import androidx.core.view.isVisible
import com.demo.lebyy.R
import com.demo.lebyy.databinding.ActivityGesturesBinding
import kotlin.math.abs
import kotlin.math.max

class GesturesActivity : AppCompatActivity() {
    private lateinit var binding: ActivityGesturesBinding
    private var multiTapCount = 0
    private var scaleFactor = 1f
    private val contextMenuBackCallback = object : OnBackPressedCallback(false) {
        override fun handleOnBackPressed() {
            hideContextMenu()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityGesturesBinding.inflate(layoutInflater)
        setContentView(binding.root)
        DrawerHelper.setup(this, binding.drawerLayout, binding.navigationView, binding.toolbar, "gestures")

        setupLongPress()
        setupDoubleTap()
        setupDragAndDrop()
        setupPinch()
        setupMultiTouch()
        setupContextMenu()
    }

    private fun setupLongPress() {
        binding.longPressTarget.setOnLongClickListener {
            binding.gestureResult.text = "Result: Long Pressed"
            true
        }
    }

    private fun setupDoubleTap() {
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
        binding.doubleTapTarget.setOnTouchListener { _, event ->
            detector.onTouchEvent(event)
            true
        }
    }

    private fun setupDragAndDrop() {
        // iOS accepts a drop when the translation stays inside ±120 x ±80 of the start point.
        val toleranceX = 120 * resources.displayMetrics.density
        val toleranceY = 80 * resources.displayMetrics.density
        var startX = 0f
        var startY = 0f

        binding.dragItem.setOnTouchListener { view, event ->
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    startX = event.rawX
                    startY = event.rawY
                }
                MotionEvent.ACTION_MOVE -> {
                    view.translationX = event.rawX - startX
                    view.translationY = event.rawY - startY
                }
                MotionEvent.ACTION_UP -> {
                    val dx = abs(event.rawX - startX)
                    val dy = abs(event.rawY - startY)
                    setDropped(dx < toleranceX && dy < toleranceY)
                    view.animate().translationX(0f).translationY(0f).setDuration(180).start()
                }
                MotionEvent.ACTION_CANCEL -> {
                    view.animate().translationX(0f).translationY(0f).setDuration(180).start()
                }
            }
            true
        }

        binding.resetDragDrop.setOnClickListener {
            resetDropTarget()
            binding.dragItem.translationX = 0f
            binding.dragItem.translationY = 0f
            binding.gestureResult.text = "Result: —"
        }
    }

    private fun setDropped(dropped: Boolean) {
        if (dropped) {
            binding.dropLabel.text = "Dropped!"
            binding.dropLabel.contentDescription = "Dropped"
            binding.dropTarget.setBackgroundColor(
                ColorUtils.setAlphaComponent(ContextCompat.getColor(this, R.color.lebyy_success), 77),
            )
            binding.gestureResult.text = "Result: Drag Dropped"
        } else {
            resetDropTarget()
            binding.gestureResult.text = "Result: Drag Missed"
        }
    }

    private fun resetDropTarget() {
        binding.dropLabel.text = "Drop here"
        binding.dropLabel.contentDescription = "Drop here"
        binding.dropTarget.setBackgroundColor(ContextCompat.getColor(this, R.color.lebyy_surface))
    }

    private fun setupPinch() {
        val scaleDetector = ScaleGestureDetector(
            this,
            object : ScaleGestureDetector.SimpleOnScaleGestureListener() {
                override fun onScale(detector: ScaleGestureDetector): Boolean {
                    scaleFactor = (scaleFactor * detector.scaleFactor).coerceIn(0.5f, 3f)
                    binding.pinchImage.scaleX = scaleFactor
                    binding.pinchImage.scaleY = scaleFactor
                    binding.pinchValue.text = "Zoom: ${"%.2f".format(scaleFactor)}x"
                    return true
                }

                override fun onScaleEnd(detector: ScaleGestureDetector) {
                    binding.gestureResult.text = "Result: Pinch ${"%.2f".format(scaleFactor)}x"
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
    }

    private fun setupMultiTouch() {
        // Count a finished two-finger tap, mirroring the iOS UITapGestureRecognizer.
        var maxPointers = 0
        binding.multiTouch.setOnTouchListener { _, event ->
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> maxPointers = 1
                MotionEvent.ACTION_POINTER_DOWN -> maxPointers = max(maxPointers, event.pointerCount)
                MotionEvent.ACTION_UP -> {
                    if (maxPointers >= 2) registerMultiTouch()
                    maxPointers = 0
                }
                MotionEvent.ACTION_CANCEL -> maxPointers = 0
            }
            true
        }
        binding.simulateMultiTouch.setOnClickListener { registerMultiTouch() }
    }

    private fun registerMultiTouch() {
        multiTapCount++
        binding.gestureResult.text = "Result: Multi-touch $multiTapCount"
    }

    private fun setupContextMenu() {
        onBackPressedDispatcher.addCallback(this, contextMenuBackCallback)
        binding.contextMenuTarget.setOnLongClickListener {
            showContextMenu()
            true
        }
        binding.contextMenuScrim.setOnClickListener { hideContextMenu() }
        binding.contextCopy.setOnClickListener { pickContextAction("Copy") }
        binding.contextShare.setOnClickListener { pickContextAction("Share") }
        binding.contextDelete.setOnClickListener { pickContextAction("Delete") }
    }

    private fun pickContextAction(action: String) {
        binding.gestureResult.text = "Result: Context $action"
        hideContextMenu()
    }

    private fun showContextMenu() {
        binding.contextMenuScrim.isVisible = true
        contextMenuBackCallback.isEnabled = true
    }

    private fun hideContextMenu() {
        binding.contextMenuScrim.isVisible = false
        contextMenuBackCallback.isEnabled = false
    }
}
