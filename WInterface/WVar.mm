@implementation WVar
@synthesize clas,type,name,qname,defaultValue,attributes,stars,defLevel,setterArg,localizedType,localizedName,ocppCompatible=_ocppCompatible,swiftCompatible=_swiftCompatible;
- (void)dealloc {
    self.type=nil;
    self.name=self.defaultValue=nil;
    self.attributes=nil;
    self.clas=nil;
    }

-(NSString*)color {return(
    self.swiftCompatible?
        (self.ocppCompatible?
            @"blue":
            @"green"
        ):
        (self.ocppCompatible?
            @"orange":
            @"red"
        )
);};



+(NSComparisonResult)compareName:(NSString*)n1 withName:(NSString*)n2 {
    NSComparisonResult res=[n1 compare:n2 options:NSCaseInsensitiveSearch];
    return(res);
}


- (id)initWithType:(WType*)atype stars:(Int)astars name:(NSString*)aname qname:(NSString*)aqname defVal:(NSString*)adefaultValue defValLevel:(Int)adefLevel attributes:(NSSet*)aattributes clas:(WClass*)aclas {
    if (!(self=[super init])) return(nil);
    ocppCompatible=swiftCompatible=YES;
    dprnt("Var : %s:%s\n",aclas.name.UTF8String,aname.UTF8String);
    self.type=[WType newWithClass:atype.clas protocols:atype.protocols.allObjects addObject:NO];
    self.stars=astars>0?astars:(atype.clas.isType?0:1);
    //[WClasses warning:[NSString stringWithFormat:@"%@ %d %d",aname,stars,astars] withReader:nil];
    self.name=aname;
    localizedName=[aclas localizeString:aname];
    localizedType=[aclas localizeType:type];
    
    self.qname=aqname;
    self.setterArg=@"v";
    
    addedToFns=NO;
    self.defaultValue=adefaultValue;
    self.defLevel=adefLevel;
    self.attributes=(aattributes?aattributes.copy:nil);
    ((self.clas=aclas).vars)[self.name] = self;
    return(self);
}
+ (WVar*)getVarWithType:(WType*)atype stars:(Int)astars name:(NSString *)aname qname:(NSString*)aqname defVal:(NSString *)adefaultValue defValLevel:(Int)adefLevel attributes:(NSSet *)aattributes clas:(WClass *)aclas {
    WVar *ret=(aclas.vars)[aname];
    if (!ret) return([[WVar alloc] initWithType:atype stars:astars name:aname qname:aqname defVal:adefaultValue defValLevel:adefLevel attributes:aattributes clas:aclas]);
    [ret.type addClass:atype.clas protocols:atype.protocols.allObjects];
    if (adefaultValue) ret.defaultValue=adefaultValue;
    if (adefLevel) ret.defLevel=adefLevel;
    if (aattributes) {
        if (ret.attributes) ret.attributes=[ret.attributes setByAddingObjectsFromSet:aattributes];
        else ret.attributes=aattributes;
    }
    return(ret);
}

+ (WVar*)getExistingVarWithName:(NSString *)aname clas:(WClass *)aclas {
    return((aclas.vars)[aname]);
}

+ (NSString*)escapeCString:(NSString*)s {
    return([WProp string:s replacePairs:@"\\",@"\\\\",@"\r",@"\\r",@"\t",@"\\t",@"\"",@"\\\"",@"\n",@"\\n\"\n            \"",nil]);
}




-(void)refreshCompatability {
    _ocppCompatible=ocppCompatible&&type.ocppCompatible;
    _swiftCompatible=swiftCompatible&&type.swiftCompatible;

    if (_swiftCompatible&&[attributes containsObject:@"cpp"]) _swiftCompatible=NO;
    if (_ocppCompatible&&[attributes containsObject:@"swift"]) _ocppCompatible=NO;
}



