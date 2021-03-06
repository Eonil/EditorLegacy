//
//  FileOperations.swift
//  EditorWorkspaceNavigationFeature
//
//  Created by Hoon H. on 2015/03/01.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation
import EditorCommon



struct FileOperations {
	
	///	Moves all files at URLs to trash.
	static func trashFilesAtURLs(us: [NSURL]) -> Resolution<()> {
		Debug.assertMainThread()
		
		var	err	=	nil as NSError?
		for u in us {
			let	ok	=	NSFileManager.defaultManager().trashItemAtURL(u, resultingItemURL: nil, error: &err)
			assert(ok || err != nil)
			if !ok {
				return	Resolution.failure(err!)
			}
		}
		return	Resolution.success()
	}
	
	
	
	
	
	///	When you delete series of files, you may accidentally try to delete
	///	subnode of a directory file. And the subnode can already be deleted
	///	by deleting one of its ancestor.
	///
	///	To prevent this situation, file nodes must be sorted topologically
	///	and any descendant nodes should be ignored.
	///
	///	This function filters list of file URLs and returns only top-most
	///	file nodes that are appropriate to deletion.
	///
	///	This also performs deduplication.
	///
	///	This is currently about O(n^2).
	///
	///	:param:	us	
	///			Array of URL to filter.
	static func filterTopmostURLsOnlyForTrashing(us:[NSURL]) -> [NSURL] {
		let	us1	=	deduplicateSequence(us)
		var	us2	=	[] as [NSURL]
		for u1 in us1 {
			for u2 in us2 {
				if u2.isFileContainerOf(u1) {
					//	Skip it.
					continue
				}
			}
			us2.append(u1)
		}
		return	us2
	}
}

private extension NSURL {
	func isFileContainerOf(u:NSURL) -> Bool {
		precondition(self.fileURL)
		precondition(self.scheme == u.scheme)
		precondition(self.host == u.host)
		precondition(self.query == nil)
		precondition(u.query == nil)
		return	u.path!.hasPrefix(self.path!)
	}
}






///	Removes all duplicated values without losing ordering.
private func deduplicateSequence<T:Hashable>(vs:[T]) -> [T] {
	var	l	=	[] as [T]
	var	t	=	Set<T>()
	
	for v in vs {
		if t.contains(v) == false {
			t.insert(v)
			l.append(v)
		}
	}
	
	return	l
}

