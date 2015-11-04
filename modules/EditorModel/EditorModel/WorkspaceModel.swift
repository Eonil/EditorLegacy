//
//  WorkspaceModel.swift
//  EditorShell
//
//  Created by Hoon H. on 2015/08/14.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Foundation
import MulticastingStorage
import EditorCommon





/// A unit for a product.
/// A workspace can contain multiple projects.
///
/// You need to call `locate` to designate location of this
/// workspace. Workspace will be in an empty state until you
/// provide a location.
///
/// A workspace should work with an invalid path without crash.
/// A workspace can work even with `nil` locaiton. Anyway most
/// feature won't work with invalid paths.
///
public class WorkspaceModel: ModelSubnode<ApplicationModel>, BroadcastingModelType {





	///

	public let event	=	EventMulticast<Event>()

	///

	override func didJoinModelRoot() {
		super.didJoinModelRoot()

		file.owner		=	self
		search.owner		=	self
		build.owner		=	self
		debug.owner		=	self
		report.owner		=	self
		console.owner		=	self
		cargo.owner		=	self
		UI.owner		=	self
	}
	override func willLeaveModelRoot() {
		super.willLeaveModelRoot()

		UI.owner		=	nil
		cargo.owner		=	nil
		console.owner		=	nil
		report.owner		=	nil
		debug.owner		=	nil
		build.owner		=	nil
		search.owner		=	nil
		file.owner		=	nil
	}

	///

	public var application: ApplicationModel {
		get {
			assert(owner != nil)
			return	owner!
		}
	}

	public let	file		=	FileTreeModel()
	public let	search		=	SearchModel()
	public let	build		=	BuildModel()
	public let	debug		=	DebuggingModel()
	public let	report		=	ReportingModel()
	public let	console		=	ConsoleModel()

	public let	UI		=	WorkspaceUIModel()

	internal let	cargo		=	CargoModel()

	///

	/// A location for a project can be changed to provide smoother
	/// user experience.
	/// For instance, user can move workspace directory to another
	/// location, and we can just replace location without re-creating
	/// whole workspace UI.
	public var location: NSURL? {
		willSet {
			Event.WillRelocate(from: location, to: newValue).dualcastWithSender(self)
			_willLocate()
		}
		didSet {
			_didLocate()
			Event.DidRelocate(from: oldValue, to: location).dualcastWithSender(self)
		}
	}

	public private(set) var allProjects: [ProjectModel] = []
	public private(set) var currentProject: ProjectModel?

	///

	/// Creates a new workspace file structure at current location
	/// if there's none. This method does not guarantee proper creation,
	/// and can fail for any reason.
	public func construct() throws {
		assert(location != nil)
		cargo.runNewAtURL(location!)
	}
//	public func demolish() {
//	}

	public func insertProjectWithRootURL(url: NSURL) {
		assert(location != nil, "You cannot manage projects on a workspace with no location.")
		markUnimplemented()
//		let	p	=	ProjectModel()
//		p.owner		=	self
//		_projects
	}
	public func deleteProject(project: ProjectModel) {
		assert(location != nil, "You cannot manage projects on a workspace with no location.")
		markUnimplemented()
	}








	///

	private func _willLocate() {
	}
	private func _didLocate() {
	}
}





public class WorkspaceUIModel: ModelSubnode<WorkspaceModel> {

	public let	navigationPane	=	MutableValueStorage<Bool>(false)
	public let	inspectionPane	=	MutableValueStorage<Bool>(false)
	public let	consolePane	=	MutableValueStorage<Bool>(false)

}






