-(bool)hasSettersAndGettersInBody:(NSString*)body hasSetter:(bool*)phasSetter hasGetter:(bool*)phasGetter {
    if (phasSetter) *phasSetter=NO;
    if (phasGetter) *phasGetter=NO;
    if (!body) return(NO);
    
    if (!setterRE) {
        NSError *err=nil;
//        setterRE=[NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"(?<![\\w\\d_]|\\.\\s*|->\\s*)%@[^\\w\\d_]",[NSRegularExpression escapedPatternForString:self.localizedName]] options:0 error:&err];
        setterRE=[NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"(?<![\\w\\d_\\.\\s]|->)\\s*%@(?:$|[^\\w\\d_])",[NSRegularExpression escapedPatternForString:self.localizedName]] options:0 error:&err];
        if (err) {
            NSLog(@"WInterface internal error %@",err.description);
            exit(1);
        }
    }

    if (![setterRE firstMatchInString:body options:0 range:NSMakeRange(0, body.length)]) return(NO);

    WReader *r=[[WReader alloc] init];
    r.fileString=body;

    bool ret=NO;

    Int bad=0,pos=-1;
    for (WReaderToken *t in r.tokenizer.tokens) {
        pos++;
        switch (t.type) {
            case 'o':
            if ([t.str isEqualToString:@"."]) bad=1;
            else if ([t.str hasSuffix:@"ivar*/"]) bad=1;
            else if ([t.str isEqualToString:@"-"]) bad=-1;
            else if ([t.str isEqualToString:@">"]&&(bad==-1)) bad=1;
            break;
            case 'z':case 'r':case 'c':case 'n':case 's':if (bad==-1) bad=0;
            break;
            case 'w':
            if ((bad<=0)&&[t.str isEqualToString:self.localizedVarName]) {
                bad=0;
                bool isSetter=NO,isGetter=YES,got=NO;
                for (Int pos2=pos+1;(pos2<r.tokenizer.tokens.count)&&!got;pos2++) {
                    WReaderToken *t2=(r.tokenizer.tokens)[pos2];
                    switch (t2.type) {
                        case 'o':isSetter=[t2.str isEqualToString:@"="];
                        isGetter=(!isSetter)&&![t2.str isEqualToString:@"("];
                        got=YES;
                        break;
                        case 'w':case 'n':case 's':break;
                    }
                }
                if (isSetter) {
                    ret=YES;
                    if (phasSetter) *phasSetter=YES;
                }
                if (isGetter) {
                    ret=YES;
                    if (phasGetter) *phasGetter=YES;
                }
            }
        }
    }
    return(ret);
}



-(bool)retainable {
    return([localizedType.clas.varPatterns containsObject:@"retains"]||[localizedType.clas.varPatterns containsObject:@"copies"]||self.isBlock||((!self.isType)&&(stars<=1)));
}



-(void)cacheAttributes {
    if (attributesCached) return;
    [self imaginary];
    [self retains];
    [self copies];
    [self isType];
    [self modelretains];
    [self readonly];
    [self atomic];
    [self synthesized];
    [self objc_readonly];
    [self needsGetter];
    [self needsSetter];
    [self hasIVar];
    [self superHasIVar];
    [self privateIVar];
    [self hasDefaultValue];
    [self justivar];
    [self hasGetter];
    [self hasSetter];
    [self setterName];
    [self getterName];
    [self getterSig];
    [self setterSig];
    [self localizedSetterName];
    [self localizedGetterName];
    [self localizedGetterSig];
    [self localizedSetterSig];
    [self localizedSetterBody];
    [self localizedGetterBody];
    [self localizedVarName];
    
    if ([attributes containsObject:@"explain"]) {
        [WClasses note:((NSDictionary*)@{@"imaginary": @(imaginary),
            @"retains": @(retains),
            @"copies": @(copies),
            @"isType": @(isType),
            @"isBlock": @(isBlock),
            @"modelRetains": @(modelretains),
            @"readonly": @(readonly),
            @"atomic": @(atomic),
            @"synthesized": @(synthesized),
            @"objc_readonly": @(objc_readonly),
            @"needsGetter": @(needsGetter),
            @"needsSetter": @(needsSetter),
            @"hasIVar": @(hasIVar),
            @"hasDefaultValue": @(hasDefaultValue),
            @"justivar": @(justivar),
            @"hasGetter": @(hasGetter!=nil),
            @"hasSetter": @(hasSetter!=nil),
            @"setterName": setterName,
            @"getterName": getterName,
            @"setterSig": setterSig,
            @"getterSig": getterSig,
            @"localizedSetterName": localizedSetterName,
            @"localizedGetterName": localizedGetterName,
            @"localizedSetterSig": localizedSetterSig,
            @"localizedGetterSig": localizedGetterSig,
            @"localizedVarName": localizedVarName,
            @"tracked": @(self.tracked)}).description withToken:nil context:self];
    }
    attributesCached=YES;
}

