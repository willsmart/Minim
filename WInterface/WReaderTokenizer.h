@interface WReaderTokenizer : NSObject {
    bool addedBracketTokens,addedSelectorTokens;
}

@property (assign,nonatomic) WReader *reader;
@property (retain,nonatomic) NSObject<WReaderTokenDelegate> *tokenDelegate;
@property (retain,nonatomic) NSMutableArray *tokens;
@property (retain,nonatomic) NSString *str,*_str;

@property (readonly) NSString *tokenStr;
@property (readonly) NSIndexSet *tokenIndexSet;

-(void)applyRegex:(NSString*)regex;

- (id)initWithReader:(WReader*)areader;
-(void)addBracketTokens;
-(void)addSelectorTokens;

@end
