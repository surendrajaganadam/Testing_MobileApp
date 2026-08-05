package com.demo.lebyy.ui

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.demo.lebyy.databinding.ActivityAlertsBinding
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.android.material.button.MaterialButton
import com.google.android.material.dialog.MaterialAlertDialogBuilder

class AlertsActivity : AppCompatActivity() {
    private lateinit var binding: ActivityAlertsBinding
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityAlertsBinding.inflate(layoutInflater)
        setContentView(binding.root)
        DrawerHelper.setup(this, binding.drawerLayout, binding.navigationView, binding.toolbar, "alerts")

        binding.buttonSimpleAlert.setOnClickListener {
            MaterialAlertDialogBuilder(this)
                .setTitle("Alert")
                .setMessage("This is a simple Lebyy alert")
                .setPositiveButton("OK") { _, _ ->
                    binding.alertResult.text = "Result: Alert OK"
                }
                .show()
        }

        binding.buttonConfirmAlert.setOnClickListener {
            MaterialAlertDialogBuilder(this)
                .setTitle("Confirm")
                .setMessage("Do you want to continue?")
                .setPositiveButton("OK") { _, _ ->
                    binding.alertResult.text = "Result: Confirm OK"
                }
                .setNegativeButton("CANCEL") { _, _ ->
                    binding.alertResult.text = "Result: Confirm CANCEL"
                }
                .show()
        }

        binding.buttonPromptAlert.setOnClickListener {
            val input = EditText(this).apply {
                hint = "Enter text"
                contentDescription = "test-PromptInput"
                setTextColor(0xFF0F2144.toInt())
                setHintTextColor(0xFF6B7F99.toInt())
                setPadding(48, 32, 48, 32)
            }
            MaterialAlertDialogBuilder(this)
                .setTitle("Prompt")
                .setMessage("Please type something")
                .setView(input)
                .setPositiveButton("OK") { _, _ ->
                    binding.alertResult.text = "Result: Prompt ${input.text}"
                }
                .setNegativeButton("CANCEL") { _, _ ->
                    binding.alertResult.text = "Result: Prompt CANCEL"
                }
                .show()
        }

        binding.buttonCustomModal.setOnClickListener {
            val dialog = MaterialAlertDialogBuilder(this)
                .setTitle("Custom Modal")
                .setMessage("Not a system alert — custom overlay")
                .setPositiveButton("OK") { _, _ ->
                    binding.alertResult.text = "Result: Modal OK"
                }
                .setNegativeButton("Cancel") { _, _ ->
                    binding.alertResult.text = "Result: Modal Cancel"
                }
                .create()
            dialog.setOnShowListener {
                dialog.getButton(android.app.AlertDialog.BUTTON_POSITIVE)?.contentDescription = "test-ModalOK"
                dialog.getButton(android.app.AlertDialog.BUTTON_NEGATIVE)?.contentDescription = "test-ModalCancel"
            }
            dialog.show()
        }

        binding.buttonBottomSheet.setOnClickListener {
            val dialog = BottomSheetDialog(this)
            val sheet = android.widget.LinearLayout(this).apply {
                orientation = android.widget.LinearLayout.VERTICAL
                setPadding(48, 48, 48, 48)
                contentDescription = "test-BottomSheetContent"
                addView(android.widget.TextView(this@AlertsActivity).apply {
                    text = "Bottom Sheet"
                    textSize = 20f
                    contentDescription = "test-BottomSheetTitle"
                    setTextColor(0xFF42C6FF.toInt())
                })
                addView(MaterialButton(this@AlertsActivity).apply {
                    text = "Confirm Sheet"
                    contentDescription = "test-BottomSheetConfirm"
                    setOnClickListener {
                        binding.alertResult.text = "Result: Bottom Sheet Confirm"
                        dialog.dismiss()
                    }
                })
                addView(MaterialButton(this@AlertsActivity).apply {
                    text = "Dismiss Sheet"
                    contentDescription = "test-BottomSheetDismiss"
                    setOnClickListener {
                        binding.alertResult.text = "Result: Bottom Sheet Dismiss"
                        dialog.dismiss()
                    }
                })
            }
            dialog.setContentView(sheet)
            dialog.show()
        }

        binding.buttonToast.setOnClickListener {
            binding.toastMessage.visibility = View.VISIBLE
            binding.alertResult.text = "Result: Toast shown"
            Toast.makeText(this, "Toast: Saved successfully", Toast.LENGTH_SHORT).show()
            handler.postDelayed({ binding.toastMessage.visibility = View.GONE }, 2500)
        }
    }
}