#define CACHEVARATTRFN(I,__name,...) -(I)__name {if (attributesCached) return(__name);\
    I ret;memset(&ret,0,sizeof(ret)); \
    {__VA_ARGS__} \
    return(__name=ret); \
}
#define CACHEVARATTRFN_retain(I,__name,...) -(I)__name {if (attributesCached) return(__name);\
__name=nil; \
    I ret=nil; \
    {__VA_ARGS__} \
    return((__name=ret)); \
}
CACHEVARATTRFN_retain(NSString*,getterName,
    if (attributes) for (NSString *s in attributes) if ([s hasPrefix:@"getter="]) ret=[s substringFromIndex:@"getter=".length];
    if (!ret) ret=name;
)
CACHEVARATTRFN_retain(NSString*,setterName,
    if (attributes) for (NSString *s in attributes) if ([s hasPrefix:@"setter="]) ret=[s substringWithRange:NSMakeRange(@"setter=".length,s.length-@"setter=".length-([s hasSuffix:@":"]?1:0))];
    if (!ret) ret=[NSString stringWithFormat:@"set%@",[WProp upperName:self.name]];
)
CACHEVARATTRFN_retain(NSString*,localizedGetterName,
    if (attributes) for (NSString *s in attributes) if ([s hasPrefix:@"getter="]) ret=[clas localizeString:[s substringFromIndex:@"getter=".length]];
    if (!ret) ret=localizedName;
)
CACHEVARATTRFN_retain(NSString*,localizedSetterName,
    if (attributes) for (NSString *s in attributes) if ([s hasPrefix:@"setter="]) ret=[clas localizeString:[s substringWithRange:NSMakeRange(@"setter=".length,s.length-@"setter=".length-([s hasSuffix:@":"]?1:0))]];
    if (!ret) ret=[NSString stringWithFormat:@"set%@",[WProp upperName:self.localizedName]];
)

CACHEVARATTRFN_retain(NSString*,getterSig,
    ret=[NSString stringWithFormat:@"-(%@)%@",self.objCType,self.getterName];
)
CACHEVARATTRFN_retain(NSString*,localizedGetterSig,
    ret=[NSString stringWithFormat:@"-(%@)%@",self.localizedObjCType,self.localizedGetterName];
)
CACHEVARATTRFN_retain(NSString*,setterSig,
    ret=[NSString stringWithFormat:@"-(void)%@:(%@)%@",self.setterName,self.objCType,self.setterArg];
)
CACHEVARATTRFN_retain(NSString*,localizedSetterSig,
    ret=[NSString stringWithFormat:@"-(void)%@:(%@)%@",self.localizedSetterName,self.localizedObjCType,self.setterArg];
)

CACHEVARATTRFN(bool,retains,
    ret=self.retainable&&(!([attributes containsObject:@"assign"]||[attributes containsObject:@"weak"]))&&(self.hasIVar||self.superHasIVar);
)
CACHEVARATTRFN(bool,copies,
    ret=self.retainable&&(self.isBlock||[attributes containsObject:@"copy"]);
)
CACHEVARATTRFN(bool,imaginary,
    ret=[attributes containsObject:@"imaginary"];
)
CACHEVARATTRFN(bool,isType,
    ret=self.localizedType.clas.isType;
)
CACHEVARATTRFN(bool,isBlock,
    ret=self.localizedType.clas.isBlock;
)
CACHEVARATTRFN(bool,modelretains,
    ret=[attributes containsObject:@"modelretain"];
)
CACHEVARATTRFN(bool,readonly,
    ret=((![clas.varPatterns containsObject:@"-Object"])&&[attributes containsObject:@"publicreadonly"])||self.objc_readonly;
)
CACHEVARATTRFN_retain(WFn*,hasGetter,
    ret=(clas.fns)[[self getterSig]];
)
CACHEVARATTRFN_retain(WFn*,hasSetter,
    ret=(clas.fns)[[self setterSig]];
)
CACHEVARATTRFN(bool,atomic,
    ret=[attributes containsObject:@"atomic"];
)

CACHEVARATTRFN(bool,synthesized,
    ret=(!(self.imaginary||[attributes containsObject:@"justivar"]))&&(self.clas.isSys||self.hasGetter||self.hasSetter||self.retainable||[attributes containsObject:@"synthesize"]);
)

