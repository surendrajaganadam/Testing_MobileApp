import XCTest

class HomePage {
    
    private let app: XCUIApplication

    init(app: XCUIApplication) {
           self.app = app
       }

    
    
    private var loginBtn: XCUIElement {
        app.buttons["Account"]
    }
    
    func loginApp() {
        loginBtn.tap()
    }
}
