//
//  InternalController.swift
//  EditorWorkspaceNavigationFeature
//
//  Created by Hoon H. on 2015/02/22.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit
import EditorCommon
import EditorUIComponents






//	Errors on File-System Handling
//	------------------------------
//	File-system is not transactional.
//	That means user must handle failure situation MANUALLY.
//	To make user do it easily, no extra abstraction should be made.
//	This method just suspend operation, where it fails.








///	MARK:
///	MARK:	InternalController







internal final class InternalController: NSObject {
	let menu			=	ContextMenuController()
	var repository		=	nil as WorkspaceRepository?
	
//	let	dragging		=	DraggingController()
	
	override init() {
		super.init()
		
//		dragging.owner	=	self
		
		let querySelection	=	{ [unowned self] ()->SelectionQuery in
			return	SelectionQuery(controller: self.owner, repository: self.repository)
		}
		menu.showInFinder.onAction	=	{ [unowned self] in
			let	q	=	querySelection()
			NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs(q.URL.all)
		}
		menu.showInTerminal.onAction	=	{ [unowned self] in
			let	q	=	querySelection()
			let	u	=	q.URL.hot!
			let	p	=	u.path!
			let	p1	=	p.stringByDeletingLastPathComponent
			let	s	=	NSAppleScript(source: "tell application \"Terminal\" to do script \"cd \(p1)\"")!
			s.executeAndReturnError(nil)
		}
		
		menu.newFile.onAction		=	{ [unowned self] in
			Debug.assertMainThread()
			
			let	q	=	querySelection()
			if let u = q.URL.hot {
				let	parentFolderURL	=	u
				let	r				=	FileUtility.createNewFileInFolder(parentFolderURL)
				if r.ok {
					let	newFileURL	=	r.value!
					let	newFileNode	=	q.node.hot!.createChildNodeAtLastAsKind(WorkspaceNodeKind.File, withName: newFileURL.lastPathComponent!)
					
					self.owner.outlineView.reloadData()
					self.owner.outlineView.expandItem(q.node.hot!)
					self.owner.outlineView.editColumn(0, row: self.owner.outlineView.rowForItem(newFileNode), withEvent: nil, select: true)
				} else {
					self.owner.presentError(r.error!)
				}
			} else {
				//	Ignore. Happens by clicking empty space.
			}
		}
		menu.newFolder.onAction		=	{ [unowned self] in
			Debug.assertMainThread()
			
			let	q	=	querySelection()
			if let u = q.URL.hot {
				let	parentFolderURL	=	u
				let	r				=	FileUtility.createNewFolderInFolder(parentFolderURL)
				if r.ok {
					let	newFolderURL	=	r.value!
					let	newFolderNode	=	q.node.hot!.createChildNodeAtLastAsKind(WorkspaceNodeKind.Folder, withName: newFolderURL.lastPathComponent!)
					
					println(newFolderURL)
					self.owner.outlineView.reloadData()
					self.owner.outlineView.expandItem(q.node.hot!)
					self.owner.outlineView.editColumn(0, row: self.owner.outlineView.rowForItem(newFolderNode), withEvent: nil, select: true)
				} else {
					self.owner.presentError(r.error!)
				}
			} else {
				//	Ignore. Happens by clicking empty space.
			}
		}
		menu.newFolderWithSelection.onAction	=	{ [unowned self] in
			let	q	=	querySelection()

			//	TODO:	Implement this...
		}
		menu.delete.onAction	=	{ [unowned self] in
			let	q			=	querySelection()
			let	targetURLs	=	q.URL.all
			if targetURLs.count > 0 {
				UIDialogues.queryDeletingFilesUsingWindowSheet(self.owner.outlineView.window!, files: targetURLs, handler: { (b:UIDialogueButton) -> () in
					switch b {
					case .OKButton:
						let	us	=	FileOperations.filterTopmostURLsOnlyForTrashing(targetURLs)
						for u in us {
							let	n	=	self.owner!.nodeForAbsoluteFileURL(u)!
							let	pn	=	n.parent!
							let	idx	=	pn.indexOfNode(n)!
							
							switch FileOperations.trashFilesAtURLs([u]) {
							case Resolution.Success(let _):
								pn.deleteChildNodeAtIndex(idx)
								self.owner!.outlineView.removeItemsAtIndexes(NSIndexSet(index: idx), inParent: pn, withAnimation: NSTableViewAnimationOptions.SlideUp)
								
							case Resolution.Failure(let e):
								self.owner!.presentError(e)
								break
							}
						}
						
					case .CancelButton:
						break
					}
				})
			}
		}
		menu.deleteReferenceOnly.onAction	=	{ [unowned self] in
			let	q			=	querySelection()
			let	targetURLs	=	q.URL.all
			if targetURLs.count > 0 {
				let	us	=	FileOperations.filterTopmostURLsOnlyForTrashing(targetURLs)
				for u in us {
					let	n	=	self.owner!.nodeForAbsoluteFileURL(u)!
					let	pn	=	n.parent!
					let	idx	=	pn.indexOfNode(n)!
					
					pn.deleteChildNodeAtIndex(idx)
					self.owner!.outlineView.removeItemsAtIndexes(NSIndexSet(index: idx), inParent: pn, withAnimation: NSTableViewAnimationOptions.SlideUp)
				}
			}
		}
		menu.addAllUnregistredFiles.onAction	=	{ [unowned self] in
			let	q	=	querySelection()
			
			fatalError("Unimplemented yet...")
			//	TODO:	Implement this...
		}
		menu.removeAllMissingFiles.onAction	=	{ [unowned self] in
			let	q	=	querySelection()
			
			fatalError("Unimplemented yet...")
			//	TODO:	Implement this...
		}
		menu.note.onAction	=	{ [unowned self] in
			let	q	=	querySelection()

			fatalError("Unimplemented yet...")
			//	TODO:	Implement this...
		}
		
		NSNotificationCenter.defaultCenter().addObserverForName(
			NSMenuDidBeginTrackingNotification,
			object: MenuController.menuOfController(menu),
			queue: nil) { [unowned self](n:NSNotification!) -> Void in
				let	q	=	querySelection()
				
				let	hasFocusSelection	=	q.node.hot != nil
				let	hasAnySelection		=	q.node.all.count > 0
				let	hasFlatSelection	=	{ ()->Bool in
					if hasAnySelection == false {
						return	false
					}
					let	a	=	q.node.all
					let	f	=	a.first!.parent
					for n in a {
						if n.parent !== f {
							return	false
						}
					}
					return	true
				}()
				let	hasAnyRootSelection	=	q.rootCoolSelection || q.rootHotSelection
				
				self.menu.showInFinder.enabled				=	hasAnySelection
				self.menu.showInTerminal.enabled			=	hasFlatSelection
				self.menu.newFile.enabled					=	hasFocusSelection && q.node.hot!.kind == WorkspaceNodeKind.Folder
				self.menu.newFolder.enabled					=	hasFocusSelection && q.node.hot!.kind == WorkspaceNodeKind.Folder
//				self.menu.newFolderWithSelection.enabled	=	hasFlatSelection && hasAnyRootSelection == false
				self.menu.delete.enabled					=	hasFlatSelection && hasAnyRootSelection == false
//				self.menu.addAllUnregistredFiles.enabled	=	hasAnySelection
//				self.menu.removeAllMissingFiles.enabled		=	hasAnySelection
//				self.menu.note.enabled						=	hasFocusSelection
		}
	}
	weak var owner:WorkspaceNavigationViewController! {
		willSet {
			assert(owner == nil)
		}
	}
}