CACHEVARATTRFN(bool,objc_readonly,
    ret=[attributes containsObject:@"readonly"]||[attributes containsObject:@"readonly!"]||(([clas.varPatterns containsObject:@"-Object"]||!(self.hasIVar||self.superHasIVar))&&self.hasGetter&&!self.hasSetter);
)
CACHEVARATTRFN(bool,needsGetter,
    ret=self.synthesized;
)
CACHEVARATTRFN(bool,needsSetter,
    ret=self.synthesized&&!self.objc_readonly;
)

CACHEVARATTRFN(bool,hasIVar,
    do {
        NSString *vv=self.localizedVarName;
        if (vv) {
            bool pvt=NO;
            for (WClass *sup=self.clas.superType.clas;sup;sup=sup.superType.clas) {
                for (NSString *k in sup.vars) {
                    WVar *v=(sup.vars)[k];
                    if (v==self) BPNOW;
                    if (v.hasIVar&&[v.localizedVarName isEqualToString:vv]) {
                        ret=YES;
                        pvt=pvt||v.privateIVar;
                    }
                }
            }
            if (pvt) {
                ret=NO;
                break;
            }
            else if (ret) break;
        }
 //       if (self.superHasIVar) break;
    //[WClasses warning:[NSString stringWithFormat:@"%@ %d %d",attributes.description,self.hasSetter,self.hasGetter] withReader:nil];
        if([attributes containsObject:@"privateivar"]||[attributes containsObject:@"ivar"]||[attributes containsObject:@"justivar"]||(!(self.hasGetter||self.hasSetter))) {ret=YES;break;}
        if (attributes) {
            for (NSString *attribute in attributes) {
                if ([attribute hasPrefix:@"privateivar="]) {ret=YES;break;}
                if ([attribute hasPrefix:@"ivar="]) {ret=YES;break;}
                if ([attribute hasPrefix:@"justivar="]) {ret=YES;break;}
            }
            if (ret) break;
        }
        if ([self hasSettersAndGettersInBody:((WFn*)(clas.fns)[[self getterSig]]).body hasSetter:nil hasGetter:nil]||[self hasSettersAndGettersInBody:((WFn*)(clas.fns)[[self setterSig]]).body hasSetter:nil hasGetter:nil]) {ret=YES;break;}
    } while (NO);
)


CACHEVARATTRFN(bool,superHasIVar,
    NSString *vv=self.localizedVarName;
    if (vv) {
        for (WClass *sup=self.clas.superType.clas;sup;sup=sup.superType.clas) {
            for (NSString *k in sup.vars) {
                WVar *v=(sup.vars)[k];
                if (v.hasIVar&&[v.localizedVarName isEqualToString:vv]) {
                    ret=YES;
                }
            }
            if (ret) break;
        }
    }
)

CACHEVARATTRFN(bool,privateIVar,
    ret=[attributes containsObject:@"privateivar"];
    if (!ret) for (NSString *s in attributes) if ([s hasPrefix:@"privateivar="]) {ret=YES;break;}
)

CACHEVARATTRFN(bool,justivar,
    if ([attributes containsObject:@"justivar"]) ret=YES;
    else if (attributes) {
        for (NSString *attribute in attributes) {
            if ([attribute hasPrefix:@"justivar="]) ret=YES;
        }
    }
)

-(bool)tracked {
    return(self.hasIVar&&(!(self.localizedType.clas.isType||self.localizedType.clas.isSys))&&self.retainable&&![attributes containsObject:@"notrack"]);
}


CACHEVARATTRFN_retain(NSMutableString*,localizedGetterBody,
    if (self.synthesized) {
        NSMutableString *body=((WFn*)(clas.fns)[[self getterSig]]).body.mutableCopy;
        if (!body) {
            body=(self.hasIVar?
                    ((!self.atomic)||self.isType?
                        [NSMutableString stringWithFormat:
                            @"@-999 %@ ret=%@;@999 return(ret);",self.localizedObjCType,self.localizedVarName]:
                        [NSMutableString stringWithFormat:
                            @"@-999 %@ ret=%@;@999 return(ret);",self.localizedObjCType,self.localizedVarName]):// todo make actually atomic
                    [NSMutableString stringWithFormat:
                        @"@-999 %@ ret;memset(&ret,0,sizeof(ret));@999 return(ret);",self.localizedObjCType]);
        }
        ret=body;//[WFn mergedBody:body with:@""].mutableCopy;
    }
)

