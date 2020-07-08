import XCTest
@testable import OctoKit

final class AssetsTests: XCTestCase {
    static var allTests = [
        ("testUploadAssets", testUploadAssets),
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests)
    ]

    // MARK: Actual Request tests

    func testUploadAssets() {
        let session = OctoKitURLTestSession(
            expectedURL: "https://api.github.com/repos/octocat/Hello-world/releases/1/assets",
            expectedHTTPMethod: "POST",
            jsonFile: "upload_asset",
            statusCode: 201
        )
        let task = Octokit().uploadAsset(
            session,
            owner: "octocat",
            repository: "Hello-world",
            releaseId: 1,
            name: "foo.zip"
        ) { response in
                switch response {
                case let .success(asset):
                    XCTAssertEqual(
                        asset.url,
                        URL(string: "https://api.github.com/repos/octocat/Hello-World/releases/assets/1")
                    )
                    XCTAssertEqual(
                        asset.browserDownloadURL,
                        URL(string: "https://github.com/octocat/Hello-World/releases/download/v1.0.0/example.zip")
                    )
                    XCTAssertEqual(asset.id, 1)
                    XCTAssertEqual(asset.nodeId, "MDEyOlJlbGVhc2VBc3NldDE=")
                    XCTAssertEqual(asset.name, "example.zip")
                    XCTAssertEqual(asset.state, "uploaded")
                    XCTAssertEqual(asset.contentType, "application/zip")
                    XCTAssertEqual(asset.downloadCount, 42)
                    XCTAssertEqual(asset.createdAt, Date(timeIntervalSince1970: 1594230516))
                    XCTAssertEqual(asset.updatedAt, Date(timeIntervalSince1970: 1594230516))
                case let .failure(error):
                    XCTFail("Endpoint failed with error \(error)")
                }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }

    func testLinuxTestSuiteIncludesAllTests() {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        let thisClass = type(of: self)
        let linuxCount = thisClass.allTests.count
        #if os(iOS)
        let darwinCount = thisClass.defaultTestSuite.tests.count
        #else
        let darwinCount = thisClass.defaultTestSuite.tests.count
        #endif
        XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
    }
}
