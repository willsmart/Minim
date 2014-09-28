@interface WFn : InFiles {
    bool ocppCompatible,swiftCompatible,_ocppCompatible,_swiftCompatible;
}
@property (retain,nonatomic) NSString *sig,*sigWithArgs,*body;
@property (weak,nonatomic) WClass *clas;
@property (readonly) bool imaginary;
+ (WFn*)getExistingFnWithSig:(NSString*)asig clas:(WClass*)aclas;
+ (WFn*)getFnWithSig:(NSString*)asig body:(NSString*)abody clas:(WClass*)aclas;
- (void)appendObjCToString_iface:(NSMutableString*)s;
- (void)appendObjCToString_impl:(NSMutableString*)s;
+ (Int)tokenMergeNumber:(WReaderTokenizer*)tk pos:(NSUInteger)pos append:(bool*)pappend retNumTokens:(Int*)pretNumTokens;
+(NSString*)trimmedReplaceString:(NSString*)s;
- (NSString*)finalSigStr:(NSString*)asig;
- (NSString*)finalBodyStr:(NSString*)abody withSig:(NSString*)asig;
+(NSComparisonResult)compareName:(NSString*)n1 withName:(NSString*)n2;
-(NSString*)bodyByReplacingSettersAndGettersInBody:(NSString*)body;
+ (NSString*)mergedBody:(NSString*)a with:(NSString*)b;
+(NSString*)balance:(NSString*)s;
-(NSString*)sortedBody;

-(NSString*)color;

-(void)refreshCompatability;
@property bool ocppCompatible,swiftCompatible;

@end