CACHEVARATTRFN_retain(NSMutableString*,localizedSetterBody,
    if (self.synthesized) {
        NSMutableString *body=((WFn*)(clas.fns)[[self setterSig]]).body.mutableCopy;
        if (!body) {
            NSString *vv=self.localizedVarName;
            body=(!self.retainable?
                (self.hasIVar?
                    (self.retains?
                        (!self.atomic?
                            [NSMutableString stringWithFormat:
                                @"@-905 if(!memcmp(&%@,&%@,sizeof(%@)))return;@-900 memcpy(&%@,&%@,sizeof(%@));",vv,self.setterArg,vv,vv,self.setterArg,vv]:
                            [NSMutableString stringWithFormat:
                                @"@-905 @synchronized(self) {@-904 if(!memcmp(&%@,&%@,sizeof(%@)))return;memcpy(&%@,&%@,sizeof(%@));@-895}",vv,self.setterArg,vv,vv,self.setterArg,vv]):
                        (!self.atomic?
                            [NSMutableString stringWithFormat:
                                @"@-905 if(!memcmp(&%@,&%@,sizeof(%@)))return;@-900 memcpy(&%@,&%@,sizeof(%@));",vv,self.setterArg,vv,vv,self.setterArg,vv]:
                            [NSMutableString stringWithFormat:
                                @"@-905 @synchronized(self) {@-904 if(!memcmp(&%@,&%@,sizeof(%@)))return;memcpy(&%@,&%@,sizeof(%@));@-895}",vv,self.setterArg,vv,vv,self.setterArg,vv])):
                    [NSMutableString stringWithFormat:@""]):
                (self.hasIVar?
                    (self.retains?
                        (!self.atomic?
                            [NSMutableString stringWithFormat:
                                @"@-905 if(%@==%@)return;@-900 {%@=(id)%@;}",vv,self.setterArg,vv,self.setterArg]:
                            [NSMutableString stringWithFormat:
                                @"@-905 @synchronized(self) {@-904 if(%@==%@)return;@-900 {%@=(id)%@;}@-895}",vv,self.setterArg,vv,self.setterArg]):
                        (!self.atomic?
                            [NSMutableString stringWithFormat:
                                @"@-905 if(%@==%@)return;@-900 {%@=(id)%@;}",vv,self.setterArg,vv,self.setterArg]:
                            [NSMutableString stringWithFormat:
                                @"@-905 @synchronized(self) {@-904 if(%@==%@)return;{%@=(id)%@;}@-895}",vv,self.setterArg,vv,self.setterArg])):
                    [NSMutableString stringWithFormat:@""]));
        }
        
        if (self.readonly) {
            [body appendFormat:@"@-1999 if (!authorized_thread(__private_access_thread_mask_in___ClassName__)) ERR(\"Attempt to set public-readonly property in unauthorized thread (please try something like privateaccess(%@=\\\"blah\\\") to set the property)\");\n",self.localizedName];
        }
        
        if (self.tracked) {
            [body appendFormat:@"@-850 REMOVEOWNER(%@,self);ADDOWNER(%@,self);",self.localizedVarName,self.setterArg];
        }
        ret=body;//[WFn mergedBody:body with:@""].mutableCopy;
    }
)

CACHEVARATTRFN_retain(NSString*,localizedVarName,
    if (attributes) {
        for (NSString *attribute in attributes) {
            if ([attribute hasPrefix:@"privateivar="]) {
                ret=[attribute substringFromIndex:@"privateivar=".length];
            }
            if ([attribute hasPrefix:@"ivar="]) {
                ret=[attribute substringFromIndex:@"ivar=".length];
            }
            if ([attribute hasPrefix:@"justivar="]) {
                ret=[attribute substringFromIndex:@"justivar=".length];
            }
        }
    }
    if (!ret) {
        if (!self.retainable) ret=localizedName;
        else ret=[NSString stringWithFormat:@"v_%@",localizedName];
    }
)

-(char)varType {
    return(localizedType.clas?([localizedType.clas.name isEqualToString:@"NSArray"]||[localizedType.clas.name isEqualToString:@"NSMutableArray"]||[localizedType.clas.superType.clas.name isEqualToString:@"NSArray"]||[localizedType.clas.superType.clas.name isEqualToString:@"NSMutableArray"]?'A':([localizedType.clas.name isEqualToString:@"NSSet"]||[localizedType.clas.name isEqualToString:@"NSMutableSet"]||[localizedType.clas.superType.clas.name isEqualToString:@"NSSet"]||[localizedType.clas.superType.clas.name isEqualToString:@"NSMutableSet"]?'S':([localizedType.clas.name isEqualToString:@"NSDictionary"]||[localizedType.clas.name isEqualToString:@"NSMutableDictionary"]||[localizedType.clas.superType.clas.name isEqualToString:@"NSDictionary"]||[localizedType.clas.superType.clas.name isEqualToString:@"NSMutableDictionary"]?'M':'1'))):'1');
}

