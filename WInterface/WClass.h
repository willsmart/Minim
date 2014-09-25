@interface WClass : InFiles {
    NSString *name;
    WType *superType;
    NSMutableDictionary *fns,*vars;
    NSArray *fnNames,*varNames;
    bool addedToFns,isProtocol;
    Int _depth;
    NSRegularExpression *getterSetterRE;
}
@property (readonly) NSString *filename;
@property (readonly) Int depth;
- (Int)depthWithStack:(NSMutableSet*)stack;

@property (readonly) bool empty;
@property bool hasDef;
@property (readonly) bool exists;

@property bool isProtocol,isSys,isType,isBlock,isWIOnly;
@property (retain,nonatomic) NSString *name;
@property (retain,nonatomic) WType *superType;
@property (retain,nonatomic) NSSet *varPatterns;
@property (retain,nonatomic) NSMutableDictionary *fns,*vars;
@property (retain,nonatomic) NSArray *fnNames,*varNames;

+ (WClass*)getClassWithName:(NSString*)aname;
+ (WClass*)getProtocolWithName:(NSString*)aname;
+ (WClass*)getClassWithName:(NSString*)aname superClass:(WClass*)superClass protocolList:(NSArray*)protocolList varPatterns:(NSSet*)avarPatterns;
+ (WClass*)getProtocolWithName:(NSString*)aname superList:(NSArray*)asuperList varPatterns:(NSSet*)avarPatterns;
- (void)appendObjCToString_struct:(NSMutableString*)s;
- (void)appendObjCToString_protocol:(NSMutableString*)s;
- (void)appendObjCToString_iface:(NSMutableString*)s;
- (void)appendObjCToString_impl:(NSMutableString*)s;
- (void)addProtocolToClass:(WClass*)forClas included:(NSMutableSet*)included stack:(NSMutableArray*)stack;
- (void)addClassToFns;
- (void)addProtocolToFns;
-(NSString*)localizeString:(NSString*)s;
-(WType*)localizeType:(WType*)atype;

@property (readonly) WType *wType;
@property (readonly) NSRegularExpression *getterSetterRE;


@property (readonly) NSString *infoStr,*tag;
@property Int ownedNum,ownsNum;
-(void)addOwnership;
-(NSString*)html:(NSMutableDictionary*)tags andName:(bool)andName;
-(void)addjsvars:(NSMutableDictionary*)dict;

@end
