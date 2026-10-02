//
//  LoginTest.swift
//  Lebyy
//
//  Created by Lucky on 28/08/26.
import XCTest

class LoginTest: BaseClass {
    lazy var homePage = HomePage(app: app)

    func testLoginFlow() {
        homePage.loginApp()
    }
}

