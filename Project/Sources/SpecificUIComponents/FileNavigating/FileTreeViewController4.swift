//
//  FileTreeViewController4.swift
//  RustCodeEditor
//
//  Created by Hoon H. on 11/13/14.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation
import AppKit
import EonilDispatch

class FileTreeViewController4 : NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
	
	let	userIsWantingToEditFileAtPath	=	Notifier<String>()
	
	private	var	_fileTreeRepository		=	nil as FileTreeRepository4?
	private	var	_fileSystemMonitor		=	nil as FileSystemMonitor2?
	
	private var	_channelsHolding:Any	=	()
	
	var URLRepresentation:NSURL? {
		get {
			return	self.representedObject as NSURL?
		}
		set(v) {
			self.representedObject	=	v
		}
	}

	
	
	
	
	override var representedObject:AnyObject? {
		willSet(v) {
			precondition(v is NSURL)
			_channelsHolding	=	()
			_fileSystemMonitor	=	nil
			_fileTreeRepository	=	nil
		}
		didSet {
			if let v3 = URLRepresentation {
				_fileTreeRepository	=	FileTreeRepository4(rootlink: v3)
				_fileTreeRepository!.reload()
				
				_fileSystemMonitor	=	FileSystemMonitor2(rootLocationToMonitor: v3)
			}
			self.outlineView.reloadData()
			
			_channelsHolding	=	connectMonitorToTree(_fileSystemMonitor!, _fileTreeRepository!, outlineView)
		}
	}
	
	var outlineView:NSOutlineView {
		get {
			return	self.view as NSOutlineView
		}
		set(v) {
			self.view	=	v
		}
	}
	override func loadView() {
		super.view	=	NSOutlineView()
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let	col1	=	NSTableColumn(identifier: NAME, title: "Name", width: 100)

		outlineView.focusRingType	=	NSFocusRingType.None
		outlineView.headerView		=	nil
		outlineView.addTableColumn <<< col1
		outlineView.outlineTableColumn		=	col1
		outlineView.rowSizeStyle			=	NSTableViewRowSizeStyle.Small
		outlineView.selectionHighlightStyle	=	NSTableViewSelectionHighlightStyle.SourceList
		outlineView.sizeLastColumnToFit()
		
		outlineView.setDataSource(self)
		outlineView.setDelegate(self)
	}
	
	
	
	
//	func outlineView(outlineView: NSOutlineView, heightOfRowByItem item: AnyObject) -> CGFloat {
//		return	16
//	}
	
	func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
		let	n1	=	item as FileNode4?
		if let n2 = n1 {
			if n2.subnodes.count == 0 {
				n2.reloadSubnodes()
			}
			return	n2.subnodes.count
		} else {
			return	_fileTreeRepository?.root == nil ? 0 : 1
		}
	}
	func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
		let	n1	=	item as FileNode4?
		if let n2 = n1 {
			return	n2.subnodes[index]
		} else {
			return	_fileTreeRepository!.root!
		}
	}
//	func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
//		let	n1	=	item as FileNode4
//		let	ns2	=	n1.subnodes
//		return	ns2 != nil
//	}
	func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
		let	n1	=	item as FileNode4
		return	n1.directory
	}
//	func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
//		let	n1	=	item as FileNode4
//		return	n1.relativePath
//	}
	func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
		let	tv1	=	NSTextField()
		let	iv1	=	NSImageView()
		let	cv1	=	NSTableCellView()
		cv1.textField	=	tv1
		cv1.imageView	=	iv1
		cv1.addSubview(tv1)
		cv1.addSubview(iv1)

		///	Do no query on file-system here.
		///	The node is a local cache, and may not exist on 
		///	underlying file-system. 
		///	This is especially true for kqueue/GCD notification.
		///	GCD VNODE notifications are fired asynchronously, and
		///	the actual file can be already gone at the time of the
		///	notification arrives. In other words, file operation
		///	does not wait for notification returns.
		///	So do not query on file-system at this point, and just
		///	use cached data on the node.
		
		let	n1	=	item as FileNode4
		iv1.image						=	n1.icon
		cv1.textField!.stringValue		=	n1.displayName
		cv1.textField!.bordered			=	false
		cv1.textField!.backgroundColor	=	NSColor.clearColor()
		cv1.textField!.editable			=	false
		(cv1.textField!.cell() as NSCell).lineBreakMode	=	NSLineBreakMode.ByTruncatingHead
		return	cv1
	}
	
	
	
	func outlineViewSelectionDidChange(notification: NSNotification) {
//		let	idx1	=	self.outlineView.selectedRow
//		let	n1		=	self.outlineView.itemAtRow(idx1) as FileNode4
//		userIsWantingToEditFileAtPath.signal(n1.absolutePath)
	}
	func outlineViewItemDidCollapse(notification: NSNotification) {
		assert(notification.name == NSOutlineViewItemDidCollapseNotification)
		let	n1	=	notification.userInfo!["NSObject"]! as FileNode4
		n1.resetSubnodes()
	}
}


























private let	NAME	=	"NAME"






///	Keep the returned object to keep the connection.
private func connectMonitorToTree(m:FileSystemMonitor2, t:FileTreeRepository4, v:NSOutlineView) -> Any {
	unowned let	v2	=	v
	func onFileEvent(u:NSURL) {
		assert(NSThread.currentThread() == NSThread.mainThread())
		
		let	u2	=	u.URLByDeletingLastPathComponent!
		
		//	File-system notifications are sent asynchronously, then
		//	a file-node always can not nil for the URL.
		if let n1 = t[u2] {
			n1.reloadSubnodes()
			v2.reloadItem(n1, reloadChildren: true)
		}
	}
	return	channel(m.notifyEventForURL, onFileEvent)
}











