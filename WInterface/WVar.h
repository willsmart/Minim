@interface WVar : InFiles {
    bool addedToFns;
    NSRegularExpression *setterRE,*getterRE;
    
    

    bool attributesCached,imaginary,retains,copies,isType,isBlock,modelretains,readonly,atomic,synthesized,objc_readonly,needsGetter,needsSetter,hasIVar,superHasIVar,privateIVar,hasDefaultValue,justivar;
    WFn *hasGetter,*hasSetter;
    NSString *setterName,*getterName,*getterSig,*setterSig,*localizedSetterName,*localizedGetterName,*localizedGetterSig,*localizedSetterSig,*localizedVarName,*localizedName;
    WType *localizedType;
    NSMutableString *localizedSetterBody,*localizedGetterBody;
}

-(bool)hasSettersAndGettersInBody:(NSString*)body hasSetter:(bool*)phasSetter hasGetter:(bool*)phasGetter;

@property (retain,nonatomic) NSString *name,*qname,*defaultValue,*setterArg;
@property (retain,nonatomic) NSSet *attributes;
@property (weak,nonatomic) WClass *clas;
@property (strong,nonatomic) WType *type;
@property (strong,nonatomic) NSMutableSet *type_protocols;
@property Int stars;
@property (readonly) NSString *localizedVarName;
@property Int defLevel;

@property (readonly) WType *localizedType;
@property (readonly) NSString *localizedName;


- (void)add:(WReader*)r;

+ (WVar*)getExistingVarWithName:(NSString*)aname clas:(WClass*)aclas;
+ (WVar*)getVarWithType:(WType*)atype stars:(Int)astars name:(NSString*)aname qname:(NSString*)qname defVal:(NSString*)adefaultValue defValLevel:(Int)adefLevel attributes:(NSSet*)aattributes clas:(WClass*)aclas;
- (void)appendObjCToString_ivar:(NSMutableString*)s;
- (void)appendObjCToString_iface:(NSMutableString*)s;
- (void)appendObjCToString_impl:(NSMutableString*)s;
- (void)addToFns;
@property (readonly) NSString *objCType,*lazyObjCType,*localizedObjCType,*lazyLocalizedObjCType;

+(NSComparisonResult)compareName:(NSString*)n1 withName:(NSString*)n2;


@property (readonly) bool tracked;
@property (readonly) bool imaginary;
@property (readonly) WFn *hasGetter,*hasSetter;
@property (readonly) bool retains,copies;
@property (readonly) bool isType,isBlock;
@property (readonly) bool modelretains;
@property (readonly) bool readonly;
@property (readonly) bool atomic;
@property (readonly) bool synthesized,objc_readonly,needsGetter,needsSetter;
@property (readonly) bool hasIVar,superHasIVar,privateIVar,hasDefaultValue,justivar;
@property (readonly) NSString *setterName,*getterName,*getterSig,*setterSig,*localizedSetterName,*localizedGetterName,*localizedGetterSig,*localizedSetterSig;
@property (readonly) NSMutableString *localizedSetterBody,*localizedGetterBody;

@property (readonly) bool retainable;

@end








