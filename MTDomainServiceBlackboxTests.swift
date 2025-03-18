//
//  MTDomainServiceBlackboxTests.swift
//  
//
//  Created by Waseem Akram on 15/09/21.
//

import Foundation
import XCTest
@testable import MailTMSwift

class MTDomainServiceBlackboxTests: XCTestCase {

    var sut: MTDomainService!

    override func setUp() {
        sut = MTDomainService()
    }

    override func tearDown() {
        sut = nil
    }

    func test_getAllDomains_returnsDomains() throws {

        let getAllDomainsExpectation = expectation(description: "getAllDomains did not return domains")
        var returnedResultOptional: Result<[MTDomain], MTError>!
        sut.getAllDomains { result in
            returnedResultOptional = result
            getAllDomainsExpectation.fulfill()
        }

        waitForExpectations(timeout: 5)
        let returnedResult = try XCTUnwrap(returnedResultOptional)
        switch returnedResult {
        case .failure(let error):
            switch error {
            case .decodingError(let decodingError):
                XCTFail(decodingError)
            case .encodingError(let encodingError):
                XCTFail(encodingError)
            case .mtError(let mtError):
                XCTFail(mtError)
            case .networkError(let networkError):
                XCTFail(networkError)
            }
        case .success(let domains):
            XCTAssertTrue(domains.count > 0)
        }
    }

    func test_getDomainFromId_returnsDomain() throws {
        let givenId = "613f72dc2a2501052c66504d"
        let getAllDomainsExpectation = expectation(description: "getAllDomains did not return domains")
        var returnedResultOptional: Result<MTDomain, MTError>!
        sut.getDomain(id: givenId) { result in
            returnedResultOptional = result
            getAllDomainsExpectation.fulfill()
        }

        waitForExpectations(timeout: 5)
        let returnedResult = try XCTUnwrap(returnedResultOptional)
        switch returnedResult {
        case .failure(let error):
            switch error {
            case .decodingError(let decodingError):
                XCTFail(decodingError)
            case .encodingError(let encodingError):
                XCTFail(encodingError)
            case .mtError(let mtError):
                XCTFail(mtError)
            case .networkError(let networkError):
                XCTFail(networkError)
            }
        case .success(let domain):
            XCTAssertEqual(domain.id, givenId)
        }
    }

}
