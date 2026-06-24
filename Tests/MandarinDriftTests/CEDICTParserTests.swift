import XCTest
import MandarinCore

final class CEDICTParserTests: XCTestCase {
    func testParsesBasicCEDICTLine() {
        let parser = CEDICTParser()
        let text = "你好 你好 [ni3 hao3] /hello/hi/\n"
        let entries = parser.parse(text: text, limit: nil)

        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0].simplified, "你好")
        XCTAssertEqual(entries[0].traditional, "你好")
        XCTAssertEqual(entries[0].pinyinNumeric, "ni3 hao3")
        XCTAssertEqual(entries[0].pinyin, "nǐ hǎo")
        XCTAssertEqual(entries[0].definitions, ["hello", "hi"])
    }

    func testParsesUDiaeresis() {
        let parser = CEDICTParser()
        let text = "女兒 女儿 [nu:3 er2] /daughter/\n"
        let entries = parser.parse(text: text, limit: nil)

        XCTAssertEqual(entries.first?.pinyin, "nǚ ér")
    }
}
