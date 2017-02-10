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


@objc public protocol LoginScreenletDelegate : BaseScreenletDelegate {

	/// Called when login successfully completes.
	/// The user attributes are passed as a dictionary of keys (String or NSStrings) 
	/// and values (AnyObject or NSObject).
	///
	/// - Parameters:
	///   - screenlet
	///   - attributes: user attributes.
	@objc optional func screenlet(_ screenlet: BaseScreenlet,
			onLoginResponseUserAttributes attributes: [String:AnyObject])

	///  Called when an error occurs during login. The NSError object describes the error.
	///
	/// - Parameters:
	///   - screenlet
	///   - error: error in login.
	@objc optional func screenlet(_ screenlet: BaseScreenlet,
			onLoginError error: NSError)

	/// Called when the user credentials are stored after a successful login.
	///
	/// - Parameters:
	///   - screenlet
	///   - attributes: user attributes.
	@objc optional func screenlet(_ screenlet: BaseScreenlet,
		onCredentialsSavedUserAttributes attributes: [String:AnyObject])

	/// Called when the user credentials are retrieved. Note that this only occurs when the Screenlet is used and stored credentials are available.
	///
	/// - Parameters:
	///   - screenlet
	///   - attributes: user attributes.
	@objc optional func screenlet(_ screenlet: LoginScreenlet,
		onCredentialsLoadedUserAttributes attributes: [String:AnyObject])

}


open class LoginScreenlet: BaseScreenlet, BasicAuthBasedType {


	//MARK: Inspectables

	@IBInspectable open var basicAuthMethod: String? = BasicAuthMethod.email.rawValue {
		didSet {
			(screenletView as? BasicAuthBasedType)?.basicAuthMethod = basicAuthMethod
		}
	}

	@IBInspectable open var saveCredentials: Bool = false

	@IBInspectable open var companyId: Int64 = 0

	@IBInspectable open var OAuthConsumerKey: String = "" {
		didSet {
			copyAuthType()
		}
	}

	@IBInspectable open var cookieAuth: Bool = false

	@IBInspectable open var OAuthConsumerSecret: String = "" {
		didSet {
			copyAuthType()
		}
	}

	open var loginDelegate: LoginScreenletDelegate? {
		return self.delegate as? LoginScreenletDelegate
	}

	open var viewModel: LoginViewModel {
		return screenletView as! LoginViewModel
	}


	//MARK: BaseScreenlet

	override open func onCreated() {
		super.onCreated()
		
		(screenletView as? BasicAuthBasedType)?.basicAuthMethod = basicAuthMethod

		copyAuthType()

	}

	override open func createInteractor(name: String, sender: AnyObject?) -> Interactor? {
		if cookieAuth {
			return createLoginCookieInteractor()
		}
		switch name {
		case "login-action", BaseScreenlet.DefaultAction:
			return createLoginBasicInteractor()
		case "oauth-action":
			return createLoginOAuthInteractor()
		default:
			return nil
		}
	}


	//MARK: Public methods

	/// loadStoredCredentials loads credentials if exist in the current context.
	///
	/// - Returns: true if succeed, false if not.
	open func loadStoredCredentials() -> Bool {
		if SessionContext.loadStoredCredentials() {
			viewModel.userName = SessionContext.currentContext?.basicAuthUsername
			viewModel.password = SessionContext.currentContext?.basicAuthPassword

			let userAttributes = SessionContext.currentContext!.user.attributes

			// We don't want the session to be automatically created. Clear it.
			// User can recreate it again in the delegate method.
			SessionContext.logout()

			loginDelegate?.screenlet?(self,
			                          onCredentialsLoadedUserAttributes: userAttributes)

			return true
		}
		
		return false
	}


	//MARK: Private methods

	fileprivate func createLoginBasicInteractor() -> LoginBasicInteractor {
		let interactor = LoginBasicInteractor(loginScreenlet: self)

		interactor.onSuccess = {
			self.loginDelegate?.screenlet?(self,
					onLoginResponseUserAttributes: interactor.resultUserAttributes!)

			if let ctx = SessionContext.currentContext, self.saveCredentials {
				if ctx.storeCredentials() {
					self.loginDelegate?.screenlet?(self,
						onCredentialsSavedUserAttributes: interactor.resultUserAttributes!)
				}
			}
		}

		interactor.onFailure = {
			self.loginDelegate?.screenlet?(self, onLoginError: $0)
		}

		return interactor
	}

	fileprivate func createLoginOAuthInteractor() -> LoginOAuthInteractor {
		let interactor = LoginOAuthInteractor(
				screenlet: self,
				consumerKey: OAuthConsumerKey,
				consumerSecret: OAuthConsumerSecret)

		interactor.onSuccess = {
			self.loginDelegate?.screenlet?(self,
					onLoginResponseUserAttributes: interactor.resultUserAttributes!)

			if let ctx = SessionContext.currentContext, self.saveCredentials {
				if ctx.storeCredentials() {
					self.loginDelegate?.screenlet?(self,
						onCredentialsSavedUserAttributes: interactor.resultUserAttributes!)
				}
			}
		}

		interactor.onFailure = {
			self.loginDelegate?.screenlet?(self, onLoginError: $0)
			return
		}

		return interactor
	}

	fileprivate func createLoginCookieInteractor() -> LoginCookieInteractor {
		let interactor = LoginCookieInteractor(screenlet: self, emailAddress: viewModel.userName!, password: viewModel.password!)

		interactor.onSuccess = {
			self.loginDelegate?.screenlet?(self,
			                               onLoginResponseUserAttributes: interactor.resultUserAttributes!)

			if let ctx = SessionContext.currentContext, self.saveCredentials {
				if ctx.storeCredentials() {
					self.loginDelegate?.screenlet?(self,
					                               onCredentialsSavedUserAttributes: interactor.resultUserAttributes!)
				}
			}
		}

		interactor.onFailure = {
			self.loginDelegate?.screenlet?(self, onLoginError: $0)
		}
		
		return interactor
	}


	fileprivate func copyAuthType() {

		let authType: AuthType

		if cookieAuth {
			authType = .cookie
		}
		else if OAuthConsumerKey != "" && OAuthConsumerSecret != "" {
			authType = .oAuth
		}
		else {
			authType = .basic
		}

		(screenletView as? LoginViewModel)?.authType = StringFromAuthType(authType)
	}

}