-(void)add:(WReader*)r {
    if (qname) {
        WReader *r2=[[WReader alloc] init];
        r2.tokenizer.tokenDelegate=[WClasses getDefault];
        
        //[WClasses note:[NSString stringWithFormat:@"Add var %@ %@ %c",self.localizedName,self.qname,[self varType]] withReader:r];
        r2.fileString=[WProp string:([WClasses getDefault].propFiles)[[NSString stringWithFormat:(self.localizedType.clas.isType?@"T%c":@"NS%c"),[self varType]]] withMyType:self.clas.wType myName:@"self" iamOwner:NO myQName:@"" hisType:self.localizedType hisName:self.localizedName heIsOwner:YES hisQName:self.qname qprop:@"" noPlurals:YES];
        r2._fileName=[NSString stringWithFormat:@"%@:(%@ >> %@)",r.fileName,[self.clas.wType wiType],self.qname];
        
        [[WClasses getDefault] read:r2 logContext:self];
    }
}

- (NSString*)objCType {
    return([type objCTypeWithStars:stars]);
}
- (NSString*)lazyObjCType {
    return([type objCTypeWithStars:((stars<=1)&&!self.isType?0:stars)]);
}
- (NSString*)localizedObjCType {
    return([localizedType objCTypeWithStars:stars]);
}
- (NSString*)lazyLocalizedObjCType {
    return([localizedType objCTypeWithStars:((stars<=1)&&!self.isType?0:stars)]);
}


-(bool)hasDefaultValue {
    double f;
    return(defaultValue&&!(
    [defaultValue isEqualToString:@"nil"]
    ||[defaultValue isEqualToString:@"null"]
    ||[defaultValue isEqualToString:@"NULL"]
    ||((sscanf(defaultValue.UTF8String,"%lf",&f)>0)&&!f)
    ));
}

