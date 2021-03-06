////
////  AutocompletionUI.swift
////  EditorAutocompletionUI
////
////  Created by Hoon H. on 2015/05/25.
////  Copyright (c) 2015 Eonil. All rights reserved.
////
//
//import Foundation
//import AppKit
//import SignalGraph
//import EditorModel
//import EditorToolComponents
//
//public class AutocompletionUI {
//	public typealias	Match	=	Racer.Match
//	
//	public struct CandidateItem {
//		public enum Classification {
//			case 	Unknown
//			case	Function
//			case 	Struct
//			case	Macro
//		}
//		
//		public var	kind	:	Classification
//		public var	name	:	String
////		public var	text	:	String
//	}
//
//	public init() {
//		
//	}
//	public var window: NSWindow {
//		get {
//			return	floating
//		}
//	}
//	
//	///	A data receiver.
//	public var sensor: SignalSensor<ArraySignal<Match>> {
//		get {
//			return	monitor
//		}
//	}
//	
//	///	MARK:	-	
//	
//	private let	floating	=	NSWindow()
//	private let	scroll		=	NSScrollView()
//	private let	table		=	NSTableView()
//	private let	agent		=	OBJCAgent()
//	
//	private let	monitor		=	SignalMonitor<ArraySignal<Match>>()
//	private var	copy		:	[Match]?
//	
//	private func setup() {
//		agent.count			=	{ [weak self] () in self!.copy?.count ?? 0 }
//		agent.reconfigureView		=	{ [weak self] view, row in (view as! V).data = self!.copy![row] }
//		agent.instantiateView		=	{ return V() }
//		
//		floating.contentView		=	scroll
//		
//		scroll.hasVerticalScroller	=	true
//		scroll.documentView		=	table
//		
//		table.headerView		=	nil
//		table.addTableColumn(NSTableColumn())
//		table.setDataSource(agent)
//		table.setDelegate(agent)
//		
//		monitor.handler			=	{ [weak self] in self!.processSignal($0) }
//	}
//	
//	private func processSignal(s: ArraySignal<T>) {
//		s.apply(&copy)
//		
//		switch s {
//		case .Initiation(snapshot: let s):
//			table.setDataSource(agent)
//			table.setDelegate(agent)
//			table.reloadData()
//			
//		case .Transition(transaction: let s):
//			let	all_column_idxs	=	NSIndexSet(indexesInRange: NSRange(location: 0, length: table.tableColumns.count))
//			table.beginUpdates()
//			for m in s.mutations {
//				switch (m.past, m.future) {
//				case (nil, _):
//					table.insertRowsAtIndexes(NSIndexSet(index: m.identity), withAnimation: NSTableViewAnimationOptions.EffectFade)
//					
//				case (_, nil):
//					table.removeRowsAtIndexes(NSIndexSet(index: m.identity), withAnimation: NSTableViewAnimationOptions.EffectFade)
//					
//				case (_, _):
//					table.reloadDataForRowIndexes(NSIndexSet(index: m.identity), columnIndexes: all_column_idxs)
//					
//				default:
//					fatalError("Unsupported mutation state representation found in the signal.")
//				}
//			}
//			table.endUpdates()
//			
//		case .Termination(snapshot: let s):
//			table.setDelegate(nil)
//			table.setDataSource(nil)
//			table.reloadData()
//		}
//	}
//}
//
//
//
//
//
//
//
//@objc
//private final class OBJCAgent: NSObject, NSTableViewDataSource, NSTableViewDelegate {
//	var	count		:	(()->Int)?
//	var	reconfigureView	:	((view: NSView, row: Int) -> ())?
//	var	instantiateView	:	(() -> NSView)?
//	
//	///	MARK:	-
//	
//	@objc
//	private func numberOfRowsInTableView(tableView: NSTableView) -> Int {
//		return	count!()
//	}
//	
//	@objc
//	private func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
//		func reuseOld() -> NSView? {
//			return	tableView.makeViewWithIdentifier(CELL_IDENTIFIER, owner: nil) as? NSView
//		}
//		
//		let	v	=	reuseOld() ?? makeNew()
//		reconfigureView!(view: v, row: row)
//		return	v
//	}
//	
//	private func makeNew() -> NSView {
//		let	v	=	instantiateView!()
//		v.identifier	=	CELL_IDENTIFIER
//		return	v
//	}
//}
//
//private let	CELL_IDENTIFIER	=	"CELL"
//
