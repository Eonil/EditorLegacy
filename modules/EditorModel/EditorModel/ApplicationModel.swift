//
//  ApplicationModel.swift
//  EditorShell
//
//  Created by Hoon H. on 2015/08/14.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation
import MulticastingStorage
import EditorCommon



/// A model for application.
/// This manages whole application state, not only single document
/// or something else.
/// This exists for application, and designed toward to GUI.
///
/// **ALL** features of this object and subnodes must run in
/// main thread. Any non-main thread operations should be
/// performed with special care. Also, you must minimize performing
/// heavy load operations in main thread.
///
/// Current window is trackable, but current window selection algorithm
/// is hidden and complex, so it's impractical to synchronize it by model.
/// And I removed `currentWorkspace`. Find current workspace from UI graph.
///
public class ApplicationModel: ModelRootNode, BroadcastingModelType {

	public override init() {
//		let	a	=	ToolLocationResolver.cargoToolLocation()
//		assert(a == "/Users/Eonil/Unix/homebrew/bin/cargo")
	}
	deinit {
		assert(currentWorkspace == nil)
	}

	///

	public let event	=	EventMulticast<Event>()

	///

	public private(set) var workspaces: ObjectSet<WorkspaceModel> = [] {
//		willSet {
//			assert(workspaces.areAllElementsUniqueReferences())
//		}
		didSet {
//			assert(workspaces.areAllElementsUniqueReferences())
		}
	}
	public private(set) weak var currentWorkspace: WorkspaceModel? {
		willSet {
//			assert(isUniquelyReferencedNonObjC(&currentWorkspace))
			if let currentWorkspace = currentWorkspace {
				Event.WillEndCurrentWorkspace(currentWorkspace).dualcastWithSender(self)
			}
//			assert(isUniquelyReferencedNonObjC(&currentWorkspace))
		}
		didSet {
			assert(isUniquelyReferencedNonObjC(&currentWorkspace))
			if let currentWorkspace = currentWorkspace {
				Event.DidBeginCurrentWorkspace(currentWorkspace).dualcastWithSender(self)
			}
			assert(isUniquelyReferencedNonObjC(&currentWorkspace))
		}
	}

	///

	override func didJoinModelRoot() {
		super.didJoinModelRoot()
		_preference.owner	=	self
//		_selection.owner	=	self
	}
	override func willLeaveModelRoot() {
//		_selection.owner	=	nil
		_preference.owner	=	nil
		super.willLeaveModelRoot()
	}

	///

	/// Command-queue will be required eventually... but not right now.
	/// Prefer direct synchronous call to models rather then sending
	/// asynchronous command.
//	public let commandQueue = CommandQueue()

	public var preference: PreferenceModel {
		get {
			return	_preference
		}
	}
//	public var selection: SelectionModel2 {
//		get {
//			return	_selection
//		}
//	}

	///

	/// Just opens a workspace, and create it at the place.
	///
	/// - Parameters:
	///
	///	  - location:
	///
	///		A URL to a file path that will become a workspace.
	///		This location will be created by `cargo` and must
	///		not exist at the point of calling.
	public func createAndOpenWorkspaceAtURL(location: NSURL) throws {
		do {
			try mutateWithGlobalCheck {
				let	ws	=	WorkspaceModel()
				ws.owner	=	self
				ws.location	=	location
				try ws.construct()

				_addWorkspace(ws)
				Debug.log("did create and add a workspace \(ws), ws count = \(workspaces.count)")
			}
		}
//		assert(workspaces.areAllElementsUniqueReferences())
	}

	/// You can supply any URL, and a workspace will be open only if
	/// the URL is valid. If there's already open workspace for the URL,
	/// no new workspace will be created, and the workspace will be
	/// selected.
	public func openWorkspaceAtURL(u: NSURL) {
		do {
			mutateWithGlobalCheck {
				Debug.log("will open a workspace at \(u), ws count = \(workspaces.count)")
				for ws in workspaces {
					if ws.location == u {
						Debug.log("a workspace already exist for address \(u), adding cancelled, and will select it, ws count = \(workspaces.count)")
						//				if let u1 = currentWorkspace.value?.location.value {
						//					if u1 != u {
						////						reselectCurrentWorkspace(ws)
						////						deselectCurrentWorkspace()
						////						selectCurrentWorkspace(ws)
						//					}
						//				}
						return
					}
				}

				///

				let	ws	=	WorkspaceModel()
				ws.owner	=	self
				ws.location	=	u

				_addWorkspace(ws)
				Debug.log("did open by adding a workspace \(ws), ws count = \(workspaces.count)")
			}
		}
//		assert(workspaces.areAllElementsUniqueReferences())
	}

	/// Closes a workspace.
	///
	/// - Parameters:
	///	- ws:
	///		Can be either of current or non-current workspace.
	///
	public func closeWorkspace(ws: WorkspaceModel) {
		assert(workspaces.contains(ws))
		assert(currentWorkspace !== ws)
		mutateWithGlobalCheck {
			do {
				Debug.log("will remove a workspace \(ws), ws count = \(workspaces.count)")

				if currentWorkspace === ws {
					currentWorkspace	=	nil
				}

				_removeWorkspace(ws)
				ws.location	=	nil
				ws.owner	=	nil

				Debug.log("did remove a workspace \(ws), ws count = \(workspaces.count)")
			}
			//		assert(workspaces.areAllElementsUniqueReferences())
		}
	}

	/// Selects another workspace.
	/// 
	/// Current workspace cannot be nil if there's any open workspace.
	/// This limitation is set by Cocoa AppKit because any next window
	/// will be selected automatically.
	public func reselectCurrentWorkspace(workspace: WorkspaceModel?) {
		assert(workspace == nil || workspaces.contains(workspace!))
		assert(workspace != nil || workspaces.count == 1)
		mutateWithGlobalCheck {
			do {
				if currentWorkspace !== workspace {
					currentWorkspace	=	workspace
				}
			}
		}
	}

	///
	
	private let	_preference		=	PreferenceModel()
//	private let	_selection		=	SelectionModel2()





	private func _addWorkspace(workspace: WorkspaceModel) {
		workspaces.insert(workspace)
		Event.DidAddWorkspace(workspace)
	}
	private func _removeWorkspace(workspace: WorkspaceModel) {
		Event.WillRemoveWorkspace(workspace)
		workspaces.remove(workspace)
	}
}













