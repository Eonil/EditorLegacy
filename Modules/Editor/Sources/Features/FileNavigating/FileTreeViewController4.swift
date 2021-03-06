////
////  FileTreeViewController4.swift
////  RustCodeEditor
////
////  Created by Hoon H. on 11/13/14.
////  Copyright (c) 2014 Eonil. All rights reserved.
////
//
//import Foundation
//import AppKit
//import EonilDispatch
//import Precompilation
//
//
//
//
//
//protocol FileTreeViewController4Delegate: class {
//	func fileTreeViewController4NotifyKillingRootURL()
//}
//
//
/////
/////
/////	Take care that the file-system monitoring can be suspended by request,
/////	and this class is using it to suspend file-system monitoring events
/////	while column editing.
//class FileTreeViewController4 : NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, NSMenuDelegate, NSTextFieldDelegate, FileTableCellTextFieldEditingDelegate {
//	weak var delegate:FileTreeViewController4Delegate?
//	
//	///	Directories are excluded.
//	let	userIsWantingToEditFileAtURL	=	Notifier<NSURL>()
//	
//	private	var	_fileTreeRepository		=	nil as FileTreeRepository4?
//	private	var	_fileSystemMonitor		=	nil as FileSystemMonitor3?
//	
//	
//	
//	
//	
//	
//	///	Gets and sets URL for root node.
//	var URLRepresentation:NSURL? {
//		get {
//			return	self.representedObject as NSURL?
//		}
//		set(v) {
//			self.representedObject	=	v
//		}
//	}
//	
//	///	Notifies invlidation of a node.
//	///	The UI will be updated to reflect the invalidation.
//	func invalidateNodeForURL(u:NSURL) {
//		assert(NSThread.currentThread() == NSThread.mainThread())
//		assert(_fileTreeRepository != nil)
//		Debug.log("invalidateNodeForURL: \(u)")
//		
//		if u == URLRepresentation {
//			self.delegate?.fileTreeViewController4NotifyKillingRootURL()
//			self.URLRepresentation	=	nil		//	Self-destruction.
//			self.outlineView.reloadData()
//			return
//		}
//		
//		let	u2	=	u.URLByDeletingLastPathComponent!
//		
//		//	File-system notifications are sent asynchronously, 
//		//	then a file-node for the URL may not exist.
//		if let n1 = _fileTreeRepository![u2] {
//			//	Store currently selected URLs.
//			//	Getting and setting selection can show unexpected behavior if it is being performed
//			//	while a column is in editing. So ensure this will not be called while editing.
//			let	selus1	=	outlineView.selectedRowIndexes.allIndexes.map { idx in
//				return	self.outlineView.itemAtRow(idx) as? FileNode4
//			}.filter { (n:FileNode4?)->(Bool) in
//				return	n !== nil
//			}.map { n in
//				return	n!.link
//			} as [NSURL]
//
////			let	selus0	=	outlineView.selectedRowIndexes
////			let	selus1	=	selus0.allIndexes.map { (idx:Int)->(NSURL?) in
////					let	node1	=	self.outlineView.itemAtRow(idx) as FileNode4?
////					let	url1	=	node1?.link as NSURL?
////					return	url1
////				}.filter { u in
////					return	u != nil
////				}.map { u in
////					return	u!
////				} as [NSURL]
//			
//
//			func reloadingOnlyChangedPortions() {
//				func collectAllCurrentlyDisplayingNodes() -> [FileNode4] {
//					var	dns1	=	[] as [FileNode4]
//					for i in 0..<self.outlineView.numberOfRows {
//						let	dn1	=	self.outlineView.itemAtRow(i)! as FileNode4
//						dns1.append(dn1)
//					}
//					return	dns1
//				}
//				
////				let	oldlnks	=	n1.subnodes.links
//				
//				//	Perform reloading.
//				n1.reloadSubnodes()
//				outlineView.reloadItem(n1, reloadChildren: true)
//
////
////				let	n2	=	n1.subnodes[0]
////				println(n2.link)
////				outlineView.reloadItem(n2, reloadChildren: false)
//			}
//			
//			reloadingOnlyChangedPortions()
//			
//			
//			//	Restore previously selected URLs.
//			//	Just skip disappeared/missing URLs.
////			let	selns2	=	selus1.map({self._fileTreeRepository![$0]}).filter({$0 != nil})
////			let	selrs3	=	selns2.map({self.outlineView.rowForItem($0!)}).filter({$0 != -1})
////			let	selrs4	=	NSIndexSet(selrs3)
////			outlineView.selectRowIndexes(selrs4, byExtendingSelection: false)
//			
//			Debug.log("Tree partially reloaded.")
//		}
//	}
//	
//	
//	
//	
//	
//	
//	
//	
//	override var representedObject:AnyObject? {
//		willSet(v) {
//			precondition(v == nil || v is NSURL)
//			
//			_fileSystemMonitor	=	nil
//			_fileTreeRepository	=	nil
//		}
//		didSet {
//			assert(URLRepresentation == nil || URLRepresentation?.existingAsDirectoryFile == true)
//			
//			if let v3 = URLRepresentation {
//				_fileTreeRepository	=	FileTreeRepository4(rootlink: v3)
//				_fileTreeRepository!.reload()
//				
//				let	callback	=	{ [weak self] (u:NSURL)->() in
//					self?.invalidateNodeForURL(u)
//					return	()
//				}
//				_fileSystemMonitor	=	FileSystemMonitor3(monitoringRootURL: v3, callback: callback)
//			}
//			self.outlineView.reloadData()
//			if URLRepresentation != nil {
//				self.outlineView.expandItem(_fileTreeRepository!.root, expandChildren: false)
//			}
//		}
//	}
//	
//	var outlineView:NSOutlineView {
//		get {
//			return	self.view as NSOutlineView
//		}
//		set(v) {
//			self.view	=	v
//		}
//	}
//	override func loadView() {
//		super.view	=	NSOutlineView()
//	}
//	override func viewDidLoad() {
//		super.viewDidLoad()
//		
//		let	col1		=	NSTableColumn(identifier: NAME, title: "Name", width: 100)
//
//		outlineView.addTableColumn <<< col1
//		outlineView.outlineTableColumn		=	col1
//		outlineView.rowSizeStyle			=	NSTableViewRowSizeStyle.Small
//		outlineView.selectionHighlightStyle	=	NSTableViewSelectionHighlightStyle.SourceList
//		outlineView.allowsMultipleSelection	=	true
//		outlineView.focusRingType			=	NSFocusRingType.None
//		outlineView.headerView				=	nil
//		outlineView.doubleAction			=	"dummyDoubleAction:"		//	This is required to make column editing to be started with small delay like renaming in Finder.
//		
//		outlineView.sizeLastColumnToFit()
//		
//		outlineView.setDataSource(self)
//		outlineView.setDelegate(self)
//		
//		outlineView.menu			=	NSMenu()
//		outlineView.menu!.delegate	=	self
//		
//		////
//		
//		func getURLFromRowAtIndex(v:NSOutlineView, index:Int) -> NSURL {
//			let	n	=	v.itemAtRow(index) as FileNode4
//			return	n.link
//		}
//		func getURLFromClickingPoint(v:NSOutlineView) -> NSURL? {
//			let	r1	=	v.clickedRow
//			if r1 >= 0 {
//				return	getURLFromRowAtIndex(v, r1)
//			} else {
//				return	nil
//			}
//		}
//		func collectTargetFileURLs(v:NSOutlineView) -> [NSURL] {
//
//			func getURLsFromSelection(v:NSOutlineView) -> [NSURL] {
//				return
//					v.selectedRowIndexes.allIndexes.map { idx in
//						return	getURLFromRowAtIndex(v, idx)
//					}
//			}
//			
//			let	clickingURL		=	getURLFromClickingPoint(v)
//			let	selectingURLs	=	getURLsFromSelection(v)
//			if clickingURL == nil {
//				return	selectingURLs
//			}
//			
//			if contains(selectingURLs, clickingURL!) {
//				return	selectingURLs
//			} else {
//				return	[clickingURL!]
//			}
//		}
//		
//		func getParentFolderURLOfClickingPoint(v:NSOutlineView) -> NSURL? {
//			if let u2 = getURLFromClickingPoint(v) {
//				let	parentFolderURL	=	u2.existingAsDirectoryFile ? u2 : u2.URLByDeletingLastPathComponent!
//				assert(parentFolderURL.existingAsDirectoryFile)
//				return	parentFolderURL
//			}
//			return	nil
//		}
//		
//		outlineView.menu!.addItem(NSMenuItem(title: "Show in Finder", reaction: { [unowned self] () -> () in
//			let	targetURLs	=	collectTargetFileURLs(self.outlineView)
//			NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs(targetURLs)
//		}))
//		
//		outlineView.menu!.addSeparatorItem()
//		
//		outlineView.menu!.addItem(NSMenuItem(title: "New File", reaction: { [unowned self] () -> () in
//			if let parentFolderURL = getParentFolderURLOfClickingPoint(self.outlineView) {
//				let	r	=	FileUtility.createNewFileInFolder(parentFolderURL)
//				if r.ok {
//					let	newFolderURL	=	r.value!
//					let	parentNode	=	self._fileTreeRepository![parentFolderURL]!		//	Must be exists.
//					parentNode.reloadSubnodes()
//					
//					let	n1	=	self._fileTreeRepository![newFolderURL]		//	Can be `nil` if the newly created directory has been deleted immediately. This is very unlikely to happen, but possible in theory.
//					if let newFolderNode = n1 {
//						self.outlineView.reloadItem(parentNode, reloadChildren: true)	//	Refresh view.
//						self.outlineView.expandItem(parentNode)
//						
//						let	idx		=	self.outlineView.rowForItem(newFolderNode)			//	Now it should have a node for the URL.
//						assert(idx >= 0)
//						if idx >= 0 {
//							self.outlineView.selectRowIndexes(NSIndexSet(), byExtendingSelection: false)
//							self.outlineView.selectRowIndexes(NSIndexSet(index: idx), byExtendingSelection: true)
//
////							if self._fileSystemMonitor!.isPending == false {
////								self._fileSystemMonitor!.suspendEventCallbackDispatch()
////							}
//							self.outlineView.editColumn(0, row: idx, withEvent: nil, select: true)
//						} else {
//							//	Shouldn't happen, but nobody knows...
//						}
//					}
//				} else {
//					self.presentError(r.error!)
//				}
//			} else {
//				//	Ignore. Happens by clicking empty space.
//			}
//		}))
//		
//		outlineView.menu!.addItem(NSMenuItem(title: "New Folder", reaction: { [unowned self] () -> () in
//			if let parentFolderURL = getParentFolderURLOfClickingPoint(self.outlineView) {
//				let	r	=	FileUtility.createNewFolderInFolder(parentFolderURL)
//				if r.ok {
//					let	newFolderURL	=	r.value!
//					let	parentNode	=	self._fileTreeRepository![parentFolderURL]!		//	Must be exists.
//					parentNode.reloadSubnodes()
//					
//					let	n1	=	self._fileTreeRepository![newFolderURL]		//	Can be `nil` if the newly created directory has been deleted immediately. This is very unlikely to happen, but possible in theory.
//					if let newFolderNode = n1 {
//						self.outlineView.reloadItem(parentNode, reloadChildren: true)	//	Refresh view.
//						self.outlineView.expandItem(parentNode)
//						
//						let	idx		=	self.outlineView.rowForItem(newFolderNode)			//	Now it should have a node for the URL.
//						assert(idx >= 0)
//						if idx >= 0 {
//							self.outlineView.selectRowIndexes(NSIndexSet(), byExtendingSelection: false)
//							self.outlineView.selectRowIndexes(NSIndexSet(index: idx), byExtendingSelection: true)
//							
////							if self._fileSystemMonitor!.isPending == false {
////								self._fileSystemMonitor!.suspendEventCallbackDispatch()
////							}
//							self.outlineView.editColumn(0, row: idx, withEvent: nil, select: true)
//						} else {
//							//	Shouldn't happen, but nobody knows...
//						}
//					}
//				} else {
//					self.presentError(r.error!)
//				}
//			} else {
//				//	Ignore. Happens by clicking empty space.
//			}
//		}))
//		
//		outlineView.menu!.addSeparatorItem()
//		
//		outlineView.menu!.addItem(NSMenuItem(title: "Delete", reaction: { [unowned self] () -> () in
//			let	targetURLs	=	collectTargetFileURLs(self.outlineView)
//			if targetURLs.count > 0 {
//				UIDialogues.queryDeletingFilesUsingWindowSheet(self.outlineView.window!, files: targetURLs, handler: { (b:UIDialogueButton) -> () in
//					switch b {
//					case .OKButton:
//						for u in targetURLs {
//							var	err	=	nil as NSError?
//							let	ok	=	NSFileManager.defaultManager().trashItemAtURL(u, resultingItemURL: nil, error: &err)
//							assert(ok || err != nil)
//							if !ok {
//								self.outlineView.presentError(err!)
//							}
//						}
//						
//					case .CancelButton:
//						break
//					}
//				})
//			}
//		}))
//
//
//	}
//	
//	
//	
//	
//	
//	
//	
//	
//	
//	
//	
//	
//	@objc
//	func dummyDoubleAction(AnyObject?) {
//		println("AA")
//	}
//	
//	
////	func outlineView(outlineView: NSOutlineView, heightOfRowByItem item: AnyObject) -> CGFloat {
////		return	16
////	}
//	
//	func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
//		let	n1	=	item as FileNode4?
//		if let n2 = n1 {
//			if n2.subnodes.count == 0 {
//				n2.reloadSubnodes()
//			}
//			return	n2.subnodes.count
//		} else {
//			return	_fileTreeRepository?.root == nil ? 0 : 1
//		}
//	}
//	func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
//		let	n1	=	item as FileNode4?
//		if let n2 = n1 {
//			return	n2.subnodes[index]
//		} else {
//			return	_fileTreeRepository!.root!
//		}
//	}
//	
////	func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
////		let	n1	=	item as FileNode4
////		let	ns2	=	n1.subnodes
////		return	ns2 != nil
////	}
//	
//	func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
//		let	n1	=	item as FileNode4
//		return	n1.directory
//	}
//
//	func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
//		let	tv1	=	FileTableCellTextField()
//		let	iv1	=	NSImageView()
//		let	cv1	=	FileTableCellView()
//		cv1.textField	=	tv1
//		cv1.imageView	=	iv1
//		cv1.addSubview(tv1)
//		cv1.addSubview(iv1)
//		
//		tv1.editingDelegate				=	self
//
//		///	Do not query on file-system here.
//		///	The node is a local cache, and may not exist on 
//		///	underlying file-system. 
//		///	This is especially true for kqueue/GCD notification.
//		///	GCD VNODE notifications are fired asynchronously, and
//		///	the actual file can be already gone at the time of the
//		///	notification arrives. In other words, file operation
//		///	does not wait for notification returns.
//		///	So do not query on file-system at this point, and just
//		///	use cached data on the node.
//		
//		let	n1	=	item as FileNode4
//		iv1.image						=	n1.icon
//		cv1.textField!.stringValue		=	n1.displayName
//		cv1.textField!.bordered			=	false
//		cv1.textField!.backgroundColor	=	NSColor.clearColor()
//		cv1.textField!.delegate			=	self
//		
//		(cv1.textField!.cell() as NSCell).lineBreakMode	=	NSLineBreakMode.ByTruncatingTail
//		cv1.objectValue					=	n1.link.lastPathComponent
//		cv1.textField!.stringValue		=	n1.link.lastPathComponent!
//		return	cv1
//	}
//	
//	
//	
//	func outlineViewSelectionDidChange(notification: NSNotification) {
//		let	idx1	=	self.outlineView.selectedRow
//		if idx1 >= 0 {	
//			let	n1		=	self.outlineView.itemAtRow(idx1) as FileNode4
//			userIsWantingToEditFileAtURL.signal(n1.link)
//		}
//	}
//	func outlineViewItemDidCollapse(notification: NSNotification) {
//		assert(notification.name == NSOutlineViewItemDidCollapseNotification)
//		let	n1	=	notification.userInfo!["NSObject"]! as FileNode4
//		n1.resetSubnodes()
//	}
//	
//	func menuNeedsUpdate(menu: NSMenu) {
////		outlineView.selectedRowIndexes
//	}
//	
//	private func fileTableCellTextFieldDidBecomeFirstResponder() {
////		if _fileSystemMonitor!.isPending == false {
//			_fileSystemMonitor!.suspendEventCallbackDispatch()
////		}
//	}
//	private func fileTableCellTextFieldDidResignFirstResponder() {
////		if _fileSystemMonitor!.isPending {
//			_fileSystemMonitor!.resumeEventCallbackDispatch()	//	This will trigger sending of pended events, and effectively reloading of some nodes.
////		}
//	}
////	func control(control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
////		if _fileSystemMonitor!.isPending == false {
////			_fileSystemMonitor!.suspendEventCallbackDispatch()
////		}
////		return	true
////	}
////	func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
////		return	true
////	}
////	override func controlTextDidEndEditing(obj: NSNotification) {
////		Debug.log("controlTextDidEndEditing")
////		
////		if _fileSystemMonitor!.isPending {
////			_fileSystemMonitor!.resumeEventCallbackDispatch()	//	This will trigger sending of pended events, and effectively reloading of some nodes.
////		}
////	}
//}
//
//@objc
//class FileTableRowView: NSTableRowView {
//	@objc
//	var objectValue:AnyObject? {
//		get {
//			return	"AAA"
//		}
//		set(v) {
//			
//		}
//	}
//}
//@objc
//class FileTableCellView: NSTableCellView {
//	@objc
//	override var acceptsFirstResponder:Bool {
//		get {
//			return	true
//		}
//	}
//	@objc
//	override func becomeFirstResponder() -> Bool {
//		return	true
//	}
//}
//@objc
//private class FileTableCellTextField: NSTextField {
//	weak var editingDelegate:FileTableCellTextFieldEditingDelegate?
//	
//	@objc
//	override var acceptsFirstResponder:Bool {
//		get {
//			return	true
//		}
//	}
//	@objc
//	override func becomeFirstResponder() -> Bool {
//		editingDelegate?.fileTableCellTextFieldDidBecomeFirstResponder()
//		return	true
//	}
//	@objc
//	override func resignFirstResponder() -> Bool {
//		editingDelegate?.fileTableCellTextFieldDidResignFirstResponder()
//		return	true
//	}
//}
//
//private protocol FileTableCellTextFieldEditingDelegate: class {
//	func fileTableCellTextFieldDidBecomeFirstResponder()
//	func fileTableCellTextFieldDidResignFirstResponder()
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//private let	NAME	=	"NAME"
//
//
//
//
//
////private final class MenuManager : NSObject, NSMenuDelegate {
////	
////	func menuNeedsUpdate(menu: NSMenu) {
////		
////	}
////}
//
//
//
//
//
//
//
//
