//
//  LLDBSymbol.h
//  InteractiveDebugger
//
//  Created by Hoon H. on 9/7/14.
//
//

#pragma once
#import "LLDBObject.h"
#import "LLDBDeclarations.h"

@interface LLDBSymbol : LLDBObject
- (instancetype)init UNIVERSE_UNAVAILABLE_METHOD;




@property	(readonly,nonatomic,copy)	NSString*		name;
@property	(readonly,nonatomic,copy)	NSString*		mangledName;
- (LLDBInstructionList*)instructionsForTarget:(LLDBTarget*)target;
- (LLDBInstructionList*)instructionsForTarget:(LLDBTarget*)target flavor:(NSString*)flavor;




@property	(readonly,nonatomic,copy)	LLDBAddress*	startAddress;
@property	(readonly,nonatomic,copy)	LLDBAddress*	endAddress;
@property	(readonly,nonatomic,assign)	uint32_t		prologueByteSize;
//@property	(readonly,nonatomic,copy)	LLDBType*		type;




- (BOOL)isEqualToSymbol:(LLDBSymbol*)object;
- (BOOL)isEqual:(id)object;
@end
