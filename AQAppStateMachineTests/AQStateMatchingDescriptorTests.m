//
//  AQStateMatchingDescriptorTests.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-22.
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

#import "AQStateMatchingDescriptorTests.h"
#import "AQStateMaskMatchingDescriptor.h"
#import "AQStateMaskedEqualityMatchingDescriptor.h"
#import "AQBitfield.h"
#import "AQRange.h"

@implementation AQStateMatchingDescriptorTests

- (void) testUniqueIDs
{
	AQStateMaskMatchingDescriptor * desc1 = [[AQStateMaskMatchingDescriptor alloc] initWithRange: NSMakeRange(0, 10) matchingMask: nil];
	AQStateMaskMatchingDescriptor * desc2 = [[AQStateMaskMatchingDescriptor alloc] initWithRange: NSMakeRange(0, 10) matchingMask: nil];
	
	STAssertTrue([desc1.uniqueID isEqualToString: desc2.uniqueID] == NO, @"Descriptor unique IDs are supposed to be *unique*, dammit!");
}

- (void) testSingleRangeAndMask
{
	AQBitfield * mask = [AQBitfield new];
	[mask setBitsInRange: NSMakeRange(0, 6) usingBit: 1];
	
	AQStateMaskMatchingDescriptor * desc = [[AQStateMaskMatchingDescriptor alloc] initWithRange: NSMakeRange(0, 20) matchingMask: mask];
	STAssertNotNil(desc, @"Expected to be able to at least create an object!");
	
	NSRange yes = NSMakeRange(0, 6);
	NSRange no  = NSMakeRange(10, 5);
	STAssertTrue([desc matchesRange: yes], @"Expected range %@ to match descriptor %@", NSStringFromRange(yes), desc);
	STAssertFalse([desc matchesRange: no], @"Expected range %@ to NOT match descriptor %@", NSStringFromRange(no), desc);
}

- (void) testMultipleRangesWithMasks
{
	NSRange range1 = NSMakeRange(0, 20);
	AQBitfield * mask1 = [AQBitfield new];
	[mask1 setBitsInRange: NSMakeRange(0, 6) usingBit: 1];
	
	NSRange range2 = NSMakeRange(25, 5);
	AQBitfield * mask2 = [AQBitfield new];
	[mask2 setBitsInRange: NSMakeRange(0, 4) usingBit: 1];
	
	AQStateMaskMatchingDescriptor * desc = [[AQStateMaskMatchingDescriptor alloc] initWithRanges: [NSArray arrayWithObjects: [[AQRange alloc] initWithRange: range1], [[AQRange alloc] initWithRange: range2], nil] matchingMasks: [NSArray arrayWithObjects: mask1, mask2, nil]];
	
	NSRange yes = NSMakeRange(0, 6);
	NSRange no  = NSMakeRange(29, 1);
	STAssertTrue([desc matchesRange: yes], @"Expected range %@ to match descriptor %@", NSStringFromRange(yes), desc);
	STAssertFalse([desc matchesRange: no], @"Expected range %@ to NOT match descriptor %@", NSStringFromRange(no), desc);
}

- (void) testComparisons
{
	NSRange range = NSMakeRange(0, 10);
	NSRange equal = NSMakeRange(0, 10);
	NSRange higherForLength = NSMakeRange(0, 20);
	NSRange higherForLocation = NSMakeRange(10, 10);
	
	AQStateMaskMatchingDescriptor * descRange = [[AQStateMaskMatchingDescriptor alloc] initWithRange: range matchingMask: nil];
	AQStateMaskMatchingDescriptor * descEqual = [[AQStateMaskMatchingDescriptor alloc] initWithRange: equal matchingMask: nil];
	AQStateMaskMatchingDescriptor * descLength = [[AQStateMaskMatchingDescriptor alloc] initWithRange: higherForLength matchingMask: nil];
	AQStateMaskMatchingDescriptor * descLocation = [[AQStateMaskMatchingDescriptor alloc] initWithRange: higherForLocation matchingMask: nil];
	
	STAssertTrue([descRange compare: descEqual] == NSOrderedSame, @"Expected comparison of %@ to %@ to return 'same', got %lu", descRange, descEqual, (unsigned long)[descRange compare: descEqual]);
	STAssertTrue([descRange compare: descLength] == NSOrderedAscending, @"Expected comparison of %@ to %@ to return 'ascending', got %lu", descRange, descLength, (unsigned long)[descRange compare: descLength]);
	STAssertTrue([descLength compare: descRange] == NSOrderedDescending, @"Expected comparison of %@ to %@ to return 'ascending', got %lu", descLength, descRange, (unsigned long)[descLength compare: descRange]);
	STAssertTrue([descRange compare: descLocation] == NSOrderedAscending, @"Expected comparison of %@ to %@ to return 'ascending', got %lu", descRange, descLocation, (unsigned long)[descRange compare: descLocation]);
	STAssertTrue([descLocation compare: descRange] == NSOrderedDescending, @"Expected comparison of %@ to %@ to return 'ascending', got %lu", descLocation, descRange, (unsigned long)[descLocation compare: descRange]);
}

