package com.liferay.mobile.screens.auth.login.interactor;

import android.text.TextUtils;
import com.liferay.mobile.android.auth.CookieSignIn;
import com.liferay.mobile.android.auth.basic.CookieAuthentication;
import com.liferay.mobile.android.service.Session;
import com.liferay.mobile.screens.auth.BasicAuthMethod;
import com.liferay.mobile.screens.auth.login.connector.UserConnector;
import com.liferay.mobile.screens.base.interactor.event.BasicEvent;
import com.liferay.mobile.screens.cache.executor.Executor;
import com.liferay.mobile.screens.context.LiferayServerContext;
import com.liferay.mobile.screens.context.SessionContext;
import com.liferay.mobile.screens.util.EventBusUtil;
import com.liferay.mobile.screens.util.ServiceProvider;
import java.util.Map;
import org.json.JSONObject;

/**
 * @author Víctor Galán Grande
 */

public class LoginCookieInteractor extends BaseLoginInteractor {

	@Override
	public BasicEvent execute(Object... args) throws Exception {

		String login = (String) args[0];
		String password = (String) args[1];
		Map<String, String> customHeaders = (Map<String, String>) args[2];

		validate(login, password);

		Session session = SessionContext.createBasicSession(login, password);
		session.setHeaders(customHeaders);

		Session cookieSession = CookieSignIn.signIn(session);

		SessionContext.createCookieSession(cookieSession);
		UserConnector userConnector = getUserConnector(cookieSession);

		JSONObject jsonObject = getUser(login, userConnector);

		return new BasicEvent(jsonObject);
	}

	protected JSONObject getUser(String login, UserConnector userConnector)
		throws Exception {

		return userConnector.getUserByEmailAddress(LiferayServerContext.getCompanyId(), login);
	}

	protected void validate(String login, String password) {
		if (login == null) {
			throw new IllegalArgumentException("Login cannot be empty");
		} else if (password == null) {
			throw new IllegalArgumentException("Password cannot be empty");
		}
	}

	public UserConnector getUserConnector(Session session) {
		return ServiceProvider.getInstance().getUserConnector(session);
	}

}
