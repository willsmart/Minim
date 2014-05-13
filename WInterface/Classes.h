//
//  Classes.h
//  WInterface
//
//  Created by Will Smart on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*

 A (B) "a"
 Myclass [(super)] ["regex" "regex" ...]
  _name=@"hello" (retain)
  name=_name (readonly)
  value=1.0f
  NSString *str (assign)
  [type ]varName[=default] [(attribute,attribute)]
  - (void) fn
  - (int) fn2 {return(calc);}
  - (void) fn3 {
    code
  }
  as aa -a< b
  -- C cc
  [as myname][--|-a<|>a-|-s<|>s-][Hisclass]hisname
 
*/

//#import <RegexKit/RegexKit.h>
#import <Foundation/Foundation.h>
@class WReader;
@class WClass;
@class WReaderTokenizer;
@class WReaderToken;
@class WType;
@class WPotentialType;


@interface InFiles : NSObject {
    NSMutableDictionary *inFilesLocations;
    NSMutableArray *inFilesMessages;
    InFiles *useLocationsFrom;
}

@property (readonly) NSMutableDictionary *inFilesLocations;
@property (readonly) NSMutableArray *inFilesMessages;
@property (retain,nonatomic) InFiles *useLocationsFrom;

+(NSMutableDictionary*)staticInFilesMessages;
+(void)addInFilename:(NSString*)fn line:(int)line column:(int)column format:(NSString*)format,...;
-(void)addInFilename:(NSString*)fn line:(int)line column:(int)column;
-(void)addInFilesMessageUsingFormat:(NSString*)format,...;
+(NSArray*)allInFiles;
+(void)markFiles:(NSArray*)inFiles;
+(void)markFiles;
+(NSDictionary*)unionFiles:(NSArray*)inFiles;
+(void)insertData:(NSData*)d intoFile:(FILE*)fil at:(int)offs;
+(void)clearMarksFromFiles:(NSArray*)inFiles;


@end

@interface WClasses : NSObject<WReaderTokenDelegate> {
    NSMutableDictionary *classes,*protocols;
    NSMutableArray *propertyContexts,*props,*taskList;
    NSMutableIndexSet *propertyContextBrackets;
    WClass *classContext;
    InFiles *logContext;
    int classContextBracket;
    bool skipNewLines;
    bool madeImportSets;
}
@property (readonly) NSSet *filenames;
@property bool hasErrors,hasWarnings,finishedParse,skipNewLines;
@property (retain,nonatomic) NSMutableDictionary *classes,*protocols;
@property (retain,nonatomic) NSMutableArray *propertyContexts,*props;
@property (retain,nonatomic) NSMutableIndexSet *propertyContextBrackets;
@property (retain,nonatomic) WClass *classContext;
@property (retain,nonatomic) InFiles *logContext;
@property int classContextBracket;
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
- (void)clear;

+ (void)error:(NSString *)err withToken:(WReaderToken *)t context:(InFiles*)ctxt;
+ (void)warning:(NSString *)err withToken:(WReaderToken *)t context:(InFiles*)ctxt;
+ (void)note:(NSString *)n withToken:(WReaderToken *)t context:(InFiles*)ctxt;

@property (retain,nonatomic) NSMutableDictionary *propFiles;

- (NSString*)appendObjCToString:(NSMutableString*)s iface:(bool)iface impl:(bool)impl classFilename:(NSString*)cfn headerFilename:(NSString*)hfn;
+ (WClasses*)getDefault;
+ (void)clearStaticData;
- (void)addToFns;

@property (readonly) NSString *html;

+(WType*)processClassType:(WType*)t class:(WClass*)clas protocols:(NSArray*)protocols tostars:(int*)tostars;
+(NSString*)processClassString:(NSString*)s reader:(WReader*)r;
+(NSString*)processClassString:(NSString*)s class:(WClass*)clas protocols:(NSArray*)protocols;
-(NSMutableString*)importsDeclWithName:(NSString*)s nameUsed:(NSString**)pnameUsed;
-(NSMutableSet*)importsSetWithName:(NSString*)s nameUsed:(NSString**)pnameUsed;
-(void)makeImportSets;

@end

@interface WPotentialType : NSObject {
    NSString *clas;
    NSMutableSet *protocols;
}
@property (assign,nonatomic) NSString *clas;
@property (retain,nonatomic) NSMutableSet *protocols;

-(WPotentialType*)initWithType:(WType*)t;
-(WPotentialType*)initWithClass:(NSString*)aclas protocols:(NSArray*)aprotocols addObject:(bool)addObject;
-(void)addClass:(NSString*)aclas protocols:(NSArray*)aprotocols;

@end


@interface WType : NSObject {
    WClass *clas;
    NSMutableSet *protocols;
}
@property (readonly) WClass *someWClass;
@property (assign,nonatomic) WClass *clas;
@property (retain,nonatomic) NSMutableSet *protocols;

@property (readonly) WPotentialType *potentialType;
@property (retain,nonatomic) WPotentialType *_potentialType;

-(WType*)initWithPotentialType:(WPotentialType*)pt;
-(WType*)initWithClass:(WClass*)aclas protocols:(NSArray*)aprotocols addObject:(bool)addObject;
-(void)addClass:(WClass*)aclas protocols:(NSArray*)aprotocols;
@property (readonly) NSString *wiType;
-(NSString*)objCTypeWithStars:(int)stars;
+(NSString*)objCTypeWithClass:(WClass*)clas protocols:(NSSet*)protocols stars:(int)stars;

@end


