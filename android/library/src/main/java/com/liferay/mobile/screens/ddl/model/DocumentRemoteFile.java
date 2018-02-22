package com.liferay.mobile.screens.ddl.model;

import com.liferay.mobile.screens.context.LiferayServerContext;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * @author Javier Gamarra
 */
public class DocumentRemoteFile extends DocumentFile {

	private long groupId;
	private String uuid;
	private int version;
	private String title;
	private long folderId;

	public DocumentRemoteFile(String json) throws JSONException {
		JSONObject jsonObject = new JSONObject(json);

		uuid = jsonObject.getString("uuid");
		version = jsonObject.getInt("version");
		groupId = jsonObject.getInt("groupId");
		folderId = jsonObject.optLong("folderId", 0);

		// this is empty if we're retrieving the record
		title = jsonObject.optString("title");
	}

	@Override
	public String toData() {
		return "{\"groupId\":"
			+ groupId
			+ ", "
			+ "\"uuid\":\""
			+ uuid
			+ "\", "
			+ "\"version\":"
			+ version
			+ ", "
			+ "\"folderId\":"
			+ folderId
			+ ", "
			+ "\"title\":"
			+ title
			+ "}";
	}

	@Override
	public String toString() {
		return title.isEmpty() ? "File in server" : title;
	}

	@Override
	public boolean isValid() {
		return uuid != null;
	}

	public String getUrl() {
		return LiferayServerContext.getServer()
			+ "/documents/"
			+ groupId
			+ "/"
			+ folderId
			+ "/"
			+ title
			+ "/"
			+ uuid;
	}
}