//
//  WorkspaceMainWindowController.swift
//  Editor
//
//  Created by Hoon H. on 2015/01/12.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit
import AppKitExtras
import SignalGraph
import EditorCommon
import EditorUIComponents
import EditorWorkspaceNavigationFeature
import EditorIssueListingFeature
import EditorDebuggingFeature
import EditorModel





class WorkspaceMainWindowController: NSWindowController {
	init() {
		super.init(window: _makeMainWindow())
		_connectWindowEvents()
	}
	@availability(*,unavailable)
	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	deinit {
		assert(_connected == false)
		assert(_installed == false)
	}
	
	///	You MUST set this BEFORE adding this view to a window
	///	and should not change until this view to be removed from the window.
	weak var shell: Shell? {
		willSet {
			if shell != nil {
				_disconnect()
				_deinstall()
			}
		}
		didSet {
			if shell != nil {
				_install()
				_connect()
			}
		}
	}
	
	@availability(*,unavailable)
	override func loadWindow() {
		super.loadWindow()
	}
	@availability(*,unavailable)
	override func windowDidLoad() {
		super.windowDidLoad()
	}
	
	///

	private let 	_windowAgent	=	_OBJCWindowAgent()
	
	private let	_firstPaneOpts	=	FirstPaneDisplayOptions()
	
	private let	_paneDispOpts	=	PaneDisplayOptions()
	private let	_navDispSync	=	ValueStorageEqualizer<Bool>()
	private let	_inspDispSync	=	ValueStorageEqualizer<Bool>()
	
	private var	_installed	=	false
	private var	_connected	=	false
	private var	_toolbarCon	:	ToolbarController?
	private var	_mainView	:	MainView?
	
	private func _connectWindowEvents() {
		assert(window!.delegate === nil)
		_windowAgent.owner	=	self
		window!.delegate	=	_windowAgent
	}
	private func _disconnectWindowEvents() {
		assert(window!.delegate === _windowAgent)
		window!.delegate	=	nil
		_windowAgent.owner	=	nil
	}
	
	private func _install() {
		typealias	ToolItem	=	ToolbarController.ToolItem
		assert(_installed == false)
		assert(_connected == false)
		
		_firstPaneOpts.install()
		_firstPaneOpts.segmentstrip.sizeToFit()
		
		_paneDispOpts.shell	=	shell
		_paneDispOpts.segmentstrip.sizeToFit()
		
		_toolbarCon				=	ToolbarController(identifier: "MainWindowToolbar")
		_toolbarCon!.configuration		=	[
			_customViewToolItem("Navigation", _firstPaneOpts.segmentstrip),
			ToolbarController.ToolItem.flexibleSpace(),
			_customViewToolItem("Panes", _paneDispOpts.segmentstrip),
		]
		_toolbarCon!.toolbar.displayMode	=	NSToolbarDisplayMode.IconAndLabel
		_mainView			=	MainView()
		window!.toolbar			=	_toolbarCon!.toolbar
		window!.contentView		=	_mainView!
		window!.titleVisibility		=	NSWindowTitleVisibility.Hidden
		_installed			=	true
	}
	private func _deinstall() {
		assert(_installed == true)
		assert(_connected == false)
		window!.contentView		=	NSView()
		window!.toolbar			=	nil
		_mainView			=	nil
		_toolbarCon!.configuration	=	nil
		_toolbarCon			=	nil
		_paneDispOpts.shell		=	nil
		_firstPaneOpts.deinstall()
		_installed			=	false
	}
	
	private func _connect() {
		assert(_connected == false)
		assert(shell != nil)
		_mainView!.shell		=	shell!
		_navDispSync.storages.snapshot	=	[shell!.navigatorPaneDisplay, _paneDispOpts.navigator.selection]
		_inspDispSync.storages.snapshot	=	[shell!.inspectorPaneDisplay, _paneDispOpts.inspector.selection]
		_connected			=	true
	}
	private func _disconnect() {
		assert(_connected == true)
		assert(shell != nil)
		_inspDispSync.storages.snapshot	=	[]
		_navDispSync.storages.snapshot	=	[]
		_mainView!.shell		=	nil
		_connected			=	false
	}
	
}

@objc
private class _OBJCWindowAgent: NSObject, NSWindowDelegate {
	weak var owner: WorkspaceMainWindowController?
	
	private func windowDidChangeScreen(notification: NSNotification) {
//		assert(owner != nil)
//		assert(notification.object === owner!.window)
//		if let owner = owner {
//			if owner.window!.screen == nil {
//				owner._deinstall()
//				owner._disconnect()
//			} else {
//				owner._connect()
//				owner._install()
//			}
//		}
	}
	
	@objc
	func windowWillClose(notification: NSNotification) {
		assert(owner != nil)
		assert(notification.object === owner!.window)
		if let owner = owner {
			owner._disconnectWindowEvents()
		}
	}
}

