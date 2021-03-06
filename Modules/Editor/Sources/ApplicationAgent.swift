//
//  ApplicationAgent.swift
//  Editor
//
//  Created by Hoon H. on 2015/01/12.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Cocoa
import EditorCommon
import EditorUIComponents
import EditorModel










///	Central control of the app.
///
///
///
///	**Menu Management**
///
///	Currently, menus are not well designed. I just use NIB and static binding for static menus.
///	Dynamic menus will be managed by `MenuController` subclasses. See `MenuControllers.swift` for
///	all available dynamic menus. Here're basic rules.
///
///	1.	Instantiate and use each dynamic menus with default state. Menu items usually no-op.
///	2.	Swaps menu items by context. Queries current context when opening a menu.
///	3.	Swap back to default state menu if there's no special context.
///
///	Conceptually, each document has their own menu instances. All those menus are mostly same
///	except some states. This object just manages swapping between menu instances for current state.
///
///	NIBs are just temporal form, and will be replaced by code-driven implementation as soon as I
///	finish more important features. Currently it's low on priority.
@NSApplicationMain
class ApplicationAgent: NSObject, NSApplicationDelegate {
	
	
	@IBOutlet
	var projectMenu:NSMenuItem?
	
	@IBOutlet
	var debugMenu:NSMenuItem?
	
	var currentWorkspaceDocument:WorkspaceDocument? {
		get {
			if let w = NSApplication.sharedApplication().mainWindow {
				if let d = (NSDocumentController.sharedDocumentController() as! NSDocumentController).documentForWindow(w) as! WorkspaceDocument? {
					return	d
				}
			}
			return	nil
		}
	}
	
	private let	_dynamicMenuAgent	=	ADHOC_DynamicMenuAgent()
	
	private func _attachMenus() {
		projectMenu!.submenu		=	_dynamicMenuAgent.projectMenu
		debugMenu!.submenu		=	_dynamicMenuAgent.debugMenu
	}
	private func _detachMenus() {
		debugMenu!.submenu		=	nil
		projectMenu!.submenu		=	nil
	}
}


//
//final class DefaultMenuControllerPalette {
//	static let	project	=	ProjectMenuController()
//	static let	debug	=	DebugMenuController()
//}










///	MARK:
///	MARK:	Application Lifecycle Management
extension ApplicationAgent {
	
	func applicationWillFinishLaunching(notification: NSNotification) {
		NSUserDefaults.standardUserDefaults().setBool(true, forKey: "NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints")
	}
	
	func applicationDidFinishLaunching(aNotification: NSNotification) {
		_attachMenus()
	}
	
	func applicationWillTerminate(aNotification: NSNotification) {
		_detachMenus()
	}
}













///	MARK:
///	MARK:	Document Handling
extension ApplicationAgent {
	func applicationShouldOpenUntitledFile(sender: NSApplication) -> Bool {
		return	false
	}
}














///	MARK:
///	MARK:	Global Menu Handlers

///	"Open" always opens an existing workspace. There's no concept of opening a data file.
///	"Save" family menus save currently editing data file.
///
extension ApplicationAgent {
	
	///	Creates a new workspace.
	///	User will be asked to select a directory to store new workspace.
	@objc @IBAction
	func newDocument(AnyObject?) {
		let	p		=	NSSavePanel()
		p.beginWithCompletionHandler { (r:Int) -> Void in
			switch r {
			case NSFileHandlingPanelOKButton:
				if let u = p.URL {
					let	workspaceDirFileURL		=	u
					if workspaceDirFileURL.existingAsAnyFile {
						//	If a URL to an existing file item, that means user confirmed overwriting of the whole directory tree.
						//	Anyway, move them to the system Trash instead of deleting it for safety.
						//	Operation may fail, regardless of file existence when we check before due to asynchronous nature of file system.
						//	Just try and check returning error to handle bad situations.
						var	trashingError		=	nil as NSError?
						NSFileManager.defaultManager().trashItemAtURL(workspaceDirFileURL, resultingItemURL: nil, error: &trashingError)
						
						if let e = trashingError {
							NSApplication.sharedApplication().presentError(e)
							//						UIDialogues.alertModally("Couldn't move the existing workspace to Trash.", comment: "There was an error while trashing it.", style: NSAlertStyle.WarningAlertStyle)
							return
						}
					}
					
					////
					
					if let workspaceConfigFileURL = WorkspaceUtility.createNewWorkspaceAtURL(workspaceDirFileURL) {
						//	Try opening newrly created project as a document.
						//	Ignore failure.
						NSDocumentController.sharedDocumentController().openDocumentWithContentsOfURL(workspaceConfigFileURL, display: true, completionHandler: { (document:NSDocument!, documentWasAlreadyOpen:Bool, error:NSError!) -> Void in
							//	Nothing to do.
						})
					} else {
						UIDialogues.alertModally("Could not create a project with the name.", comment: nil, style: NSAlertStyle.InformationalAlertStyle)
					}
				} else {
					//	Unknown situation. Ignore it.
				}
				
			case NSFileHandlingPanelCancelButton:
				//	Ignore cancellation.
				break
				
			default:
				fatalError()
			}
		}
	}
	
	@objc @IBAction
	func newDataFile(AnyObject?) {
		
	}
}
























