//
//  SourceFile.h
//  WInterface
//
//  Created by Will Smart on 7/07/14.
//
//

#import <Foundation/Foundation.h>
@class WReader;

@protocol SourceFileClass
@property NSString *basePath;
@end

#import "CodeBlock.h"
@interface SourceFile : CodeBlock

@property (readonly,strong,nonatomic) WReader *wreader;
@property (strong,nonatomic) NSArray *tokens;
@property (readonly,strong,nonatomic) NSString *path;
@property (strong,nonatomic) *body;
@property (readonly,nonatomic) NSString *filename;
-(SourceFile*)referedFile:(NSString*)filename;

@end
