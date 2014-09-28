@interface WClasses : NSObject<WReaderTokenDelegate> {
    NSMutableDictionary *classes,*protocols;
    NSMutableArray *propertyContexts,*props,*taskList;
    NSMutableIndexSet *propertyContextBrackets;
    NSMutableArray *propertyContextLineis;
    NSMutableDictionary *settingsContext;
    WClass *classContext;
    InFiles *logContext;
    Int classContextBracket;
    Int classContextLinei;
    bool skipNewLines;
    bool madeImportSets;
}
@property (readonly) NSSet *filenames;
@property bool hasErrors,hasWarnings,finishedParse,skipNewLines;
@property (retain,nonatomic) NSMutableDictionary *classes,*protocols;
@property (retain,nonatomic) NSMutableArray *propertyContexts,*props;
@property (retain,nonatomic) NSMutableIndexSet *propertyContextBrackets;
@property (retain,nonatomic) NSMutableArray *propertyContextLineis;
@property (retain,nonatomic) NSMutableDictionary *settingsContext;
@property (retain,nonatomic) WClass *classContext;
@property (retain,nonatomic) InFiles *logContext;
@property Int classContextBracket,classContextLinei;
@property (retain,nonatomic) NSMutableArray *taskList;
@property (retain,nonatomic) NSMutableSet *readFNStack;
@property (retain,nonatomic) NSMutableArray *includes;
@property (retain,nonatomic) NSString *taskFn;
@property (retain,nonatomic) NSMutableString *ins_first_decl,*ins_after_imports_decl,*ins_after_decl_decl,*ins_after_structs_decl,*ins_after_protocols_decl,*ins_after_ifaces_decl,*ins_last_decl;
@property (retain,nonatomic) NSMutableString *ins_first_iface,*ins_after_imports_iface,*ins_after_decl_iface,*ins_after_structs_iface,*ins_after_protocols_iface,*ins_after_ifaces_iface,*ins_last_iface;
@property (retain,nonatomic) NSMutableString *ins_first_impl,*ins_after_imports_impl,*ins_after_decl_impl,*ins_after_structs_impl,*ins_after_protocols_impl,*ins_after_ifaces_impl,*ins_last_impl;
@property (retain,nonatomic) NSMutableString *ins_each_impl;
@property (retain,nonatomic) NSMutableSet *ins_set_first_decl,*ins_set_after_imports_decl,*ins_set_after_decl_decl,*ins_set_after_structs_decl,*ins_set_after_protocols_decl,*ins_set_after_ifaces_decl,*ins_set_last_decl;
@property (retain,nonatomic) NSMutableSet *ins_set_first_iface,*ins_set_after_imports_iface,*ins_set_after_decl_iface,*ins_set_after_structs_iface,*ins_set_after_protocols_iface,*ins_set_after_ifaces_iface,*ins_set_last_iface;
@property (retain,nonatomic) NSMutableSet *ins_set_first_impl,*ins_set_after_imports_impl,*ins_set_after_decl_impl,*ins_set_after_structs_impl,*ins_set_after_protocols_impl,*ins_set_after_ifaces_impl,*ins_set_last_impl;
@property (retain,nonatomic) NSMutableSet *ins_set_each_impl;
@property (retain,nonatomic) NSMutableArray *incls;

- (void)read:(WReader*)r;
- (void)read:(WReader *)r logContext:(InFiles*)alogContext;
- (void)clear;

+ (void)error:(NSString *)err withToken:(WReaderToken *)t context:(InFiles*)ctxt;
+ (void)warning:(NSString *)err withToken:(WReaderToken *)t context:(InFiles*)ctxt;
+ (void)note:(NSString *)n withToken:(WReaderToken *)t context:(InFiles*)ctxt;

@property (retain,nonatomic) NSMutableDictionary *propFiles;

- (NSString*)appendObjCToString:(NSMutableString*)s iface:(bool)iface impl:(bool)impl classFilename:(NSString*)cfn headerFilename:(NSString*)hfn swift:(bool)swift;
+ (WClasses*)getDefault;
+ (void)clearStaticData;
- (void)addToFns;

@property (readonly) NSString *html;

+(WType*)processClassType:(WType*)t class:(WClass*)clas protocols:(NSArray*)protocols tostars:(Int*)tostars;
+(NSString*)processClassString:(NSString*)s reader:(WReader*)r;
+(NSString*)processClassString:(NSString*)s class:(WClass*)clas protocols:(NSArray*)protocols;
-(NSMutableString*)importsDeclWithName:(NSString*)s nameUsed:(NSString*__strong*)pnameUsed;
-(NSMutableSet*)importsSetWithName:(NSString*)s nameUsed:(NSString*__strong*)pnameUsed;
-(void)makeImportSets;

-(WPotentialType*)readPotentialType:(WReader*)r;
-(WType*)readType:(WReader*)r;
+ (NSString*)htmlStringForString:(NSString*)str;
+ (NSString*)jsStringForString:(NSString*)str;
- (WClass*)classForName:(NSString*)name;


@end
