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
import Foundation

public class ImageGalleryUploadInteractor : ServerWriteConnectorInteractor {

	public typealias OnProgress = ImageGalleryUploadConnector.OnProgress

	let imageUpload: ImageEntryUpload
	let repositoryId: Int64
	let folderId: Int64
	let page: Int
	let onUploadedBytes: OnProgress?

	var result: [String : AnyObject]?

	public init(
			screenlet: ImageGalleryScreenlet?,
			imageUpload: ImageEntryUpload,
			repositoryId: Int64,
			folderId: Int64,
			page: Int,
			onUploadedBytes: OnProgress? ) {

		self.imageUpload = imageUpload
		self.repositoryId = repositoryId
		self.folderId = folderId
		self.page = page
		self.onUploadedBytes = onUploadedBytes

		super.init(screenlet: screenlet)
	}

	public override func createConnector() -> ServerConnector? {
		return ImageGalleryUploadConnector(
				repositoryId: repositoryId,
				folderId: folderId,
				sourceFileName: imageUpload.title,
				mimeType: "image/png",
				title: imageUpload.title,
				descrip: imageUpload.descript,
				changeLog: "",
				image: imageUpload.image,
				onUploadBytes:  onUploadedBytes)
	}

	public override func completedConnector(op: ServerConnector) {
		if let op = op as? ImageGalleryUploadConnector, uploadResult = op.uploadResult {
			result = uploadResult
		}
		else if cacheStrategy == .CacheOnly {
			createModelFromUploadData()
		}
	}

	//MARK: Cache methods

	public override func writeToCache(c: ServerConnector) {
		guard let cacheManager = SessionContext.currentContext?.cacheManager
		else {
			return
		}

		if cacheStrategy == .CacheFirst || c.lastError != nil {

			// TODO title could be repeated
			cacheManager.setDirty(
				collection: ScreenletName(ImageGalleryScreenlet),
				key: "uploadEntry-\(imageUpload.title)-\(folderId)-\(repositoryId)",
				value: imageUpload,
				attributes: ["folderId": NSNumber(longLong: folderId),
							 "repositoryId": NSNumber(longLong: repositoryId),
							 "page": NSNumber(long: page)])
		} else {

			saveResultAndCountOnCache()

			cacheManager.remove(
				collection: ScreenletName(ImageGalleryScreenlet),
				key: "uploadEntry-\(imageUpload.title)-\(folderId)-\(repositoryId)")
		}
	}

	public override func callOnSuccess() {
		if cacheStrategy == .CacheFirst {
			// update cache with date sent
			SessionContext.currentContext?.cacheManager.remove(
					collection: ScreenletName(ImageGalleryScreenlet),
					key: "uploadEntry-\(imageUpload.title)-\(folderId)-\(repositoryId)")

			saveResultAndCountOnCache()
		}

		super.callOnSuccess()
	}

	private func createModelFromUploadData() {
		// Construct an object with the uploadEntry data
		result = ["title": imageUpload.title,
		          "fileEntryId": NSNumber(longLong: Int64(CFAbsoluteTimeGetCurrent())),
		          "image": imageUpload.thumbnail!]
	}

	private func saveResultAndCountOnCache() {
		guard let cacheManager = SessionContext.currentContext?.cacheManager
		else {
			return
		}

		if let entry = result {
			let cacheKeyList = "\(ImageGalleryLoadInteractor.CacheKey)-\(page)"
			let cacheKeyCount = "\(ImageGalleryLoadInteractor.CacheKey)-count"

			cacheManager.getSome(
					collection: ScreenletName(ImageGalleryScreenlet),
					keys: [cacheKeyList, cacheKeyCount], result: {

						var newPage = [[String:AnyObject]]()

						if let oldPage = $0.first as? [[String:AnyObject]] {
							newPage.appendContentsOf(oldPage)
						}

						newPage.append(entry)

						cacheManager.setClean(
							collection: ScreenletName(ImageGalleryScreenlet),
							key: cacheKeyList,
							value: newPage,
							attributes: [:])

						if let count = $0.last as? Int {
							cacheManager.setClean(
								collection: ScreenletName(ImageGalleryScreenlet),
								key: cacheKeyCount,
								value: count + 1,
								attributes: [:])
						}
			})
		}
	}


}