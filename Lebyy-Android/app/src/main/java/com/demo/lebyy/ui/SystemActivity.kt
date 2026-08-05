package com.demo.lebyy.ui

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Intent
import android.content.pm.ActivityInfo
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import com.demo.lebyy.R
import com.demo.lebyy.data.ShopState
import com.demo.lebyy.databinding.ActivitySystemBinding
import com.google.android.material.dialog.MaterialAlertDialogBuilder

class SystemActivity : AppCompatActivity() {
    private lateinit var binding: ActivitySystemBinding

    private val pickImage = registerForActivityResult(ActivityResultContracts.GetContent()) { uri ->
        if (uri != null) {
            binding.selectedImage.text = "Selected: Picked Photo"
            binding.imagePreview.setImageURI(uri)
            binding.imagePreview.visibility = View.VISIBLE
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivitySystemBinding.inflate(layoutInflater)
        setContentView(binding.root)
        DrawerHelper.setup(this, binding.drawerLayout, binding.navigationView, binding.toolbar, "system")

        binding.permissionCamera.setOnClickListener { askPermission("Camera") }
        binding.permissionLocation.setOnClickListener { askPermission("Location") }
        binding.permissionNotifications.setOnClickListener { askPermission("Notifications") }

        binding.pickPhoto.setOnClickListener { pickImage.launch("image/*") }
        binding.useSampleImage.setOnClickListener {
            binding.selectedImage.text = "Selected: course_1"
            binding.imagePreview.setImageResource(R.drawable.course_1)
            binding.imagePreview.visibility = View.VISIBLE
        }

        binding.copyClipboard.setOnClickListener {
            val text = binding.shareText.text?.toString().orEmpty()
            val cm = getSystemService(CLIPBOARD_SERVICE) as ClipboardManager
            cm.setPrimaryClip(ClipData.newPlainText("lebyy", text))
            binding.clipboardResult.text = "Clipboard: copied"
            Toast.makeText(this, "Copied", Toast.LENGTH_SHORT).show()
        }
        binding.pasteClipboard.setOnClickListener {
            val cm = getSystemService(CLIPBOARD_SERVICE) as ClipboardManager
            val value = cm.primaryClip?.getItemAt(0)?.coerceToText(this)?.toString().orEmpty()
            binding.clipboardResult.text = "Clipboard: ${value.ifEmpty { "(empty)" }}"
        }
        binding.shareSheet.setOnClickListener {
            val send = Intent(Intent.ACTION_SEND).apply {
                type = "text/plain"
                putExtra(Intent.EXTRA_TEXT, binding.shareText.text?.toString().orEmpty())
            }
            startActivity(Intent.createChooser(send, "Share via"))
        }

        binding.forcePortrait.isChecked = ShopState.forcePortraitOnly
        renderOrientation()
        binding.forcePortrait.setOnCheckedChangeListener { _, checked ->
            ShopState.forcePortraitOnly = checked
            requestedOrientation = if (checked) {
                ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
            } else {
                ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED
            }
            renderOrientation()
        }
    }

    private fun renderOrientation() {
        if (ShopState.forcePortraitOnly) {
            binding.orientationMode.text = "Mode: Portrait locked"
            binding.orientationMode.contentDescription = "test-Orientation-Portrait"
        } else {
            binding.orientationMode.text = "Mode: All orientations"
            binding.orientationMode.contentDescription = "test-Orientation-All"
        }
    }

    private fun askPermission(name: String) {
        val dialog = MaterialAlertDialogBuilder(this)
            .setTitle("Allow $name?")
            .setMessage("Lebyy would like to access ${name.lowercase()}.")
            .setPositiveButton("Allow") { _, _ ->
                binding.permissionResult.text = "Permission: $name Allow"
            }
            .setNegativeButton("Don't Allow") { _, _ ->
                binding.permissionResult.text = "Permission: $name Deny"
            }
            .create()
        dialog.setOnShowListener {
            dialog.getButton(android.app.AlertDialog.BUTTON_POSITIVE)?.contentDescription = "test-PermissionAllow"
            dialog.getButton(android.app.AlertDialog.BUTTON_NEGATIVE)?.contentDescription = "test-PermissionDeny"
        }
        dialog.show()
    }
}
