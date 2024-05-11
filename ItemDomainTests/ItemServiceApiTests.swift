//
//  ItemServiceApiTests.swift
//  ItemDomainTests
//
//  Created by Ahmed on 11/05/2024.
//

import Foundation
import XCTest
@testable import ItemDomain
/**
 This incuded the unit tests for APIClient
 */
final class ItemServiceApiTests: XCTestCase {
    private var sut: ItemServiceApi!
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        
        sut = ItemServiceApi(session: urlSession)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_whenGetPostsIsCalled_returnsSuccessResponse() {
        // Given
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        let expectedResponseData = """
                [{
                    "userId": 1,
                    "id": 1,
                    "title": "test title",
                    "body": "test body"
                  }]
                """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            // Check the Http Request
            XCTAssertEqual(request.httpMethod!, "GET")
            //XCTAssertEqual(request.value(forHTTPHeaderField: HTTPHeaderField.contentType.rawValue), ContentType.json.rawValue)
            return (HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!, expectedResponseData)
        }
        
        let expectation = expectation(description: "Posts Resource Success")
        
        // When
        Task {
            do {
                let result: [Item] = try await sut.loadItems()
                
                // Check the Http Response
                XCTAssertEqual(result[0].title, "test title")
                XCTAssertEqual(result.count, 1)
                expectation.fulfill()
            } catch {
                XCTFail("An error occurred during the asynchronous call: \(error)")
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func test_whenGetPostsIsCalled_returnsFailureResponse() {
        // Given
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        let failureResponse = """
                {
                    "error": "Server error",
                    "error_description": "Something went wrong"
                }
                """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { _ in
            return (HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)!, failureResponse)
        }
        
        let expectation = expectation(description: "Posts Resource Server Error")
        
        // When
        Task {
            do {
                _ = try await sut.loadItems()
                
                // Then
                XCTFail("The test should throw a server error for an error response.")
                expectation.fulfill()
            } catch let error as APIError {
                switch error {
                case .serverError(let description):
                    XCTAssertEqual(description, "Something went wrong")
                    expectation.fulfill()
                default:
                    XCTFail("The test should throw a server error for an error response.")
                    expectation.fulfill()
                }
            } catch {
                XCTFail("The test should throw a server error for an error response.")
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 0.1, handler: nil)
    }
}
