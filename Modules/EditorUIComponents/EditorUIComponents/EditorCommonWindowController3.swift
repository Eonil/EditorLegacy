//
//  EditorCommonWindowController3.swift
//  EditorUIComponents
//
//  Created by Hoon H. on 2015/02/21.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit


///	A window controller which fixes some insane behaviors.
///
///	-	This creates and binds `contentViewController` itself. You can override instantiation of it.
///	-	This creates and binds `window` by calling `loadWindow` and that calls `instantiateWindow` method.
///	-	This sends `windowDidLoad` message after loading window.
///	-	So, `window` is always a non-`nil` value. And also you cannot set `nil` to `window`.
///
///	Do not override any initialiser. Instead, override `windowDidLoad` to setup thigns.
///	This is intentional design to prevent weird OBJC instance replacement behavior.
///
///	**Notice**
///
///	This class does not support use in Interface Builder
public class EditorCommonWindowController3 : NSWindowController {
	
	///	Designated initialiser.
	public required init() {
		super.init(window: nil)
		
		loadWindow()		//	This doesn't being called automatically. Need to be called manually.
		windowDidLoad()		//	This doesn't being called automatically. Need to be called manually.
	}
	
	@availability(*,unavailable)
	public required init?(coder: NSCoder) {
		fatalError("This class `\(EditorCommonWindowController3.self)` does not support IB.")
	}
	@availability(*,unavailable)
	override convenience init(window: NSWindow?) {
		fatalError("This class `\(EditorCommonWindowController3.self)` does not support setting window object.")
	}
	@availability(*,unavailable)
	public convenience init(windowNibName:String) {
		fatalError("This initializer is not supported.")
	}
	@availability(*,unavailable)
	public convenience init(windowNibName:String, owner:AnyObject) {
		fatalError("This initializer is not supported.")
	}
	@availability(*,unavailable)
	public convenience init(windowNibPath:String, owner:AnyObject) {
		fatalError("This initializer is not supported.")
	}

	
	
	
	
	public override var window:NSWindow! {
		get {
			assert(super.window !== nil, "Current `window` is `nil` which means logic bug.")
			return	super.window
		}
		set(v) {
			precondition(v != nil, "`nil` is not allowed for `window`.")
		}
	}
	
	
	
	
	///	Don't call this. Intended for internal use only.
//	@availability(*,unavailable)
	public final override func loadWindow() {
		super.window	=	instantiateWindow()
	}
	
	///	Designed to be overridable.
	///	You must call super-implementation.
	///	`window` property is always be non-`nil` at this point.
	public override func windowDidLoad() {
		super.windowDidLoad()
		super.window!.contentViewController	=	instantiateContentViewController()
	}
	
	
	
	
	
	///	Unsupported.
	@availability(*,unavailable)
	public override var windowNibPath:String! {
		get {
			fatalError("`windowNibPath` property is not supported.")
		}
	}
	///	Unsupported.
	@availability(*,unavailable)
	public override var windowNibName:String! {
		get {
			fatalError("`windowNibName` property is not supported.")
		}
	}
	
	
	
	
	
	
	
	///	Intended to be overriden.
	///	Override if you want to provide custom subclass window object.
	public func instantiateWindow() -> NSWindow {
		let	w1	=	NSWindow()
		w1.styleMask	|=	NSResizableWindowMask | NSTitledWindowMask | NSMiniaturizableWindowMask | NSClosableWindowMask
		return	w1
	}
	
	///	Intended to be overriden.
	///	Override if you want to provide custom subclass view-controller object.
	public func instantiateContentViewController() -> NSViewController {
		return	EmptyViewController(nibName: nil, bundle: nil)!
	}
	
	public final override var contentViewController:NSViewController? {
		get {
			return	super.window!.contentViewController
		}
		@availability(*,unavailable)
		set(v) {
			fatalError("You cannot set `contentViewController` directly. Instead, override `instantiateContentViewController` method to customise its class.")
		}
	}
}








private extension EditorCommonWindowController3 {
	
	///	A view controller to suppress NIB searching error.
	@objc
	private class EmptyViewController: NSViewController {
		private override func loadView() {
			super.view	=	NSView()
		}
	}
}

