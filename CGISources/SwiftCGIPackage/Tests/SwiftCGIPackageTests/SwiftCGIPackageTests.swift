/* *************************************************************************************************
 SwiftCGIPackageTests.swift
   © 2025 YOCKOW.
     Licensed under MIT License.
     See "LICENSE.txt" for more information.
 ************************************************************************************************ */

import Testing
@testable import MyCGILibrary

@Test func testCGIBody() async throws {
  #expect(cgiBodyText.contains("Swift"))
}
