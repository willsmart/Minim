@interface WReader : NSObject {
    NSString *_fileString,*_fileName,*_filePath;
    NSArray *lines;
    Int pos;
}

@property Int pos;

@property (retain,nonatomic) NSString *fileString,*fileName,*_fileString,*_fileName,*_filePath;
@property (retain,nonatomic,readonly) NSString *filePath;

@property (retain,nonatomic) NSArray *lines;
@property (retain,nonatomic) NSMutableDictionary *replaces;

@property (readonly) WReaderToken *nextToken,*currentToken;
@property (retain,nonatomic) WReaderTokenizer *tokenizer;
- (NSString*)stringWithTokensInRange:(NSRange)r;

@property (readonly) NSString *localString;

@end


