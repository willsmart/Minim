@interface WProp : InFiles {
    NSString *myname,*hisname,*myqname,*hisqname,*type,*origType;
    char myType,hisType;
    bool addedToFns,ownerIsMe;
}
@property (retain,nonatomic) NSString *myname,*hisname,*myqname,*hisqname,*type,*origType;
@property (weak,nonatomic) WClass *myclas,*hisclas;
@property (readonly) char myType,hisType;
@property (readonly) WType *myWType,*hisWType;
@property (readonly) bool ownerIsMe,ownerIsHim;

+ (NSString*)string:(NSString*)as replacePairs:(NSObject*)firstObject,...;
+ (NSString*)lowerName:(NSString*)s;
+ (NSString*)upperName:(NSString*)s;
+ (NSString*)__lowerName:(NSString*)s;
+ (NSString*)__upperName:(NSString*)s;
+ (WProp*)getPropWithMyClass:(WClass*)amyclass myName:(NSString*)amyname myQName:(NSString*)amyqname type:(NSString*)atype origType:(NSString*)aorigType hisClass:(WClass*)ahisclass hisName:(NSString*)ahisname hisQName:(NSString*)ahisqname;
/*
- (void)appendObjCToString_ivar_myclass:(NSMutableString*)s;
- (void)appendObjCToString_iface_myclass:(NSMutableString*)s;
- (void)appendObjCToString_impl_myclass:(NSMutableString*)s;
- (void)appendObjCToString_ivar_hisclass:(NSMutableString*)s;
- (void)appendObjCToString_iface_hisclass:(NSMutableString*)s;
- (void)appendObjCToString_impl_hisclass:(NSMutableString*)s;
*/
- (void)add:(WReader*)r;
+ (void)stadd:(WClass*)clas;
+ (NSString*)string:(NSString*)s withMyType:(WType*)mytype myName:(NSString*)myname iamOwner:(bool)iamOwner myQName:(NSString*)myqname hisType:(WType*)histype hisName:(NSString*)hisname heIsOwner:(bool)heIsOwner hisQName:(NSString*)hisqname qprop:(NSString*)qprop noPlurals:(bool)noPlurals;


@end
