package com.liferay.mobile.screens.viewsets.defaultviews.comment;

import android.content.Context;
import android.os.Bundle;
import android.os.Parcelable;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import com.liferay.mobile.screens.R;
import com.liferay.mobile.screens.base.BaseScreenlet;
import com.liferay.mobile.screens.base.list.BaseListScreenletView;
import com.liferay.mobile.screens.comment.CommentListScreenlet;
import com.liferay.mobile.screens.comment.view.CommentListViewModel;
import com.liferay.mobile.screens.comment.view.CommentView;
import com.liferay.mobile.screens.comment.view.CommentViewListener;
import com.liferay.mobile.screens.models.CommentEntry;
import java.util.ArrayList;
import java.util.List;
import java.util.Stack;

/**
 * @author Alejandro Hernández
 */
public class CommentListView
	extends BaseListScreenletView<CommentEntry, CommentListAdapter.CommentViewHolder, CommentListAdapter>
	implements CommentListViewModel, CommentViewListener, View.OnClickListener {

	public CommentListView(Context context) {
		super(context);
	}

	public CommentListView(Context context, AttributeSet attributes) {
		super(context, attributes);
	}

	public CommentListView(Context context, AttributeSet attributes, int defaultStyle) {
		super(context, attributes, defaultStyle);
	}

	@Override protected Parcelable onSaveInstanceState() {
		Bundle bundle = (Bundle) super.onSaveInstanceState();
		Stack<CommentEntry> stack = getCommentScreenlet().getDiscussionStack();
		ArrayList<CommentEntry> discussion = new ArrayList<>(stack);
		bundle.putParcelableArrayList("stack", discussion);
		return bundle;
	}

	private CommentListScreenlet getCommentScreenlet() {
		return (CommentListScreenlet) getScreenlet();
	}

	@Override protected void onRestoreInstanceState(Parcelable inState) {
		Bundle state = (Bundle) inState;
		ArrayList<CommentEntry> discussion = state.getParcelableArrayList("stack");
		Stack<CommentEntry> stack = new Stack<>();
		stack.addAll(discussion);
		getCommentScreenlet().setDiscussionStack(stack);
		changeToCommentDiscussion(stack.empty() ? null : stack.peek());
		super.onRestoreInstanceState(inState);
	}

	@Override protected void onFinishInflate() {
		super.onFinishInflate();
		_commentView = (CommentView) findViewById(R.id.discussion_comment);
		_discussionSeparator = (ImageView) findViewById(R.id.comment_separator);
		_emptyListTextView = (TextView) findViewById(R.id.comment_empty_list);
		_goBackButton = (Button) findViewById(R.id.comment_go_back);
		_sendButton = (Button) findViewById(R.id.comment_send);
		_addCommentEditText = (EditText) findViewById(R.id.comment_add);

		_goBackButton.setOnClickListener(this);
		_sendButton.setOnClickListener(this);

		_commentView.setListener(this);

		setFocusableInTouchMode(true);
	}

	@Override public boolean onKeyUp(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK && _discussionComment != null) {
			goBackToList();
			return true;
		}
		return super.onKeyUp(keyCode, event);
	}

	@Override protected CommentListAdapter createListAdapter(int itemLayoutId, int itemProgressLayoutId) {
		return new CommentListAdapter(itemLayoutId, itemProgressLayoutId, this, getContext());
	}

	@Override public void showFinishOperation(int page, List<CommentEntry> serverEntries, int rowCount) {
		super.showFinishOperation(page, serverEntries, rowCount);

		_sendButton.setEnabled(true);

		if (getAdapter().getEntries().isEmpty()) {
			_emptyListTextView.setText(_discussionComment != null ? R.string.empty_replies : R.string.empty_comments);
			_emptyListTextView.setVisibility(VISIBLE);
		} else {
			_emptyListTextView.setVisibility(GONE);
		}
	}

	@Override protected int getItemLayoutId() {
		return R.layout.comment_row_default;
	}

	@Override public void setHtmlBody(boolean htmlBody) {
		getAdapter().setHtmlBody(htmlBody);
		_commentView.setHtmlBody(htmlBody);
	}

	@Override
	public void changeToCommentDiscussion(CommentEntry newRootComment) {
		_discussionComment = newRootComment;

		if (newRootComment == null) {
			_goBackButton.setVisibility(GONE);
			_commentView.setVisibility(GONE);
			_discussionSeparator.setVisibility(GONE);
			_addCommentEditText.setHint(R.string.type_your_comment);
			_sendButton.setText(R.string.send);
		} else {
			_goBackButton.setVisibility(VISIBLE);
			_commentView.setCommentEntry(newRootComment);
			_commentView.reloadUserPortrait();
			_commentView.hideRepliesCounter();
			_commentView.setVisibility(VISIBLE);
			_discussionSeparator.setVisibility(VISIBLE);
			_addCommentEditText.setHint(R.string.type_your_reply);
			_sendButton.setText(R.string.reply);

			requestFocus();
		}
	}

	@Override
	public void onItemClick(int position, View view) {
		super.onItemClick(position, view);

		requestFocus();

		CommentEntry newRootComment = getAdapter().getEntries().get(position);

		clearAdapterEntries();

		getScreenlet().performUserAction(BaseScreenlet.DEFAULT_ACTION, CommentListScreenlet.IN_DISCUSSION_ACTION, newRootComment);
	}

	private void clearAdapterEntries() {
		getAdapter().getEntries().clear();
	}

	private void goBackToList() {
		clearAdapterEntries();
		_emptyListTextView.setVisibility(GONE);
		getScreenlet().performUserAction(BaseScreenlet.DEFAULT_ACTION, CommentListScreenlet.OUT_DISCUSSION_ACTION);
	}

	@Override public void onEditButtonClicked(long commentId, String newBody) {
		clearAdapterEntries();
		getScreenlet().performUserAction(CommentListScreenlet.UPDATE_COMMENT_ACTION, commentId, newBody);
	}

	@Override public void onDeleteButtonClicked(long commentId) {
		clearAdapterEntries();
		getScreenlet().performUserAction(CommentListScreenlet.DELETE_COMMENT_ACTION, commentId);
	}

	@Override public void onClick(View v) {
		int i = v.getId();
		if (i == R.id.comment_go_back && _discussionComment != null) {
			goBackToList();
		} else if (i == R.id.comment_send) {
			String body = _addCommentEditText.getText().toString();
			if (!body.isEmpty()) {
				clearAdapterEntries();
				_addCommentEditText.setText("");
				_sendButton.setEnabled(false);
				getScreenlet().performUserAction(CommentListScreenlet.ADD_COMMENT_ACTION, body);
			}
		}
	}

	private CommentEntry _discussionComment;

	private CommentView _commentView;
	private ImageView _discussionSeparator;
	private TextView _emptyListTextView;
	private Button _goBackButton;
	private Button _sendButton;
	private EditText _addCommentEditText;
}
