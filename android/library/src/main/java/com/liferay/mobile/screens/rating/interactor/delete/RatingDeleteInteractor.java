package com.liferay.mobile.screens.rating.interactor.delete;

import com.liferay.mobile.screens.base.interactor.BaseCacheWriteInteractor;
import com.liferay.mobile.screens.rating.AssetRating;
import com.liferay.mobile.screens.rating.RatingListener;
import com.liferay.mobile.screens.rating.RatingScreenlet;
import com.liferay.mobile.screens.rating.connector.ScreensRatingsConnector;
import com.liferay.mobile.screens.rating.interactor.RatingEvent;
import com.liferay.mobile.screens.util.ServiceProvider;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * @author Alejandro Hernández
 */
public class RatingDeleteInteractor extends BaseCacheWriteInteractor<RatingListener, RatingEvent> {

	@Override
	public RatingEvent execute(RatingEvent event) throws Exception {

		ScreensRatingsConnector connector = ServiceProvider.getInstance().getScreensRatingsConnector(getSession());

		JSONObject jsonObject =
			connector.deleteRatingsEntry(event.getClassPK(), event.getClassName(), event.getRatingGroupCounts());

		event.setJSONObject(jsonObject);
		return event;
	}

	@Override
	public void onSuccess(RatingEvent event) {
		JSONObject result = event.getJSONObject();
		AssetRating assetRating;
		try {
			assetRating = new AssetRating(result.getLong("classPK"), result.getString("className"),
				toIntArray(result.getJSONArray("ratings")), result.getDouble("average"), result.getDouble("userScore"),
				result.getDouble("totalScore"), result.getInt("totalCount"));
		} catch (JSONException e) {
			event.setException(e);
			onFailure(event);
			return;
		}
		getListener().onRatingOperationSuccess(assetRating);
	}

	@Override
	public void onFailure(RatingEvent event) {
		getListener().error(event.getException(), RatingScreenlet.DELETE_RATING_ACTION);
	}

	protected int[] toIntArray(JSONArray array) {
		int[] intArray = new int[array.length()];
		for (int i = 0; i < array.length(); i++) {
			intArray[i] = array.optInt(i);
		}
		return intArray;
	}
}
