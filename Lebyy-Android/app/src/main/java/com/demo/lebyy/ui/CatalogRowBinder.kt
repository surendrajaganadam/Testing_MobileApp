package com.demo.lebyy.ui

import android.view.View
import com.demo.lebyy.databinding.ItemComponentBinding

/** Wires catalog/hub rows so Accessibility Inspector sees title + subtitle text separately. */
object CatalogRowBinder {
    fun bind(
        binding: ItemComponentBinding,
        title: String,
        subtitle: String,
        accessibilityId: String,
        onOpen: () -> Unit,
    ) {
        binding.componentTitle.text = title
        binding.componentSubtitle.text = subtitle

        // Human-readable a11y names come from the visible text, not test-* ids.
        binding.root.contentDescription = null
        binding.componentTitle.contentDescription = null
        binding.componentSubtitle.contentDescription = null
        binding.componentA11yId.contentDescription = accessibilityId

        val open = View.OnClickListener { onOpen() }
        binding.root.setOnClickListener(open)
        binding.componentTitle.setOnClickListener(open)
        binding.componentSubtitle.setOnClickListener(open)
        binding.componentA11yId.setOnClickListener(open)
    }
}