///	MARK:
///	MARK:	Utility Functions


























///	MARK:
///	MARK:	InternalController (NSOutlineViewDataSource)



extension InternalController: NSOutlineViewDataSource {
	@objc
	func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
		return	false
	}
	@objc
	func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
		let n	=	item as! WorkspaceNode
		return	n.kind == WorkspaceNodeKind.Folder
	}
	@objc
	func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
		if item == nil {
			return	repository == nil ? 0 : 1
		}
		let n	=	item as! WorkspaceNode
		return	n.children.count
	}
	@objc
	func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
		if item == nil {
			return	repository!.root
		}
		let	n	=	item as! WorkspaceNode
		return	n.children[index]
	}
	@objc
	func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
		return	item as! WorkspaceNode
	}
//	@objc
//	func outlineView(outlineView: NSOutlineView, rowViewForItem item: AnyObject) -> NSTableRowView? {
//		let	v	=	NSTableRowView()
//		return	v
//	}
	
	@objc
	func outlineView(outlineView: NSOutlineView, rowViewForItem item: AnyObject) -> NSTableRowView? {
		let	v	=	DarkVibrancyAwareTableRowView()
		return	v
	}
	@objc
	func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
		let	cid	=	WorkspaceNavigationTreeColumnIdentifier(rawValue: tableColumn!.identifier)!
		let	v	=	CellView(cid)
		let	n	=	item as! WorkspaceNode
		v.nodeRepresentation	=	n
		v.textField!.delegate	=	self
		v.appearance			=	outlineView.appearance
		return	v
	}
	
	
	
	//	Drag source support.
	
	@objc
	func outlineView(outlineView: NSOutlineView, pasteboardWriterForItem item: AnyObject?) -> NSPasteboardWriting! {
		let	n	=	item as! WorkspaceNode
		let	u	=	owner!.URLRepresentation!.URLByAppendingPath(n.path)
		return	u
	}
	@objc
	func outlineView(outlineView: NSOutlineView, draggingSession session: NSDraggingSession, willBeginAtPoint screenPoint: NSPoint, forItems draggedItems: [AnyObject]) {
		
	}
	@objc
	func outlineView(outlineView: NSOutlineView, draggingSession session: NSDraggingSession, endedAtPoint screenPoint: NSPoint, operation: NSDragOperation) {
		
	}
	
	
	
	
	//	Drag destination support.
	
	@objc
	func outlineView(outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: AnyObject?, proposedChildIndex index: Int) -> NSDragOperation {
		if item == nil {
			return	NSDragOperation.None
		}
		
		let	n	=	item as! WorkspaceNode
		switch n.kind {
		case .Folder:
			return	NSDragOperation.Every
			
		case .File:
			return	NSDragOperation.None
			
		}
	}
	@objc
	func outlineView(outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: AnyObject?, childIndex index: Int) -> Bool {
		assert(repository != nil)
		assert(item !== nil)
		assert(item is WorkspaceNode)
		assert((item as! WorkspaceNode).kind == WorkspaceNodeKind.Folder)
		
		//	Copies by default.
		//	Moves if user dragged workspace-nodes within same workspace. This does not include
		//	dragging files from Finder or any other apps even they're files in same workspace.
		//
		//	Stop on any errors. User is responsible to handle the error.
		
		//	Though it's not been documented, `index` can be `-1` if user dropped file into the 
		//	container node itself.

		let	op	=	Dropping.Op.determinateOp(info, currentOutlineView: outlineView)
		let	n	=	item as! WorkspaceNode
		let	i1	=	index == -1 ? n.children.count : index
		Dropping(internals: self).processDropping(info, destinationNode: n, destinationChildIndex: i1, operation: op)
		
//		Debug.log(item)
//		Debug.log(a)
		return	true
	}
}




