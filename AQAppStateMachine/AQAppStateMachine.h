//
//  AQAppStateMachine.h
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-16.
//  Copyright 2011 Jim Dovey. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions
//  are met:
//
//  Redistributions of source code must retain the above copyright notice,
//  this list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//
//  Neither the name of the project's author nor the names of its
//  contributors may be used to endorse or promote products derived from
//  this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
//  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>
#import "AQNotifyingBitfield.h"

/*!
 This is intended to be a singleton class.
 */
@interface AQAppStateMachine : NSObject
{
	AQNotifyingBitfield *	_stateBits;
	NSMutableDictionary *	_namedRanges;
	NSMutableArray *		_matchDescriptors;
	NSMutableDictionary *	_notifierLookup;
	dispatch_queue_t		_syncQ;
}

/*!
 Obtain/create the singleton state machine instance.
 */
+ (AQAppStateMachine *) appStateMachine;

// core notification API— everything else funnels through these functions
- (void) notifyForChangesToStateBitAtIndex: (NSUInteger) index usingBlock: (void (^)(void)) block;
- (void) notifyForChangesToStateBitsInRange: (NSRange) range usingBlock: (void (^)(void)) block;
- (void) notifyForChangesToStateBitsInRange: (NSRange) range maskedWithInteger: (NSUInteger) mask
								 usingBlock: (void (^)(void)) block;
- (void) notifyForChangesToStateBitsInRange: (NSRange) range maskedWithBits: (AQBitfield *) mask
								 usingBlock: (void (^)(void)) block;

@end

/*!
 This category defines an interface whereby API clients can interact with the state machine using
 atomic-sized enumerated value ranges keyed with specific names, rather than knowing the internals
 of the (potentially quite large) bitfield layout.
 */
@interface AQAppStateMachine (NamedStateEnumerations)

// up to 32 bits of enum size
- (void) addStateMachineValuesFromZeroTo: (NSUInteger) maxValue withName: (NSString *) name;

// up to 32-64 bits of enum size
- (void) add64BitStateMachineValuesFromZeroTo: (UInt64) maxValue withName: (NSString *) name;

// generic named bit-range creator -- the others all funnel through here
- (void) addStateMachineValuesUsingBitfieldOfLength: (NSUInteger) length withName: (NSString *) name;

// add notifications for named enumerations
- (void) notifyChangesToStateMachineValuesWithName: (NSString *) name
										usingBlock: (void (^)(void)) block;
- (void) notifyChangesToStateMachineValuesWithName: (NSString *) name
									  matchingMask: (NSUInteger) mask
										usingBlock: (void (^)(void)) block;
- (void) notifyChangesToStateMachineValuesWithName: (NSString *) name
								 matching64BitMask: (UInt64) mask
										usingBlock: (void (^)(void)) block;
- (void) notifyChangesToStateMachineValuesWithName: (NSString *) name
							  matchingMaskBitfield: (AQBitfield *) mask
										usingBlock: (void (^)(void)) block;

@end

@interface AQAppStateMachine (MultipleEnumerationNotifications)

// TODO: Figure out a nice API to assign a block to bits in multiple named state enum ranges
// Probably it'll involve a custom descriptor object

@end

@interface AQAppStateMachine (InteriorThingsICantHelpMyselfFromExposing)

- (NSRange) underlyingBitfieldRangeForName: (NSString *) name;

@end
