//
//  WReaderTokenizer.h
//  WInterface
//
//  Created by Will Smart on 8/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WReaderTokenizer;
@class WReaderToken;
@class WReader;

@protocol WReaderTokenDelegate

-(NSString*)processedStringForString:(NSString*)s inToken:(WReaderToken*)token;

@end

@interface WReaderToken : NSObject
@property (assign,nonatomic) WReaderTokenizer *tokenizer;
@property (retain,nonatomic) NSString *_str,*str;
@property int bracketCount;
@property char type;
- (id)initWithTokenizer:(WReaderTokenizer*)atokenizer string:(NSString*)astr bracketCount:(int)bc type:(char)type;
@end

@interface WReaderTokenizer : NSObject

@property (assign,nonatomic) WReader *reader;
@property (retain,nonatomic) NSObject<WReaderTokenDelegate> *tokenDelegate;
@property (retain,nonatomic) NSMutableArray *tokens;
@property (retain,nonatomic) NSString *str,*_str;

@property (readonly) NSString *tokenStr;

- (id)initWithReader:(WReader*)areader;

@end
