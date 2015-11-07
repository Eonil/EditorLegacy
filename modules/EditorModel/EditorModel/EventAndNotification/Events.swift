//
//  Events.swift
//  EditorModel
//
//  Created by Hoon H. on 2015/10/25.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation
import EditorCommon


// In C/C++ or Rust, we can use pointers to identify a value-type storage.
// But Swift does not support such thing, so we have to figure out something else.
// And of course, there's no good way.
//
// Having an explicit identity using reference-type will double-up object tree depth.
// So we just don't try to identify them using pointers. We just identify them using 
// names manually.




public extension ApplicationModel {
	public enum Event: BroadcastableEventType {
		public typealias	Sender	=	ApplicationModel
		case DidInitiate
		case WillTerminate
		case DidAddWorkspace(WorkspaceModel)
		case WillRemoveWorkspace(WorkspaceModel)
		case DidBeginCurrentWorkspace(WorkspaceModel)
		case WillEndCurrentWorkspace(WorkspaceModel)
	}
}

public extension WorkspaceModel {
	public enum Event: BroadcastableEventType {
		public typealias	Sender	=	WorkspaceModel
		case DidInitiate
		case WillTerminate
		case WillRelocate(from: NSURL?, to: NSURL?)
		case DidRelocate(from: NSURL?, to: NSURL?)
	}
}

public extension FileTreeModel {
	public enum Event: BroadcastableEventType {
		public typealias	Sender	=	FileTreeModel
		case DidCreateRoot(root: FileNodeModel)
		case WillDeleteRoot(root: FileNodeModel)
		case NodeEvent(sender: FileNodeModel, event: FileNodeModel.Event)
	}
}

public extension FileNodeModel {
	public enum Event: BroadcastableEventType {
		public typealias	Sender	=	FileNodeModel
		case DidInsertSubnode(subnode: FileNodeModel, index: Int)
		case WillDeleteSubnode(subnode: FileNodeModel, index: Int)
		case WillChangeGrouping(old: Bool, new: Bool)
		case DidChangeGrouping(old: Bool, new: Bool)
		case WillChangeName(old: String, new: String)
		case DidChangeName(old: String, new: String)
		case WillChangeComment(old: String?, new: String?)
		case DidChangeComment(old: String?, new: String?)
	}
}

public extension BuildModel {
	public enum Event: BroadcastableEventType {
		public typealias	Sender	=	BuildModel
		case WillChangeRunnableCommand
		case DidChangeRunnableCommand
	}
}

public extension DebuggingModel {
	public enum Event: BroadcastableEventType {
		public typealias	Sender	=	DebuggingModel
		case WillChangeCurrentTarget
		case DidChangeCurrentTarget
		case WillChangeTargetList
		case DidChangeTargetList
		case WillChangeSelection
		case DidChangeSelection
		case TargetEvent(sender: DebuggingTargetModel, event: DebuggingTargetModel.Event)
	}
}

public extension DebuggingTargetModel {
	public enum Event: BroadcastableEventType {
		public typealias	Sender	=	DebuggingTargetModel
		case StartExecution(execution: DebuggingTargetExecutionModel)
		case EndExecution(execution: DebuggingTargetExecutionModel)
		case ExecutionEvent(sender: DebuggingTargetExecutionModel, event: DebuggingTargetExecutionModel.Event)
	}
}

public extension DebuggingTargetExecutionModel {
	public enum Event: BroadcastableEventType {
		public typealias	Sender	=	DebuggingTargetExecutionModel
		case WillChangeState(state: DebuggingTargetExecutionModel.State)
		case DidChangeState(state: DebuggingTargetExecutionModel.State)
		case WillChangeRunnableCommands(commands: Set<DebuggingCommand>)
		case DidChangeRunnableCommands(commands: Set<DebuggingCommand>)
	}
}



public extension ConsoleModel {
	public enum Event: BroadcastableEventType {
		public typealias	Sender	=	ConsoleModel
		case DidClear
		case DidAddLines(range : Range<Int>)
	}
}
