private extension InternalController {
	///	This just generate a proper URL expression object, and does not check for existence.
	func absoluteURLForNode(n:WorkspaceNode) -> NSURL {
		assert(owner!.URLRepresentation!.absoluteURL!.absoluteString == owner!.URLRepresentation!.absoluteString!)
		return	owner!.URLRepresentation!.URLByAppendingPath(n.path)
	}
}








///	MARK:	InternalController (NSOutlineViewDelegate)



extension InternalController: NSOutlineViewDelegate {
	@objc
	func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
		let	n	=	item as! WorkspaceNode
		if n.kind == WorkspaceNodeKind.File {
			let	u	=	owner.URLRepresentation!
			let	u1	=	u.URLByAppendingPath(n.path)
			owner.delegate?.workpaceNavigationViewControllerWantsToOpenFileAtURL(u1)
		}
		return	true
	}
	@objc
	func outlineView(outlineView: NSOutlineView, shouldExpandItem item: AnyObject) -> Bool {
		let	n	=	item as! WorkspaceNode
		n.setExpanded()
		owner.persistToFileSystem()
		return	true
	}
	@objc
	func outlineView(outlineView: NSOutlineView, shouldCollapseItem item: AnyObject) -> Bool {
		let	n	=	item as! WorkspaceNode
		n.setCollapsed()
		owner.persistToFileSystem()
		return	true
	}
}







































///	MARK:	InternalController (WorkspaceRepositoryDelegate)

extension InternalController: WorkspaceRepositoryDelegate {
	func workspaceRepositoryWillCreateNode() {
		
	}
	func workspaceRepositoryDidCreateNode(node: WorkspaceNode) {
		owner.persistToFileSystem()
	}
	func workspaceRepositoryWillRenameNode(node: WorkspaceNode) {
		
	}
	func workspaceRepositoryDidRenameNode(node: WorkspaceNode) {
		owner.persistToFileSystem()
	}
	func workspaceRepositoryWillMoveNode(node: WorkspaceNode) {
	}
	func workspaceRepositoryDidMoveNode(node: WorkspaceNode) {
		owner.persistToFileSystem()
	}
	func workspaceRepositoryWillDeleteNode(node: WorkspaceNode) {
	}
	func workspaceRepositoryDidDeleteNode() {
		owner.persistToFileSystem()		
	}
	
	
	
	func workspaceRepositoryDidOpenSubworkspaceAtNode(node: WorkspaceNode) {
		
	}
	func workspaceRepositoryWillCloseSubworkspaceAtNode(node: WorkspaceNode) {
		
	}
}












///	MARK:	InternalController (NSTextFieldDelegate)

extension InternalController: NSTextFieldDelegate {
	override func controlTextDidBeginEditing(obj: NSNotification) {
	}
	
	override func controlTextDidChange(obj: NSNotification) {
	}
	
	///	Called only when user committed editing. 
	///	No call if user cancanlled editing by pressing ESC key.
	override func controlTextDidEndEditing(obj: NSNotification) {
		//	A bit hacky...
		let	tf	=	obj.object as! NSTextField
		let	c	=	tf.superview as! CellView
		let	n	=	c.nodeRepresentation!
		
		let	pc	=	tf.stringValue
//		if pc == n.name {
//			//	Skip if unchanged.
//			return
//		}
		
		let	u1	=	owner.URLRepresentation!.URLByAppendingPath(n.path)
		let	u2	=	u1.URLByDeletingLastPathComponent!.URLByAppendingPathComponent(pc)
		var	e	=	nil as NSError?
		let	ok	=	NSFileManager.defaultManager().moveItemAtURL(u1, toURL: u2, error: &e)
		if ok {
			n.rename(pc)
		} else {
			Debug.log(u1)
			Debug.log(u2)
			tf.stringValue	=	n.name
			self.owner.presentError(e!)
		}
	}
}








































