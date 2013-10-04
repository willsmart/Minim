//
//  WReader.h
//  WInterface
//
//  Created by Will Smart on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WReaderToken;
@class WReaderTokenizer;

@interface WReader : NSObject {
    NSString *_fileString,*_fileName;
    NSArray *lines;
    int pos;
}

@property int pos;

@property (retain,nonatomic) NSString *fileString,*fileName,*_fileString,*_fileName;
@property (retain,nonatomic) NSArray *lines;
@property (retain,nonatomic) NSMutableDictionary *replaces;

@property (readonly) WReaderToken *nextToken,*currentToken;
@property (retain,nonatomic) WReaderTokenizer *tokenizer;
- (NSString*)stringWithTokensInRange:(NSRange)r;

@property (readonly) NSString *localString;

@end


