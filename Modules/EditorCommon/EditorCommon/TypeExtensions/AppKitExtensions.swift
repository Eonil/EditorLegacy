//
//  AppKitExtensions.swift
//  RustCodeEditor
//
//  Created by Hoon H. on 11/11/14.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation
import AppKit




public extension NSSplitViewController {
	func addChildViewControllerAsASplitViewItem(childViewController: NSViewController) {
		self.addChildViewController(childViewController)
		self.addSplitViewItem(NSSplitViewItem(viewController: childViewController))
	}
}

public extension NSViewController {
//	var childViewControllers:[NSViewController] {
//		get {
//			
//		}
//	}
	func indexOfChildViewController(vc:NSViewController) -> Int? {
		for i in 0..<self.childViewControllers.count {
			let	vc1	=	self.childViewControllers[i] as! NSViewController
			if vc1 === vc {
				return	i
			}
		}
		return	nil
	}
	func removeChildViewController<T:NSViewController>(vc:T) {
		precondition(vc.parentViewController === self, "The view-controller is not a child of this view-controller.")
		
		if let idx1 = self.indexOfChildViewController(vc) {
			self.removeChildViewControllerAtIndex(idx1)
		} else {
			fatalError("The view-controller is not a child of this view-controller.")
		}
	}
}


public extension NSView {
	var layoutConstraints:[NSLayoutConstraint] {
		get {
			return	self.constraints as! [NSLayoutConstraint]
		}
		set(v) {
			let	cs1	=	self.constraints
			self.removeConstraints(cs1)
			assert(self.constraints.count == 0)
			self.addConstraints(v as [AnyObject])
		}
	}
}

public extension NSTextView {
//	var selectedRanges:[NSRange] {
//		get {
//			return	self.selectedRanges.map({$0.rangeValue})
//		}
//		set(v) {
//			self.selectedRanges	=	v.map({NSValue(range: $0)})
//		}
//	}
}

public extension NSTableColumn {
	convenience init(identifier:String, title:String) {
		self.init(identifier: identifier)
		self.title		=	title
	}
	convenience init(identifier:String, title:String, width:CGFloat) {
		self.init(identifier: identifier)
		self.title		=	title
		self.width		=	width
	}
}




public extension NSLayoutManager {
	
}




public extension NSMenu {
	func addSeparatorItem() {
		let	m	=	NSMenuItem.separatorItem()
		self.addItem(m)
	}
	var allMenuItems:[NSMenuItem] {
		get {
			return	self.itemArray.map({ a in a as! NSMenuItem })
		}
		set(v) {
			self.removeAllItems()
			v.map(self.addItem)
		}
	}
}
public extension NSMenuItem {
	var	onAction:(()->())? {
		get {
			let	c1	=	ObjC.getStrongAssociationOf(self, key: Keys.MENU_REACTION) as! TargetActionFunctionBox?
			return	c1?.function
		}
		set(v) {
			let	c1	=	v == nil ? nil as TargetActionFunctionBox? : TargetActionFunctionBox(v!)
			self.target	=	c1
			self.action	=	c1 == nil ? "" : c1!.action
			ObjC.setStrongAssociationOf(self, key: Keys.MENU_REACTION, value: c1)
		}
	}

	private struct Keys {
		static let	MENU_REACTION	=	UnsafeMutablePointer<Void>.alloc(1)
	}
	
	convenience init(title:String, reaction:()->()) {
		self.init()
		self.title		=	title
		self.onAction		=	reaction
	}
}


public extension NSColor {
	class func withUInt8Components(red r:UInt8, green g:UInt8, blue b:UInt8, alpha a:UInt8) -> NSColor {
		return	NSColor(SRGBRed: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
	}
}




