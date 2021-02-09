import XCTest
@testable import IDPPlanner

final class SetExtensionsTests: XCTestCase {
    static var allTests = [
        ("testSubsets1", testSubsets1),
        ("testSubsets2", testSubsets2),
        ("testSubsets3", testSubsets3),
        ("testSubsets4", testSubsets4),
        ("testAllSubsets1", testAllSubsets1),
        ("testAllSubsets2", testAllSubsets2),
    ]

    func testSubsets1() throws {
        let a = Set(["a", "b", "c"])
        let subsets = a.subsets(size: 1)
        XCTAssertEqual(subsets.count, 3)
        for s in subsets {
            XCTAssertEqual(s.count, 1)
        }
        XCTAssertEqual(subsets, Set([
            Set(["a"]),
            Set(["b"]),
            Set(["c"]),
        ]))
    }

    func testSubsets2() throws {
        let a = Set(["a", "b", "c"])
        let subsets = a.subsets(size: 2)
        XCTAssertEqual(subsets.count, 3)
        for s in subsets {
            XCTAssertEqual(s.count, 2)
        }
        XCTAssertEqual(subsets, Set([
            Set(["a", "b"]),
            Set(["a", "c"]),
            Set(["b", "c"]),
        ]))
    }

    func testSubsets3() throws {
        let a = Set(["a", "b", "c"])
        let subsets = a.subsets(size: 3)
        XCTAssertEqual(subsets.count, 1)
        for s in subsets {
            XCTAssertEqual(s.count, 3)
        }
        XCTAssertEqual(subsets, Set([
            Set(["a", "b", "c"]),
        ]))
    }

    func testSubsets4() throws {
        let a = Set(["a", "b", "c"])
        let subsets = a.subsets(size: 4)
        XCTAssertEqual(subsets.count, 0)
    }
    
    func testAllSubsets1() {
        let a = Set(["a", "b", "c"])
        let subsets = a.allProperSubsets
        XCTAssertEqual(subsets, Set([
            Set(["a"]),
            Set(["b"]),
            Set(["c"]),
            Set(["a", "b"]),
            Set(["a", "c"]),
            Set(["b", "c"]),
        ]))
    }
    
    func testAllSubsets2() {
        let a = Set(["a", "b", "c", "d"])
        let subsets = a.allProperSubsets
        XCTAssertEqual(subsets, Set([
            Set(["a"]),
            Set(["b"]),
            Set(["c"]),
            Set(["d"]),
            Set(["a", "b"]),
            Set(["a", "c"]),
            Set(["a", "d"]),
            Set(["b", "c"]),
            Set(["b", "d"]),
            Set(["c", "d"]),
            Set(["a", "b", "c"]),
            Set(["a", "b", "d"]),
            Set(["a", "c", "d"]),
            Set(["b", "c", "d"]),
        ]))
    }
}