- (void) testFullRange
{
	AQRange * r1 = [[AQRange alloc] initWithRange: NSMakeRange(0, 10)];
	AQRange * r2 = [[AQRange alloc] initWithRange: NSMakeRange(15, 5)];
	NSRange totalRange = NSMakeRange(0, 20);
	
	AQStateMaskMatchingDescriptor * desc = [[AQStateMaskMatchingDescriptor alloc] initWithRanges: [NSArray arrayWithObjects: r1, r2, nil] matchingMasks: nil];
	STAssertTrue(NSEqualRanges(totalRange, desc.fullRange), @"Expected total range of %@ to be %@, got %@", desc, NSStringFromRange(totalRange), NSStringFromRange(desc.fullRange));
}

- (void) testSimpleEquality
{
	AQStateMaskedEqualityMatchingDescriptor * desc = [[AQStateMaskedEqualityMatchingDescriptor alloc] initWith32BitValue: 0xFF700055 forRange: NSMakeRange(32, 32)];
	AQBitfield * bitfield = [[AQBitfield alloc] initWith64BitField: 0xFF700055FF00FF00];
	
	STAssertTrue([desc matchesBitfield: bitfield], @"Expected equality descriptor %@ to match bitfield %@", desc, bitfield);
	
	[bitfield flipBitAtIndex: 20];
	STAssertTrue([desc matchesBitfield: bitfield], @"Expected equality descriptor %@ to match bitfield %@", desc, bitfield);
	
	[bitfield flipBitAtIndex: 40];
	STAssertFalse([desc matchesBitfield: bitfield], @"Expected equality descriptor %@ NOT to match bitfield %@", desc, bitfield);
}

- (void) testZeroEquality
{
	AQBitfield * bitfield = [[AQBitfield alloc] initWith64BitField: 0xFFFF00000000FFFF];
	AQStateMaskedEqualityMatchingDescriptor * desc = [[AQStateMaskedEqualityMatchingDescriptor alloc] initWith32BitValue: 0 forRange: NSMakeRange(16, 32)];
	
	STAssertTrue([desc matchesBitfield: bitfield], @"Expected equality descriptor %@ to match bitfield %@", desc, bitfield);
	
	[bitfield flipBitAtIndex: 32];
	STAssertFalse([desc matchesBitfield: bitfield], @"Expected equality descriptor %@ NOT to match bitfield %@", desc, bitfield);
}

- (void) testMaskedEquality
{
	AQBitfield * bitfield = [[AQBitfield alloc] initWith64BitField: 0xFFFF00000000FFFF];
	AQStateMaskedEqualityMatchingDescriptor * desc = [[AQStateMaskedEqualityMatchingDescriptor alloc] initWith32BitValue: 0x000000FF forRange: NSMakeRange(0, 32) matchingMask: 0xFFFF00FF];
	
	STAssertTrue([desc matchesBitfield: bitfield], @"Expected equality descriptor %@ to match bitfield %@", desc, bitfield);
	
	[bitfield flipBitAtIndex: 12];
	STAssertTrue([desc matchesBitfield: bitfield], @"Expected equality descriptor %@ to match bitfield %@", desc, bitfield);
	
	[bitfield flipBitAtIndex: 24];
	STAssertFalse([desc matchesBitfield: bitfield], @"Expected equality descriptor %@ NOT to match bitfield %@", desc, bitfield);
}

@end
