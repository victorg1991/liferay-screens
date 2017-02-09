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


open class WebContentDisplayView_default: BaseScreenletView, WebContentDisplayViewModel, UIWebViewDelegate {


	//MARK: Outlets

	@IBOutlet open var webView: UIWebView? {
		didSet {
			webView!.delegate = self
		}
	}

	public var prueba = false

	public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {


//		let dummyRequest = NSMutableURLRequest(url: URL(string:"")!)
//		SessionContext.currentSession?.authentication.authenticate(dummyRequest)
//
//		for (key, value) in dummyRequest.allHTTPHeaderFields! {
//			request.addValue(value, forHTTPHeaderField: key)
//		}

//		if (!prueba) {
//			prueba = true
//			let request1 = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
//			SessionContext.currentSession?.authentication.authenticate(request1)
//
//			webView.loadRequest(request1 as URLRequest)
//			
//
//			return false
//		}

		return true
	}



	override open var progressMessages: [String:ProgressMessages] {
		return [
			BaseScreenlet.DefaultAction :
				[.working : LocalizedString("default", key: "webcontentdisplay-loading-message", obj: self),
				.failure : LocalizedString("default", key: "webcontentdisplay-loading-error", obj: self)]]
	}

	fileprivate let styles =
		".MobileCSS {padding: 4%; width: 92%;} " +
		".MobileCSS, .MobileCSS span, .MobileCSS p, .MobileCSS h1, .MobileCSS h2, .MobileCSS h3 { " +
			"font-size: 110%; font-family: \"Helvetica Neue\", Helvetica, Arial, sans-serif; font-weight: 200; } " +
		".MobileCSS img { width: 100% !important; } " +
		".span2, .span3, .span4, .span6, .span8, .span10 { width: 100%; }"


	override open func createProgressPresenter() -> ProgressPresenter {
		return DefaultProgressPresenter()
	}

	//MARK: WebContentDisplayViewModel

	open var htmlContent: String? {
		get {
			return ""
		}
		set {

			let styledHtml = "<style>\(styles)</style><div class=\"MobileCSS\">\(newValue ?? "")</div>"

			let newHTML = styledHtml.replacingOccurrences(of: "/documents", with: "\(LiferayServerContext.server)documents")


//			let dummyRequest = NSMutableURLRequest(url: URL(string:"someurl.com")!)
//			SessionContext.currentSession?.authentication.authenticate(dummyRequest)
//
//			//let cookies = HTTPCookie.cookies(withResponseHeaderFields: dummyRequest.allHTTPHeaderFields!, for: request.url!)
//
//			let cookieString = dummyRequest.allHTTPHeaderFields!["Cookie"]!.components(separatedBy: ";")
//
//			var cookies = [HTTPCookie]()
//			for cookie in cookieString {
//				if cookie.isEmpty {
//					continue
//				}
//				let nameValue = cookie.components(separatedBy: "=")
//				var dict = [HTTPCookiePropertyKey: Any]()
//
//				dict[HTTPCookiePropertyKey.name] = nameValue[0]
//				dict[HTTPCookiePropertyKey.value] = nameValue[1]
//				dict[HTTPCookiePropertyKey.domain] = "screens-challenge.liferay.org.es"
//				dict[HTTPCookiePropertyKey.path] = "/"
//				dict[HTTPCookiePropertyKey.expires] = nil
//				let realCookie = HTTPCookie(properties: dict)!
//				cookies.append(realCookie)
//			}
//
//			//HTTPCookieStorage.shared.cookieAcceptPolicy = .always
//
//			cookies.forEach { HTTPCookieStorage.shared.setCookie($0) }
//
//			print(cookies)
//			let cookies1 = (SessionContext.currentSession!.authentication as! LRCookieAuthentication).cookies
//			cookies1?.forEach { print($0);HTTPCookieStorage.shared.setCookie($0) }
			webView!.loadHTMLString(newHTML, baseURL: URL(string:LiferayServerContext.server))
		}
	}

	open var recordContent: DDLRecord?

}