@interface WClass : InFiles {
    NSString *name;
    WType *superType;
    NSMutableDictionary *fns,*vars;
    NSArray *fnNames,*varNames;
    bool addedToFns,isProtocol;
    int _depth;
    NSRegularExpression *getterSetterRE;
}
@property (readonly) NSString *filename;
@property (readonly) int depth;
- (int)depthWithStack:(NSMutableSet*)stack;

@property (readonly) bool empty;
@property bool hasDef;
@property (readonly) bool exists;

@property bool isProtocol,isSys,isType,isWIOnly;
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

@property (readonly) WType *wType;
@property (readonly) NSRegularExpression *getterSetterRE;


@property (readonly) NSString *infoStr,*tag;
@property int ownedNum,ownsNum;
-(void)addOwnership;
-(NSString*)html:(NSMutableDictionary*)tags andName:(bool)andName;
-(void)addjsvars:(NSMutableDictionary*)dict;

@end



@class WReaderToken;


@interface WFn : InFiles {
    NSString *sig,*sigWithArgs,*body;
    WClass *clas;
}
@property (retain,nonatomic) NSString *sig,*sigWithArgs,*body;
@property (assign,nonatomic) WClass *clas;
@property (readonly) bool imaginary;
+ (WFn*)getExistingFnWithSig:(NSString*)asig clas:(WClass*)aclas;
+ (WFn*)getFnWithSig:(NSString*)asig body:(NSString*)abody clas:(WClass*)aclas;
- (void)appendObjCToString_iface:(NSMutableString*)s;
- (void)appendObjCToString_impl:(NSMutableString*)s;
+ (int)tokenMergeNumber:(WReaderTokenizer*)tk pos:(NSUInteger)pos append:(bool*)pappend retNumTokens:(int*)pretNumTokens;
+(NSString*)trimmedReplaceString:(NSString*)s;
- (NSString*)finalSigStr:(NSString*)asig;
- (NSString*)finalBodyStr:(NSString*)abody withSig:(NSString*)asig;
+(NSComparisonResult)compareName:(NSString*)n1 withName:(NSString*)n2;
-(NSString*)bodyByReplacingSettersAndGettersInBody:(NSString*)body;
@end


@interface WProp : InFiles {
    NSString *myname,*hisname,*myqname,*hisqname,*type,*origType;
    char myType,hisType;
    bool addedToFns,ownerIsMe;
}
@property (retain,nonatomic) NSString *myname,*hisname,*myqname,*hisqname,*type,*origType;
@property (assign,nonatomic) WClass *myclas,*hisclas;
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


@end



@interface WVar : InFiles {
    NSString *name,*qname,*defaultValue;
    NSSet *attributes;
    WClass *clas;
    WType *type;
    int stars;
    bool addedToFns;
    NSRegularExpression *setterRE,*getterRE;
    
    

    bool attributesCached,imaginary,retains,isType,modelretains,readonly,atomic,synthesized,objc_readonly,needsGetter,needsSetter,hasIVar,superHasIVar,privateIVar,hasDefaultValue,justivar;
    WFn *hasGetter,*hasSetter;
    NSString *setterName,*getterName,*getterSig,*setterSig,*localizedSetterName,*localizedGetterName,*localizedGetterSig,*localizedSetterSig,*localizedVarName,*localizedName;
    WType *localizedType;
    NSMutableString *localizedSetterBody,*localizedGetterBody;
}

-(bool)hasSettersAndGettersInBody:(NSString*)body hasSetter:(bool*)phasSetter hasGetter:(bool*)phasGetter;

@property (retain,nonatomic) NSString *name,*qname,*defaultValue,*setterArg;
@property (retain,nonatomic) NSSet *attributes;
@property (assign,nonatomic) WClass *clas;
@property (assign,nonatomic) WType *type;
@property (assign,nonatomic) NSMutableSet *type_protocols;
@property int stars;
@property (readonly) NSString *localizedVarName;
@property int defLevel;

@property (readonly) WType *localizedType;
@property (readonly) NSString *localizedName;


- (void)add:(WReader*)r;

+ (WVar*)getExistingVarWithName:(NSString*)aname clas:(WClass*)aclas;
+ (WVar*)getVarWithType:(WType*)atype stars:(int)astars name:(NSString*)aname qname:(NSString*)qname defVal:(NSString*)adefaultValue defValLevel:(int)adefLevel attributes:(NSSet*)aattributes clas:(WClass*)aclas;
- (void)appendObjCToString_ivar:(NSMutableString*)s;
- (void)appendObjCToString_iface:(NSMutableString*)s;
- (void)appendObjCToString_impl:(NSMutableString*)s;
- (void)addToFns;
@property (readonly) NSString *objCType,*lazyObjCType,*localizedObjCType,*lazyLocalizedObjCType;

+(NSComparisonResult)compareName:(NSString*)n1 withName:(NSString*)n2;


@property (readonly) bool tracked;
@property (readonly) bool imaginary;
@property (readonly) WFn *hasGetter,*hasSetter;
@property (readonly) bool retains;
@property (readonly) bool isType;
@property (readonly) bool modelretains;
@property (readonly) bool readonly;
@property (readonly) bool atomic;
@property (readonly) bool synthesized,objc_readonly,needsGetter,needsSetter;
@property (readonly) bool hasIVar,superHasIVar,privateIVar,hasDefaultValue,justivar;
@property (readonly) NSString *setterName,*getterName,*getterSig,*setterSig,*localizedSetterName,*localizedGetterName,*localizedGetterSig,*localizedSetterSig;
@property (readonly) NSMutableString *localizedSetterBody,*localizedGetterBody;

@property (readonly) bool retainable;

@end








