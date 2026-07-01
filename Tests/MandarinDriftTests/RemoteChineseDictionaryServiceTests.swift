import Foundation
import XCTest
import MandarinCore

final class RemoteChineseDictionaryServiceTests: XCTestCase {
    func testFetchUpdatesPaginatesThroughMultiplePages() async throws {
        let config = RemoteChineseDictionaryConfig(
            url: URL(string: "https://example.com/functions/v1/fetchContentUpdates")!,
            format: .json,
            bearerToken: "token",
            requestTimeout: 2,
            importLimit: 2
        )

        let session = makeStubSession()
        let service = RemoteChineseDictionaryService(config: config, session: session)

        let entries = try await service.fetchUpdatesIfAvailable()
        XCTAssertEqual(entries.map(\.simplified), ["你", "好", "我"])
    }

    private func makeStubSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [PagingURLProtocol.self]
        PagingURLProtocol.handler = { request in
            let url = request.url!
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let offset = Int(components?.queryItems?.first(where: { $0.name == "offset" })?.value ?? "0") ?? 0

            let payload: String
            if offset == 0 {
                payload = """
                {
                  "items": [
                    {
                      "id": "11111111-1111-4111-8111-111111111111",
                      "simplified": "你",
                      "traditional": "你",
                      "pinyin": "nǐ",
                      "pinyinNumeric": "ni3",
                      "pinyinSearch": "ni",
                      "definitions": ["you"],
                      "partOfSpeech": "pronoun",
                      "hskLevel": "HSK 1",
                      "frequencyRank": 1,
                      "radical": null,
                      "radicalMeaning": null,
                      "strokeCount": 7,
                      "components": ["亻", "尔"],
                      "categories": ["basics"],
                      "exampleChineseSimplified": "你好",
                      "exampleChineseTraditional": "你好",
                      "examplePinyin": "nǐ hǎo",
                      "exampleEnglish": "hello",
                      "usageNote": null,
                      "memoryHook": null,
                      "toneTip": null,
                      "commonMistake": null,
                      "relatedEntryIds": [],
                      "isPremium": false,
                      "createdAt": "2026-06-27T00:00:00Z",
                      "updatedAt": "2026-06-27T00:00:00Z"
                    },
                    {
                      "id": "22222222-2222-4222-8222-222222222222",
                      "simplified": "好",
                      "traditional": "好",
                      "pinyin": "hǎo",
                      "pinyinNumeric": "hao3",
                      "pinyinSearch": "hao",
                      "definitions": ["good"],
                      "partOfSpeech": "adjective",
                      "hskLevel": "HSK 1",
                      "frequencyRank": 2,
                      "radical": null,
                      "radicalMeaning": null,
                      "strokeCount": 6,
                      "components": ["女", "子"],
                      "categories": ["basics"],
                      "exampleChineseSimplified": "很好",
                      "exampleChineseTraditional": "很好",
                      "examplePinyin": "hěn hǎo",
                      "exampleEnglish": "very good",
                      "usageNote": null,
                      "memoryHook": null,
                      "toneTip": null,
                      "commonMistake": null,
                      "relatedEntryIds": [],
                      "isPremium": false,
                      "createdAt": "2026-06-27T00:00:00Z",
                      "updatedAt": "2026-06-27T00:00:00Z"
                    }
                  ],
                  "count": 2,
                  "limit": 2,
                  "offset": 0,
                  "nextOffset": 2
                }
                """
            } else {
                payload = """
                {
                  "items": [
                    {
                      "id": "33333333-3333-4333-8333-333333333333",
                      "simplified": "我",
                      "traditional": "我",
                      "pinyin": "wǒ",
                      "pinyinNumeric": "wo3",
                      "pinyinSearch": "wo",
                      "definitions": ["I", "me"],
                      "partOfSpeech": "pronoun",
                      "hskLevel": "HSK 1",
                      "frequencyRank": 3,
                      "radical": null,
                      "radicalMeaning": null,
                      "strokeCount": 7,
                      "components": ["戈", "手"],
                      "categories": ["basics"],
                      "exampleChineseSimplified": "我是学生",
                      "exampleChineseTraditional": "我是學生",
                      "examplePinyin": "wǒ shì xuésheng",
                      "exampleEnglish": "I am a student",
                      "usageNote": null,
                      "memoryHook": null,
                      "toneTip": null,
                      "commonMistake": null,
                      "relatedEntryIds": [],
                      "isPremium": false,
                      "createdAt": "2026-06-27T00:00:00Z",
                      "updatedAt": "2026-06-27T00:00:00Z"
                    }
                  ],
                  "count": 1,
                  "limit": 2,
                  "offset": 2,
                  "nextOffset": 3
                }
                """
            }

            return (HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!, Data(payload.utf8))
        }
        return URLSession(configuration: config)
    }
}

final class PagingURLProtocol: URLProtocol {
    static var handler: ((URLRequest) -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        let (response, data) = handler(request)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