private func _makeMainWindow() -> NSWindow {
	let	window		=	NSWindow()
	window.styleMask	=	NSResizableWindowMask | NSTitledWindowMask | NSMiniaturizableWindowMask | NSClosableWindowMask
	
	let	USE_DARK_MODE	=	true
	if USE_DARK_MODE {
//		window.titlebarAppearsTransparent	=	true
		window.appearance			=	NSAppearance(named: NSAppearanceNameVibrantDark)
		window.invalidateShadow()
		
		func makeDark(b:NSButton, alpha:CGFloat) {
			let	f	=	CIFilter(name: "CIColorMonochrome")
			f.setDefaults()
//			f.setValue(CIColor(red: 0.5, green: 0.3, blue: 0.5, alpha: alpha), forKey: "inputColor")		//	I got this number accidentally, and I like this tone.
			f.setValue(CIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: alpha), forKey: "inputColor")
//
//			let	f1	=	CIFilter(name: "CIGammaAdjust")
//			f1.setDefaults()
//			f1.setValue(0.3, forKey: "inputPower")
//
//			let	f2	=	CIFilter(name: "CIColorInvert")
//			f2.setDefaults()
			
			b.contentFilters	=	[f]
		}
		
		makeDark(window.standardWindowButton(NSWindowButton.CloseButton)!, 1.0)
		makeDark(window.standardWindowButton(NSWindowButton.MiniaturizeButton)!, 1.0)
		makeDark(window.standardWindowButton(NSWindowButton.ZoomButton)!, 1.0)
	}
	return	window
}






class FirstPaneDisplayOptions {
	let	segmentstrip	=	OptionSegmentstripPiece()
	
	let	files		=	OptionSegment()
	let	callstack	=	OptionSegment()
	let	variables	=	OptionSegment()
	
	init() {
	}
	deinit {
	}
	
	weak var model: Shell? {
		willSet {
			assert(_installed == false)
		}
	}
	
	func install() {
		files.text.state		=	"Files"
		callstack.text.state		=	"Calls"
		variables.text.state		=	"Vars"
		
		segmentstrip.configuration	=
			OptionSegmentstripPiece.Configuration(
				selectionMode	:	OptionSegmentstripPiece.SelectionMode.One,
				optionSegments	:	[
					files,
					callstack,
					variables,
				])
		_installed			=	true
	}
	func deinstall() {
		segmentstrip.configuration	=	nil
		_installed			=	false
	}
	
	private var	_installed		=	false
}






class PaneDisplayOptions {
	let	segmentstrip	=	OptionSegmentstripPiece()
	
	let	navigator	=	OptionSegment()
	let	console		=	OptionSegment()
	let	inspector	=	OptionSegment()
	
	init() {
	}
	deinit {
		assert(_installed == false)
	}
	
	weak var shell: Shell? {
		willSet {
			if shell != nil {
				_deinstall()
			}
		}
		didSet {
			if shell != nil {
				_install()
			}
		}
	}
	
	///
	
	private var	_installed		=	false
	
	private func _install() {
		assert(_installed == false)
		navigator.text.state		=	"Navigator"
		console.text.state		=	"Console"
		inspector.text.state		=	"Inspector"
		
		segmentstrip.configuration	=
			OptionSegmentstripPiece.Configuration(
				selectionMode	:	OptionSegmentstripPiece.SelectionMode.Any,
				optionSegments	:	[
					navigator,
					console,
					inspector,
				])
		
		_installed	=	true
	}
	private func _deinstall() {
		assert(_installed == true)
		segmentstrip.configuration	=	nil
		
		_installed	=	false
	}
}






//private func _plainButtonToolItem(label: String, handler: ()->()) -> ToolbarController.ToolItem {
//	return	ToolbarController.ToolItem(label: label, size: (CGSize.zeroSize, CGSize.zeroSize), view: nil, handler: handler, _itemIdentifier: _makeID())
//}
private func _customViewToolItem(label: String, view: NSView) -> ToolbarController.ToolItem {
	let	sz	=	(view.frame.size, view.frame.size)
	return	ToolbarController.ToolItem(identifier: _makeID(), label: label, size: sz, view: view, handler: {})
}

private func _makeID() -> String {
	Debug.assertMainThread()
	struct Local {
		static var	seed	=	0
	}
	Local.seed++
	return	"ToolbarController.ToolItem.ItemIdentifier.AUTOGENERATION#\(Local.seed)"
}





//func findTextField(v: NSView) -> [NSTextField] {
//	var	fs	=	[] as [NSTextField]
//	if let v1 = v as? NSTextField {
//		fs.append(v1)
//	}
//	for v1 in v.subviews {
//		fs.extend(findTextField(v1 as! NSView))
//	}
//	return	fs
//}
//






