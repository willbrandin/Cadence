import XCTest

class CadenceUITests: XCTestCase {
    func testFreshAppOpenAddBike() {
        
        let app = XCUIApplication()
        app.activate()
        
        if app.buttons["Ready to roll?, Let's ride."].exists {
            app.buttons["Ready to roll?, Let's ride."].tap()
        }
        
        app.toolbars["Toolbar"].buttons["Add Bike"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.buttons["Mountain"].tap()
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["YETI"]/*[[".cells[\"YETI\"].buttons[\"YETI\"]",".buttons[\"YETI\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let bikeField = app.textFields["Sync'r Carbon"]
        
        if bikeField.exists {
            bikeField.tap()
            bikeField.typeText("165c")
        }
        
        app.navigationBars["Save Bike"].buttons["Save"].tap()
        
        XCTAssert(app.scrollViews.otherElements.buttons["165c, Great"].exists)
    }
    
    func testFreshOpen_AddBike_AddComponent_AddService() {
        
        let app = XCUIApplication()
        app.activate()
        
        if app.buttons["Ready to roll?, Let's ride."].exists {
            app.buttons["Ready to roll?, Let's ride."].tap()
        }
        
        let tablesQuery = app.tables

        if !app.scrollViews.otherElements.buttons["165c, Great"].exists  {
            app.toolbars["Toolbar"].buttons["Add Bike"].tap()
            
            tablesQuery/*@START_MENU_TOKEN@*/.buttons["Road"]/*[[".cells[\"Road\"].buttons[\"Road\"]",".buttons[\"Road\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            tablesQuery/*@START_MENU_TOKEN@*/.buttons["YETI"]/*[[".cells[\"YETI\"].buttons[\"YETI\"]",".buttons[\"YETI\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            
            let bikeField = app.textFields["Sync'r Carbon"]

            if bikeField.exists {
                bikeField.tap()
                bikeField.typeText("165c")
            }
            
            app.navigationBars["Save Bike"].buttons["Save"].tap()
        }
        
        app.scrollViews.otherElements.buttons["165c, Great"].tap()
        
        if !app.scrollViews.otherElements.buttons["Rear SLX Derailleur, Shimano, SLX, 0, miles, Great"].exists {
            
            // Tap Plus
            let navigationBar = app.navigationBars["165c"]
            app.toolbars["Toolbar"].buttons["New Component"].tap()
            
            // Group
            let handlebarsButton = tablesQuery.buttons["Drivetrain"]
            handlebarsButton.tap()
            
            // Type
            tablesQuery.buttons["Derailleur"].tap()
            
            // Brand
            tablesQuery.buttons["Shimano"].tap()
            
            // Model
            let modelField = app.textFields["GX-Eagle"]
            
            if modelField.exists {
                modelField.tap()
                modelField.typeText("SLX")
                
                app/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
            }
            
            // Description
            let componentDescriptionField = app.textFields["Rear Derailleur"]
            
            if componentDescriptionField.exists {
                componentDescriptionField.tap()
                componentDescriptionField.typeText("Rear SLX Derailleur")
                
                app/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
            }

            // Mileage
            tablesQuery/*@START_MENU_TOKEN@*/.buttons["Mileage Alert, 500 miles"]/*[[".cells[\"Mileage Alert, 500 miles\"].buttons[\"Mileage Alert, 500 miles\"]",".buttons[\"Mileage Alert, 500 miles\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            tablesQuery/*@START_MENU_TOKEN@*/.buttons["1,000"]/*[[".cells[\"1,000\"].buttons[\"1,000\"]",".buttons[\"1,000\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            let mileageAlertNavigationBar = app.navigationBars["Mileage Alert"]
            mileageAlertNavigationBar.buttons["Save"].tap()
                        
            // Date
            let dateSwitch = tablesQuery.switches["Date added:, Today"].firstMatch
            dateSwitch.tap()

            let dateText = app.tables.datePickers["Date added to bike"].collectionViews.staticTexts["29"]
            
            // Swipe down until it is visible
            while !dateText.exists {
                app.swipeUp()
            }

            // Interact with it when visible
            dateText.tap()
            
            // Save
            let saveComponentNavBar = app.navigationBars["Save Component"]
            saveComponentNavBar.buttons["Save"].tap()
        }
        // Tap Component
        app.scrollViews.otherElements.buttons["Rear SLX Derailleur, Shimano, SLX, 0, miles, Great"].tap()
        
        if !app.scrollViews.otherElements.staticTexts["Adjusted"].exists {
            // Tap Add Service
            app.scrollViews.otherElements.buttons["Add Service"].tap()
            
            // Description
            let descriptionField = app.textFields["Brake Bleed"]
            
            if descriptionField.exists {
                descriptionField.tap()
                descriptionField.typeText("Adjusted")
                
                app/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
            }
            
            // Save
            let serviceNavBar = app.navigationBars["Add Service"]
            serviceNavBar.buttons["Save"].tap()
            
            XCTAssert(app.scrollViews.otherElements.staticTexts["Adjusted"].exists)
        }
        
        if !app.scrollViews.otherElements.staticTexts["Bolts Greased"].exists {
            // Tap Add Service
            app.scrollViews.otherElements.buttons["Add Service"].tap()
            
            // Description
            let descriptionField = app.textFields["Brake Bleed"]
            
            if descriptionField.exists {
                descriptionField.tap()
                descriptionField.typeText("Bolts Greased")
                
                app/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
            }
            
            // Date
            let dateSwitch = tablesQuery.switches["Date, Today"].firstMatch
            dateSwitch.tap()

            let dateText = app.tables.datePickers["Date serviced"].collectionViews.staticTexts["2"]
            
            // Swipe down until it is visible
            while !dateText.exists {
                app.swipeUp()
            }

            // Interact with it when visible
            dateText.tap()
            
            // Tap Affected
            tablesQuery.cells["Affected Components, 1"].tap()
            // Remove Affected
            tablesQuery.cells["Rear SLX Derailleur, Shimano, SLX, 0, miles, Great"].tap()
            
            // Go back and tap save
            let addServiceButton = app.navigationBars["Component Service"].buttons["Add Service"]
            addServiceButton.tap()
            app.navigationBars["Add Service"].buttons["Save"].tap()
            
            // Alert
            app.alerts["No component selected"].scrollViews.otherElements.buttons["Okay"].tap()
            
            // Add effected
            tablesQuery.cells["Affected Components, 0"].tap()
            tablesQuery/*@START_MENU_TOKEN@*/.buttons["Rear SLX Derailleur, Shimano, SLX, 0, miles, Great"]/*[[".cells[\"Rear SLX Derailleur, Shimano, SLX, 0, miles, Great\"].buttons[\"Rear SLX Derailleur, Shimano, SLX, 0, miles, Great\"]",".buttons[\"Rear SLX Derailleur, Shimano, SLX, 0, miles, Great\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            
            // Go back
            addServiceButton.tap()
            
            // Save
            let serviceNavBar = app.navigationBars["Add Service"]
            serviceNavBar.buttons["Save"].tap()
            
            XCTAssert(app.scrollViews.otherElements.staticTexts["Bolts Greased"].exists)
        }
    }
}
