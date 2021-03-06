//
//  AppDelegate.swift
//  WorkbenchApp2
//
//  Created by Hoon H. on 2015/02/02.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Cocoa
import LLDBWrapper
import EditorDebuggingFeature




@NSApplicationMain
class AppDelegate: NSResponder, NSApplicationDelegate, ListenerControllerDelegate, ExecutionStateTreeViewControllerDelegate {
	
	@IBOutlet weak var mainWindow: NSWindow!
	@IBOutlet weak var localVariableWindow: NSWindow!
	
	let	tv1		=	ExecutionStateTreeViewController()
	let	tv2		=	VariableTreeViewController()
	
	let	dbg		=	LLDBDebugger()
	let	lcon	=	ListenerController()

	func executionStateTreeViewControllerDidSelectFrame(frame: LLDBFrame?) {
		tv2.snapshot	=	VariableTreeViewController.Snapshot(frame)
	}
	
	func applicationDidFinishLaunching(aNotification: NSNotification) {
		mainWindow!.appearance			=	NSAppearance(named: NSAppearanceNameVibrantDark)
		localVariableWindow!.appearance	=	NSAppearance(named: NSAppearanceNameVibrantDark)
		
		////
		
		tv1.delegate	=	self
		
		mainWindow.contentView			=	tv1.view
		localVariableWindow.contentView	=	tv2.view
		
		
		dbg.async		=	true
		lcon.delegate	=	self
		
		////
		
		self.performMenuLaunchTarget(self)
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		lcon.stopListening()
		for t in dbg.allTargets {
			t.process.stop()
		}
	}

	
	
	
	@IBAction
	func performContinue(AnyObject?) {
		let	t	=	dbg.allTargets.first!
		t.process.`continue`()
	}
	@IBAction
	func performStop(AnyObject?) {
		let	t	=	dbg.allTargets.first!
		t.process.stop()
	}
	@IBAction
	func performStepInto(AnyObject?) {
		let	t	=	dbg.allTargets.first!
		t.process.allThreads.first!.stepInto()
	}
	@IBAction 
	func performStepOver(AnyObject?) {
		let	t	=	dbg.allTargets.first!
		t.process.allThreads.first!.stepOver()
	}
	@IBAction
	func performStepOut(AnyObject?) {
		let	t	=	dbg.allTargets.first!
		t.process.allThreads.first!.stepOut()
	}
	
	@IBAction
	func performMenuLaunchTarget(AnyObject?) {
		let	f	=	NSBundle.mainBundle().bundlePath.stringByDeletingLastPathComponent.stringByAppendingPathComponent("Sample1")
		assert(NSFileManager.defaultManager().fileExistsAtPath(f))
		
//		let	t	=	dbg.createTargetWithFilename(f, andArchname: LLDBArchDefault)
		let	t	=	dbg.createTargetWithFilename(f)
		let	b	=	t.createBreakpointByName("main")
		b.enabled	=	true
		
		let	p	=	t.launchProcessSimplyWithWorkingDirectory(f.stringByDeletingLastPathComponent)
		precondition(p.state == LLDBStateType.Stopped)
		
//		println(t.triple())
//		println(p.state.rawValue)
//		println(p.allThreads[0].allFrames[0]?.lineEntry)
//		println(p.allThreads[0].allFrames[0]?.functionName)
//		
////		tv1.debugger	=	dbg
////		if let f = dbg.allTargets.first?.process.allThreads.first?.allFrames.first {
////			tv2.data	=	f
////		}
		
		lcon.startListening()
		p.addListener(lcon.listener, eventMask: LLDBProcess.BroadcastBit.StateChanged)
		
		//	Do not call `continue` on asynchronous debugger.
		//	It will stop at first if you call on it. Unexpected behavior.
//		p.`continue`()
	}
	
	@IBAction
	func performMenuStopProcess(AnyObject?) {
		let	t	=	dbg.allTargets.first!
		t.process.stop()
	}
	@IBAction
	func performMenuKillProcess(AnyObject?) {
		let	t	=	dbg.allTargets.first!
		t.process.kill()
	}
	@IBAction
	func performMenuDeleteTarget(AnyObject?) {
		let	t	=	dbg.allTargets.first!
		dbg.deleteTarget(t)
		tv1.snapshot	=	nil
		tv2.snapshot	=	nil
	}

	
	func listenerControllerIsProcessingEvent(e: LLDBEvent) {
		tv1.snapshot	=	ExecutionStateTreeViewController.Snapshot(dbg)
		if let f = dbg?.allTargets.first?.process.allThreads.first?.allFrames.first, f1 = f {
			tv2.snapshot	=	VariableTreeViewController.Snapshot(f1)
		} else {
			tv2.snapshot	=	nil
		}
		
//		if let t = dbg.allTargets.first {
//			let	p	=	t.process
//			switch p.state {
//			case .Running:
//				tv1.snapshot	=	nil
//				tv2.snapshot	=	nil
//				
//			default:
//				tv1.snapshot	=	ExecutionStateTreeViewController.Snapshot(dbg)
//				if let f = dbg?.allTargets[0].process.allThreads[0].allFrames.first, f1 = f {
//					tv2.snapshot	=	VariableTreeViewController.Snapshot(f1)
//				} else {
//					tv2.snapshot	=	nil
//				}
//			}
//		}
	}
	
	
}




































