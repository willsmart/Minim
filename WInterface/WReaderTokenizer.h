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
@property (retain,nonatomic) NSString *_str,*str,*_notes,*notes;
@property int bracketCount,linei;
@property char type;
- (id)initWithTokenizer:(WReaderTokenizer*)atokenizer string:(NSString*)astr bracketCount:(int)bc linei:(int)linei type:(char)type;
- (id)initWithTokenizer:(WReaderTokenizer*)atokenizer string:(NSString*)astr bracketCount:(int)bc linei:(int)linei type:(char)type note:(NSString*)anote;
-(void)addNote:(NSString*)format,...;
@end

@interface WReaderTokenizer : NSObject {
    bool addedBracketTokens,addedSelectorTokens;
}

@property (assign,nonatomic) WReader *reader;
@property (retain,nonatomic) NSObject<WReaderTokenDelegate> *tokenDelegate;
@property (retain,nonatomic) NSMutableArray *tokens;
@property (retain,nonatomic) NSString *str,*_str;

@property (readonly) NSString *tokenStr;

- (id)initWithReader:(WReader*)areader;
-(bool)addBracketTokens;
-(bool)addSelectorTokens;

@end
