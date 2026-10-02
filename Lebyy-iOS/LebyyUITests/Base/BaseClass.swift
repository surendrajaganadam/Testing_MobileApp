import XCTest

class BaseClass: XCTestCase {
    
    public let app = XCUIApplication()
    
    override func setUp() {

        app.launch()
    }
    
    override func tearDown() {
        app.terminate()
    }
}
