//
//  GitHubSearch_reactorkit_demoUITestsLaunchTests.swift
//  GitHubSearch-reactorkit-demoUITests
//
//  Created by 9oya on 9/6/23.
//

import XCTest

final class GitHubSearch_reactorkit_demoUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
