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
import UIKit
import LRMobileSDK


open class LoginCookieInteractor: Interactor, LRCookieCallback, LRCallback {

	open let emailAddress: String
	open let password: String
	open let companyId: Int64

	open var cookieSession: LRSession?

	open var resultUserAttributes: [String:AnyObject]?

	//MARK: Initializers

	public init(screenlet: BaseScreenlet?, companyId: Int64 = LiferayServerContext.companyId, emailAddress: String, password: String) {
		self.companyId = companyId
		self.emailAddress = emailAddress
		self.password = password

		super.init(screenlet: screenlet)
	}

	open override func start() -> Bool {
		let basicAuth = LRBasicAuthentication(username: emailAddress, password: password)
		let session = LRSession(server: LiferayServerContext.server, authentication: basicAuth)

		LRCookieSignIn.signIn(with: session, callback: self)
		return true
	}

	public func onCookieFailure(_ error: Error!) {
		onFailure?(error as NSError)
	}

	public func onSuccess(_ result: Any!) {
		if let resultValue = result as? [String:AnyObject] {
			self.resultUserAttributes = resultValue

			SessionContext.loginWithCookie(
				authentication: cookieSession?.authentication as! LRCookieAuthentication,
				userAttributes: resultValue)

			self.callOnSuccess()
		}
	}

	public func onFailure(_ error: Error!) {
		onFailure?(error as NSError)
	}

	public func onCookieSuccess(_ session: LRSession!) {
		cookieSession = session
		session.callback = self

		switch LiferayServerContext.serverVersion {
		case .v62:
			let srv = LRScreensuserService_v62(session: session)

			_ = try? srv?.getCurrentUser()

		case .v70:
			let srv = LRUserService_v7(session: session)

			_ = try? srv?.getCurrentUser()
		}
	}

}
