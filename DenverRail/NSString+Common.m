//
//  NSString+Common.m
//
// 2008 - 2013 Tack Mobile.
//

#import "NSString+Common.h"

@implementation NSString (Common)

// If the string is blank
-(BOOL)isBlank {
    if ([[self stringByStrippingWhitespace] isEqualToString:@""])
        return YES;
    return NO;
}

// if the string contains
-(BOOL)contains:(NSString *)string {
    NSRange range = [self rangeOfString:string];
    return (range.location != NSNotFound);
}

// If the string is stripped by whitespace
-(NSString *)stringByStrippingWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

// Splits the string by character
-(NSArray *)splitOnChar:(char)ch {
    NSMutableArray *results = [NSMutableArray new];
    
    int start = 0;
    for(int i=0; i<[self length]; i++) {
        
        BOOL isAtSplitChar = [self characterAtIndex:i] == ch;
        BOOL isAtEnd = i == [self length] - 1;
        
        if (isAtSplitChar || isAtEnd) {
            
            // Take the substring &amp; add it to the array
            NSRange range;
            range.location = start;
            range.length = i - start + 1;
            
            if (isAtSplitChar)
                range.length -= 1;
            
            [results addObject:[self substringWithRange:range]];
            start = i + 1;
        }
        
        // Handle the case where the last character was the split char.
        // we need an empty trailing element in the array.
        if (isAtEnd && isAtSplitChar)
            [results addObject:@""];
    }
    return results;
}

// Substring from indexes 
-(NSString *)substringFrom:(NSInteger)from to:(NSInteger)to {
    NSString *rightPart = [self substringFromIndex:from];
    return [rightPart substringToIndex:to-from];
}

@end