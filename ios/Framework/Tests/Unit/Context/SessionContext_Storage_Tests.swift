/**
* Copyright (c) 2000-present Liferay, Inc. All rights reserved.
*
* This library is free software; you can redistribute it and/or modify it under
* the terms of the GNU Lesser General Public License as published by the Free
* Software Foundation; either version 2.1 of the License, or (at your option)
* any later version.
*
* This library is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
* details.
*/
import XCTest


class SessionContext_Storage_Tests: XCTestCase {

	var credentialStore = CredentialStoreMock()

	override func setUp() {
		super.setUp()

		self.continueAfterFailure = false
		self.credentialStore = CredentialStoreMock()

		SessionContext.credentialsStorage = CredentialsStorage(
				credentialStore: self.credentialStore)

		SessionContext.logout()
	}

	override func tearDown() {
		SessionContext.logout()
		SessionContext.credentialsStorage = CredentialsStorage(
			credentialStore: BasicCredentialsStoreKeyChain())

		super.tearDown()
	}

	func test_StoreSession_ShouldReturnFalse_WhenSessionIsNotCreated() {
		XCTAssertFalse(SessionContext.storeCredentials())

		XCTAssertFalse(credentialStore.calledStoreCredential)
	}

	func test_StoreSession_ShouldReturnFalse_WhenUserAttributesAreEmpty() {
		SessionContext.createBasicSession(
				username: "username",
				password: "password",
				userAttributes: [:])

		XCTAssertFalse(SessionContext.storeCredentials())

		XCTAssertFalse(credentialStore.calledStoreCredential)
	}

	func test_StoreSession_ShouldReturnTrue_WhenSessionIsCreated() {
		SessionContext.createBasicSession(
				username: "username",
				password: "password",
				userAttributes: ["k":"v"])

		SessionContext.credentialsStorage = CredentialsStorage(
				credentialStore: self.credentialStore)

		XCTAssertTrue(SessionContext.storeCredentials())

		XCTAssertTrue(credentialStore.calledStoreCredential)
	}

	func test_LoadSessionFromStore_ShouldReturnFalse_WhenSessionIsNotStored() {
		SessionContext.createBasicSession(
				username: "username",
				password: "password",
				userAttributes: ["k":"v"])

		SessionContext.credentialsStorage = CredentialsStorage(
				credentialStore: self.credentialStore)

		credentialStore.hasData = false

		XCTAssertFalse(SessionContext.loadStoredCredentials())

		XCTAssertTrue(credentialStore.calledLoadCredential)

		XCTAssertTrue(SessionContext.currentBasicUserName == nil)
		XCTAssertTrue(SessionContext.currentBasicPassword == nil)
	}

	func test_RemoveStoredSession_ShouldEmptyTheStoredSession() {
		SessionContext.removeStoredCredentials()

		XCTAssertTrue(credentialStore.calledRemoveCredential)
	}

}