- (void)addToFns {
    if (addedToFns) return;
    
    [self cacheAttributes];
    
    addedToFns=YES;
    if (self.imaginary) return;
    
    bool hasDef=NO;
    
    if (defaultValue) {
        hasDef=YES;
        if (self.hasDefaultValue&&self.hasIVar&&!self.imaginary) {
            if (self.retainable) {
                WReader *r=[[WReader alloc] init];
                r.fileString=defaultValue;
                NSMutableArray *bs=[NSMutableArray array];
                bool malformed=NO;
                Int rc=0;
                bool wasrelease=NO,wasretain=NO;
                bool wascopy=self.isBlock;
                for (WReaderToken *t in r.tokenizer.tokens) {
                    if ((t.type=='z')||(t.type=='c')||(t.type=='r')) continue;
                    if ([t.str isEqualToString:@"["]) [bs addObject:@"[]"];
                    else if ([t.str isEqualToString:@"{"]) [bs addObject:@"{}"];
                    else if ([t.str isEqualToString:@"("]) [bs addObject:@"()"];
                    else if ([t.str isEqualToString:@"]"]) {
                        if ((!bs.count)||![(NSString*)[bs lastObject] isEqualToString:@"[]"]) {malformed=YES;break;}
                        if (wascopy||wasretain) rc++;
                        else if (wasrelease) rc--;
                        [bs removeLastObject];
                    }
                    else if ([t.str isEqualToString:@"}"]) {
                        if ((!bs.count)||![(NSString*)[bs lastObject] isEqualToString:@"{}"]) {malformed=YES;break;}
                        [bs removeLastObject];
                    }
                    else if ([t.str isEqualToString:@")"]) {
                        if ((!bs.count)||![(NSString*)[bs lastObject] isEqualToString:@"()"]) {malformed=YES;break;}
                        [bs removeLastObject];
                    }
                    else if ([t.str isEqualToString:@"."]) {
                        if (wascopy) rc++;
                    }
                    wasretain=([t.str isEqualToString:@"retain"]||[t.str isEqualToString:@"alloc"]);
                    wasrelease=([t.str isEqualToString:@"release"]||[t.str isEqualToString:@"autorelease"]);
                    wascopy=([t.str isEqualToString:@"copy"]||[t.str isEqualToString:@"mutableCopy"]);
                }
                if (malformed) {
                    [WClasses error:@"Suspected malformed default value (brackets are weird)" withToken:nil context:self];
                }
                else if (rc<0) {
                    [WClasses error:@"Suspected negative reference count in default value" withToken:nil context:self];
                }
                else if (rc<0) {
                    [WClasses note:[NSString stringWithFormat:@"Suspected positive reference count in default value. odd"] withToken:nil context:self];
                }
            }
            [WFn getFnWithSig:@"-(init)" body:[NSString stringWithFormat:@"@-500 /*ivar*/%@=(%@);%@\n",self.localizedVarName,defaultValue,(self.tracked?[NSString stringWithFormat:@"  ADDOWNER(%@,self);",self.localizedVarName]:@"")] clas:clas];
        }
    }
    else if (attributes) {
        NSMutableString *def=[NSMutableString string];
        if (!def.length) for (NSString *s in attributes) {
            if ([s hasPrefix:@"-"]||[s hasPrefix:@"+"]) {
                WFn *fn=(clas.fns)[s];
                if (!fn) [WClasses error:[NSString stringWithFormat:@"Expected function with signature %@ for var %@",s,localizedName] withToken:nil context:self];
                else {
                    [def appendFormat:@"[NSDictionary dictionaryWithObjectsAndKeys:@\"%@\",@\"signature\",@\"%@\",@\"body\",nil]",s,[WVar escapeCString:[WFn balance:fn.sortedBody]]];
                }
                break;
            }
            else if ([s isEqualToString:@"varnames"]) {
                [def appendString:@"[NSSet setWithObjects:"];
                bool fst=YES;
                for (WVar *v in clas.vars.allValues) {
                    [def appendFormat:(fst?@"@\"%@\"":@",@\"%@\""),v.localizedName];
                    fst=NO;
                }
                [def appendString:(fst?@"nil]":@",nil]")];
                break;
            }
            else if ([s hasPrefix:@"varnames_"]) {
                [def appendString:@"[NSSet setWithObjects:"];
                bool fst=YES;
                NSString *s2=[s substringFromIndex:@"varnames_".length];
                for (WVar *v in clas.vars.allValues) if (v.attributes&&[v.attributes containsObject:s2]) {
                    [def appendFormat:(fst?@"@\"%@\"":@",@\"%@\""),v.localizedName];
                    fst=NO;
                }
                [def appendString:(fst?@"nil]":@",nil]")];
                break;
            }
            else if ([s isEqualToString:@"vars"]) {
                [def appendString:@"[NSSet setWithObjects:\n            "];
                bool fst=YES;
                for (WVar *v in clas.vars.allValues) {
                    if (!fst) [def appendString:@",\n            "];
                    NSString *className=nil;
                    for (NSString *s in v.attributes) if ([s hasPrefix:@"class="]) {
                        className=[s substringFromIndex:@"class=".length];break;
                    }
                    if (className) {
                        [def appendFormat:@"[NSDictionary dictionaryWithObjectsAndKeys:@\"%@\",@\"name\",@\"%@\",@\"type\",@\"%@\",@\"class\",nil]",v.localizedName,[v localizedObjCType],className];
                    }
                    else {
                        [def appendFormat:@"[NSDictionary dictionaryWithObjectsAndKeys:@\"%@\",@\"name\",@\"%@\",@\"type\",nil]",v.localizedName,[v localizedObjCType]];
                    }
                    fst=NO;
                }
                [def appendString:(fst?@"nil]":@",nil]")];
                break;
            }
            else if ([s hasPrefix:@"vars_"]) {
                [def appendString:@"[NSSet setWithObjects:\n            "];
                bool fst=YES;
                NSString *s2=[s substringFromIndex:@"vars_".length];
                for (WVar *v in clas.vars.allValues) if (v.attributes&&[v.attributes containsObject:s2]) {
                    if (!fst) [def appendString:@",\n            "];
                    NSString *className=nil;
                    for (NSString *s in v.attributes) if ([s hasPrefix:@"class="]) {
                        className=[s substringFromIndex:@"class=".length];break;
                    }
                    if (className) {
                        [def appendFormat:@"[NSDictionary dictionaryWithObjectsAndKeys:@\"%@\",@\"name\",@\"%@\",@\"type\",@\"%@\",@\"class\",nil]",v.localizedName,[v localizedObjCType],className];
                    }
                    else {
                        [def appendFormat:@"[NSDictionary dictionaryWithObjectsAndKeys:@\"%@\",@\"name\",@\"%@\",@\"type\",nil]",v.localizedName,[v localizedObjCType]];
                    }
                    fst=NO;
                }
                [def appendString:(fst?@"nil]":@",nil]")];
                break;
            }                    
        }
        if (def.length) {
            hasDef=YES;
            [WFn getFnWithSig:@"-(init)" body:[NSString stringWithFormat:@"@-500         /*ivar*/%@=(id)%@;\n",localizedVarName,def] clas:clas];
        }
    }
    if (self.hasIVar&&!(hasDef||[attributes containsObject:@"nodef"]||self.imaginary)) {
        [WClasses warning:[NSString stringWithFormat:@"Non-imaginary variable %@ has an ivar, but no default value. This is less a strict error than unclean",self.localizedName] withToken:nil context:self];
    }

    if (self.retains&&self.hasIVar) {
        [WFn getFnWithSig:@"-(void)dealloc" body:(self.tracked?[NSString stringWithFormat:@"\n    REMOVEOWNER(%@,self);%@=nil;",self.localizedVarName,self.localizedVarName]:[NSString stringWithFormat:@"\n%@=nil;",self.localizedVarName]) clas:clas];
    }
    if (self.needsGetter) {
        WFn *fn=self.hasGetter;
        if (fn) fn.body=self.localizedGetterBody;
        else [WFn getFnWithSig:self.getterSig body:self.localizedGetterBody clas:clas];
    }
    if (self.needsSetter) {
        WFn *fn=self.hasSetter;
        if (fn) fn.body=self.localizedSetterBody;
        else [WFn getFnWithSig:self.setterSig body:self.localizedSetterBody clas:clas];
    }
    if (self.objc_readonly&&self.retainable&&self.hasIVar&&(![clas.varPatterns containsObject:@"-Object"])&&!(self.localizedType.clas.isSys||self.localizedType.clas.isType||[attributes containsObject:@"readonly!"])) {
        [WClasses note:[NSString stringWithFormat:@"Please think about making property \"%@\" publicreadonly",self.localizedName] withToken:nil context:self];
    }
}


