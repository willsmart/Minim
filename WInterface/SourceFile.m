//
//  SourceFile.m
//  WInterface
//
//  Created by Will Smart on 7/07/14.
//
//

#import "SourceFile.h"
#import "WReader.h"
#import "WReaderTokenizer.h"
#import "Collections.h"

@implementation SourceFile

static NSString *s_basePath;
+(NSString*)basePath {
    if (!s_basePath) self.basePath=nil;
    return(s_basePath);
}
+(void)setBasePath:(NSString*)basePath {
    if (!basePath) basePath=nil;
    basePath=[basePath stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!basePath.isAbsolutePath) {
        NSFileManager *fm=NSFileManager.defaultManager;
        basePath=(basePath?[fm.currentDirectoryPath stringByAppendingPathComponent:basePath]:fm.currentDirectoryPath);
    }
    s_basePath=basePath;
}

NSMutableDictionary *s_sourceFiles=nil;

+(instancetype)sourceFileWithPath:(NSString*)path {
    path=[self pathForPath:path];
    
    if (!s_sourceFiles) s_sourceFiles=@{}.mutableCopy;
    if (!s_sourceFiles[path]) {
        SourceFile *sf=SourceFile.new;
        s_sourceFiles[path]=sf;
        sf._path=path;
    }
    if (!(self=[super init])) return(nil);
    _wreader=[WReader new];
}

-(instancetype)initFileWithPath:(NSString*)path {
    path=[self pathForPath:path];
    _wreader=WReader.new;
    _tokens=_wreader.tokenizer.tokens;
    
    if (!s_sourceFiles) s_sourceFiles=@{}.mutableCopy;
    if (!s_sourceFiles[path]) {
        SourceFile *sf=SourceFile.new;
        s_sourceFiles[path]=sf;
        sf._path=path;


-(void)setPath:(NSString *)path {
    path=[basePath stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!path.isAbsolutePath) path=[((id<SourceFileClass>)self.class).basePath stringByAppendingPathComponent:path];
    
    _wreader.fileName=path;
    self.tokens=_wreader.tokenizer.tokens;
}

-(NSArray*)tokens {return(_tokens);}
-(void)setTokens:(NSArray *)tokens {
    NSIndexSet *inss=nil,*dels=nil;
    [Collections getInsertsAndDeletesAsIndexSetWhenChanging:_tokens to:tokens inss:&ins dels:&dels];
    [self removeTokensAtIndexes:dels insert:(inss.count?[tokens objectsAtIndexes:inss]:nil) atIndexes:inss];
}

-(void)removeTokensAtIndexes:(NSIndexSet*)dels insert:(NSArray*)insTokens atIndexes:(NSIndexSet*)inss {
    [super removeTokensAtIndexes:dels insert:insTokens atIndexes:inss];
    _wreader.tokenizer.tokens=self.tokens;
    _body=nil;
}

-(NSString*)body {
    if (!_body) {
        NSMutableString *ret=@"".mutableCopy;
        for (WReaderToken *t in _tokens) {
            [ret appendString:t.str];
        }
        _body=ret;
    }
    return(_body);
}
-(void)setBody:(NSString *)body {
    
    _tokens=_wreader.tokenizer.tokens;
    
@property (strong,nonatomic) NSString *path,*body;
@property (strong,nonatomic) NSMutableSet *referers,*refered;
-(SourceFile*)referedFile:(NSString*)filename;

@end
