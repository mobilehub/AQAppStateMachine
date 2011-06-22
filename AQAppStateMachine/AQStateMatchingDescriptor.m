//
//  AQStateMatchingDescriptor.m
//  AQAppStateMachine
//
//  Created by Jim Dovey on 11-06-17.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import "AQStateMatchingDescriptor.h"
#import "AQRange.h"
#import "AQBitfield.h"
#import "AQRangeMethods.h"

@implementation AQStateMatchingDescriptor

@synthesize uniqueID=_uuid;

- (id) initWithRanges: (NSArray *) ranges matchingMasks: (NSArray *) masks
{
	NSParameterAssert([masks count] == 0 || [ranges count] == [masks count]);
	
    self = [super init];
    if ( self == nil )
		return ( nil );
	
	// create a unique identifier
	CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
	_uuid = objc_retainedObject(CFUUIDCreateString(kCFAllocatorDefault, uuid));
	CFRelease(uuid);
	
	NSMutableIndexSet * indices = [NSMutableIndexSet new];
	[ranges enumerateObjectsUsingBlock: ^(__strong id obj, NSUInteger idx, BOOL *stop) {
		AQBitfield * mask = nil;
		NSRange range = [obj range];
		if ( [masks count] != 0 )
		{
			mask = [masks objectAtIndex: idx];
			if ( (id)mask == [NSNull null] )
				mask = nil;
		}
		
		if ( mask == nil )
		{
			[indices addIndexesInRange: range];
		}
		else
		{
			// have to iterate & check each bit against the mask
			for ( NSUInteger i = range.location, j=0; i < NSMaxRange(range); i++, j++ )
			{
				if ( [mask bitAtIndex: j] == 1 )
					[indices addIndex: i];
			}
		}
	}];
	
	_matchingIndices = [indices copy];
    
    return ( self );
}

- (NSRange) fullRange
{
	NSUInteger first = [_matchingIndices firstIndex];
	NSUInteger last = [_matchingIndices lastIndex];
	
	if ( first == NSNotFound )
		return ( NSMakeRange(NSNotFound, 0) );
	
	return ( NSMakeRange(first, (last - first) + 1) );
}

- (BOOL) matchesRange: (NSRange) range
{
	return ( [_matchingIndices intersectsIndexesInRange: range] );
}

- (id) copyWithZone: (NSZone *) zone
{
	AQStateMatchingDescriptor * theCopy = [[[self class] alloc] init];
	theCopy->_uuid = [_uuid copy];
	theCopy->_matchingIndices = [_matchingIndices copy];
	return ( theCopy );
}

- (BOOL) isEqual: (id) object
{
	if ( [object isKindOfClass: [AQStateMatchingDescriptor class]] == NO )
		return ( NO );
	
	AQStateMatchingDescriptor * other = (AQStateMatchingDescriptor *)object;
	return ( [_matchingIndices isEqual: other->_matchingIndices] );
}

- (NSComparisonResult) compare: (AQStateMatchingDescriptor *) other
{
	__block NSUInteger otherIdx = [other->_matchingIndices firstIndex];
	__block NSComparisonResult result = NSOrderedSame;
	[_matchingIndices enumerateIndexesUsingBlock: ^(NSUInteger idx, BOOL *stop) {
		if ( idx == otherIdx )
		{
			otherIdx = [other->_matchingIndices indexGreaterThanIndex: otherIdx];
			return;		// continue comparison
		}
		else if ( otherIdx == NSNotFound )
		{
			result = NSOrderedDescending;
			*stop = YES;
			return;
		}
		
		result = (idx < otherIdx ? NSOrderedAscending : NSOrderedDescending);
		*stop = YES;
	}];
	
	if ( result != NSOrderedSame )
		return ( result );
	
	if ( otherIdx != NSNotFound )
		return ( NSOrderedAscending );
	
	return ( NSOrderedSame );
}

- (NSString *) description
{
	return ( [NSString stringWithFormat: @"%@{uniqueID=%@, matchingIndices=%@}", [super description], _uuid, _matchingIndices] );
}

@end

@implementation AQStateMatchingDescriptor (CreationConvenience)

- (id) initWithRange: (NSRange) range matchingMask: (AQBitfield *) mask
{
	return ( [self initWithRanges: [NSArray arrayWithObject: [[AQRange alloc] initWithRange: range]]
					matchingMasks: (mask ? [NSArray arrayWithObject: mask] : nil)] );
}

- (id) initWith32BitMask: (NSUInteger) mask forRange: (NSRange) range
{
	if ( mask == 0 )
		return ( [self initWithRanges: [NSArray arrayWithObject: [[AQRange alloc] initWithRange: range]]
						matchingMasks: nil] );
	
	AQBitfield * field = [[AQBitfield alloc] init];
	for ( NSUInteger i = 0; mask != 0; mask >>= 1, i++ )
	{
		if ( mask & 1 )
			[field setBit: 1 atIndex: i];
	}
	
	return ( [self initWithRanges: [NSArray arrayWithObject: [[AQRange alloc] initWithRange: range]]
					matchingMasks: [NSArray arrayWithObject: field]] );
}

- (id) initWith64BitMask: (UInt64) mask forRange: (NSRange) range
{
	if ( mask == 0 )
		return ( [self initWithRanges: [NSArray arrayWithObject: [[AQRange alloc] initWithRange: range]]
						matchingMasks: nil] );
	
	AQBitfield * field = [[AQBitfield alloc] init];
	for ( UInt64 i = 0; mask != 0; mask >>= 1, i++ )
	{
		if ( mask & 1 )
			[field setBit: 1 atIndex: i];
	}
	
	return ( [self initWithRanges: [NSArray arrayWithObject: [[AQRange alloc] initWithRange: range]]
					matchingMasks: [NSArray arrayWithObject: field]] );
}

@end
