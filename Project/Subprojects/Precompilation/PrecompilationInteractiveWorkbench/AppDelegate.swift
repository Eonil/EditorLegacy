//
//  AppDelegate.swift
//  PrecompilationInteractiveWorkbench
//
//  Created by Hoon H. on 2015/01/11.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Cocoa
import Precompilation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!


	func applicationDidFinishLaunching(aNotification: NSNotification) {
		UIDialogues.queryDeletingFilesUsingWindowSheet(window, files: [NSURL(string: "AA")!]) { (b:UIDialogueButton) -> () in
			switch b {
			case .OKButton:
				println("OK")
				
			case .CancelButton:
				println("Cancel")
				
			}
		}
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}


}