- (void)appendObjCToString_iface:(NSMutableString*)s {
    if (self.imaginary||self.justivar) return;
    [s appendFormat:@"@property (%@%@%@%@%@%@%@",
        !(self.hasIVar&&self.retainable)?@"":(self.copies?@"copy,":(self.retains?@"strong,":@"weak,")),
        self.atomic?@"atomic,":@"nonatomic,",
        self.objc_readonly?@"readonly,":(self.readonly?@"readwrite/*(public readonly)*/,":@"readwrite,"),
        [attributes containsObject:@"strong"]?@"strong,":@"",
        [attributes containsObject:@"unsafe_unretained"]?@"unsafe_unretained,":@"",
        self.localizedGetterName&&![self.localizedGetterName isEqualToString:localizedName]?[NSString stringWithFormat:@"getter=%@,",self.localizedGetterName]:@"",
        self.localizedSetterName&&![self.localizedSetterName isEqualToString:[NSString stringWithFormat:@"set%@",[WProp upperName:self.localizedName]]]?[NSString stringWithFormat:@"setter=%@:,",self.localizedSetterName]:@""
    ];
    if ([s hasSuffix:@","]) [s replaceCharactersInRange:NSMakeRange(s.length-1,1) withString:@""];
    [s appendFormat:@") %@%@ %@;\n",
        [attributes containsObject:@"IBOutlet"]?@"IBOutlet ":@"",
        self.localizedObjCType,localizedName];
}

- (void)appendObjCToString_impl:(NSMutableString*)s {
    if (self.imaginary) return;
    //if (self.clas.isSys&&self.hasIVar) {
    //    [s appendFormat:@"@dynamic %@=%@;\n",localizedName,[self varName]];
    //}
    if (self.hasIVar&&!(self.clas.isSys||self.justivar||self.synthesized)) {
        [s appendFormat:@"@synthesize %@=%@;\n",localizedName,[self localizedVarName]];
    }
}
- (void)appendObjCToString_ivar:(NSMutableString *)s {
    if (self.imaginary) return;
    if (self.superHasIVar) return;
    if (!self.hasIVar) return;
    [s appendFormat:@"    %@%@ %@;%@\n",(self.privateIVar?@"@private ":@""),self.localizedObjCType,self.localizedVarName,(self.privateIVar?@" @protected":@"")];
}
@end

