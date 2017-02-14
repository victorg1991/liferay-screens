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

package com.liferay.mobile.screens.comment.list.view;

import com.liferay.mobile.screens.base.list.view.BaseListViewModel;
import com.liferay.mobile.screens.comment.CommentEntry;

/**
 * @author Alejandro Hernández
 */
public interface CommentListViewModel extends BaseListViewModel<CommentEntry> {

	/**
	 * Allows the edition mode in comment list.
	 */
	void allowEdition(boolean editable);

	/**
	 * Adds a new comment to the list.
	 */
	void addNewCommentEntry(CommentEntry commentEntry);

	/**
	 * Removes one comment from the list.
	 */
	void removeCommentEntry(CommentEntry commentEntry);
}
