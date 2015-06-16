//
//  Shell.swift
//  EditorShell
//
//  Created by Hoon H. on 2015/06/13.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation
import SignalGraph

///	Modeling of UI states and behaviors.
class Shell {
	
	var	navigatorPaneDisplay	=	EditableValueStorage<Bool>(false)
	var	consolePaneDisplay	=	EditableValueStorage<Bool>(false)
	var	inspectorPaneDisplay	=	EditableValueStorage<Bool>(false)
	
}