package com.lebyy.app.data

import com.lebyy.app.R

data class Product(
    val id: String,
    val name: String,
    val price: Double,
    val description: String,
    val imageRes: Int,
)

data class CartLine(
    val product: Product,
    var quantity: Int,
) {
    val lineTotal: Double get() = product.price * quantity
}

object Catalog {
    val products = listOf(
        Product(
            id = "c1",
            name = "Playwright Mastery",
            price = 19.99,
            description = "End-to-end web automation with Playwright — real projects, locators, and CI pipelines.",
            imageRes = R.drawable.course_1,
        ),
        Product(
            id = "c2",
            name = "Appium Mobile Testing",
            price = 24.99,
            description = "Android & iOS automation with Appium — gestures, hybrid apps, and device farms.",
            imageRes = R.drawable.course_2,
        ),
        Product(
            id = "c3",
            name = "API Testing Bootcamp",
            price = 14.99,
            description = "REST API testing with assertions, auth flows, and contract checks.",
            imageRes = R.drawable.course_3,
        ),
        Product(
            id = "c4",
            name = "Selenium WebDriver",
            price = 17.99,
            description = "Classic browser automation foundations with Selenium WebDriver.",
            imageRes = R.drawable.course_4,
        ),
        Product(
            id = "c5",
            name = "CI/CD for QA",
            price = 12.99,
            description = "Wire tests into pipelines — GitHub Actions, reporting, and flake control.",
            imageRes = R.drawable.course_5,
        ),
        Product(
            id = "c6",
            name = "Mobilewright Essentials",
            price = 21.99,
            description = "Native mobile UI automation with Mobilewright — locators, waits, and E2E flows.",
            imageRes = R.drawable.course_6,
        ),
    )

    fun byId(id: String): Product? = products.find { it.id == id }
}
