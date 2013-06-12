//
//  NSString+Common.h
//
// 2008 - 2013 Tack Mobile.
//

#import <Foundation/Foundation.h>

@interface NSString (Common)

-(BOOL)isBlank;
-(BOOL)contains:(NSString *)string;
-(NSArray *)splitOnChar:(char)ch;
-(NSString *)substringFrom:(NSInteger)from to:(NSInteger)to;
-(NSString *)stringByStrippingWhitespace;

@end
