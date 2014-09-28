
@implementation WClass
@synthesize name,superType,varNames,vars,fns,varPatterns,fnNames,isProtocol,isType,isBlock,isSys,hasDef,isWIOnly;
@synthesize ownedNum,ownsNum,ocppCompatible=_ocppCompatible,swiftCompatible=_swiftCompatible;

- (void)dealloc {
    self.name=nil;
    self.superType=nil;
    self.varPatterns=nil;
    self.fns=self.vars=nil;
    self.varNames=self.fnNames=nil;
}

- (id)initClassWithName:(NSString*)aname superClass:(WClass*)superClass protocolList:(NSArray*)protocolList varPatterns:(NSSet *)avarPatterns {
    if (!(aname&&((self=[super init])))) return(nil);
    ocppCompatible=swiftCompatible=YES;
    self.name=aname;
    dprnt("Class : %s\n",aname.UTF8String);
    hasDef=NO;
    self.superType=[WType newWithClass:superClass protocols:protocolList addObject:NO];
    self.varPatterns=avarPatterns.copy;
    if ([name rangeOfString:@"__WIClass__"].location!=NSNotFound) {
        self.varPatterns=[[[(self.varPatterns?self.varPatterns:[NSSet set]) setByAddingObject:@"nac"] setByAddingObject:@"multi"] setByAddingObject:@"undefined"];
    }
    self.vars=[NSMutableDictionary dictionary];
    self.fns=[NSMutableDictionary dictionary];
    ([WClasses getDefault].classes)[aname] = self;
    self.isProtocol=NO;
    self.isSys=self.isType=self.isBlock=self.isWIOnly=NO;
    _depth=NSNotFound;
    return(self);
}

- (id)initProtocolWithName:(NSString*)aname superList:(NSArray *)asuperList varPatterns:(NSSet*)avarPatterns {
    if (!(self=[super init])) return(nil);
    ocppCompatible=swiftCompatible=YES;
    self.name=aname;
    dprnt("Protocol : %s\n",aname.UTF8String);
    hasDef=NO;
    self.superType=[WType newWithClass:nil protocols:asuperList addObject:NO];
    self.varPatterns=avarPatterns.copy;
    //if ([name isEqualToString:@"Object"]||[name isEqualToString:@"Globals"]) {
    //    self.varPatterns=[[[(self.varPatterns?self.varPatterns:[NSSet set]) setByAddingObject:@"nac"] setByAddingObject:@"multi"] setByAddingObject:@"undefined"];
    //}
    self.vars=[NSMutableDictionary dictionary];
    self.fns=[NSMutableDictionary dictionary];
    ([WClasses getDefault].protocols)[aname] = self;
    self.isProtocol=YES;
    self.isSys=self.isType=self.isBlock=self.isWIOnly=NO;
    _depth=NSNotFound;
    return(self);
}

+ (WClass*)getClassWithName:(NSString *)aname {
    return([WClass getClassWithName:aname superClass:nil protocolList:nil varPatterns:nil]);
}
+ (WClass*)getProtocolWithName:(NSString *)aname {
    return([WClass getProtocolWithName:aname superList:nil varPatterns:nil]);
}

-(bool)retainable {
    return([self.varPatterns containsObject:@"retains"]||[self.varPatterns containsObject:@"copies"]||self.isBlock||!self.isType);
}

-(bool)ocppCompatible {
    if (!_refreshedCompat) [self refreshCompatability];
    return(_ocppCompatible);
}

-(bool)swiftCompatible {
    if (!_refreshedCompat) [self refreshCompatability];
    return(_swiftCompatible);
}

-(void)refreshCompatability {
    if (_refreshedCompat) return;
    _refreshedCompat=YES;
    _ocppCompatible=ocppCompatible&&superType.ocppCompatible;
    _swiftCompatible=swiftCompatible&&superType.swiftCompatible;
    if (_swiftCompatible&&[varPatterns containsObject:@"cpp"]) _swiftCompatible=NO;
    if (_ocppCompatible&&[varPatterns containsObject:@"swift"]) _ocppCompatible=NO;

    if (_swiftCompatible) for (NSString *p in varPatterns) if ([p hasPrefix:@"typedef"]) {
        if ([p rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"&"] options:0 range:NSMakeRange(0, p.length)].location!=NSNotFound) {
            _swiftCompatible=NO;break;
        }
        NSRange r=NSMakeRange([p rangeOfString:@":"].location,[p rangeOfString:@"<"].location);
        if ((r.location!=NSNotFound)&&((r.length==NSNotFound)||(r.length>r.location+1))) {
            r.location++;
            bool couldBeTemplate=(r.length!=NSNotFound);
            if (r.length==NSNotFound) r.length=p.length;
            r.length-=r.location;
            NSString *className=[[p substringWithRange:r] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
            Int i=[className rangeOfCharacterFromSet:[NSCharacterSet.alphanumericCharacterSet invertedSet] options:NSBackwardsSearch].location;
            if (i!=NSNotFound) className=[[className substringFromIndex:i+1] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
            WClass *clas=WClasses.getDefault.classes[className];
            if ((couldBeTemplate&&!clas.retainable)||(clas&&!clas.swiftCompatible)) {
                _swiftCompatible=NO;break;
            }
        }
    }

    for (id<NSCopying> key in vars) [(WVar*)vars[key] refreshCompatability];
    for (id<NSCopying> key in fns) [(WVar*)fns[key] refreshCompatability];
}

+ (WClass*)getClassWithName:(NSString *)aname superClass:(WClass*)superClass protocolList:(NSArray*)protocolList varPatterns:(NSSet *)avarPatterns {
    WClass *ret=([WClasses getDefault].classes)[aname];
    if (ret) {
        [ret.superType addClass:superClass protocols:protocolList];
        if (avarPatterns) {
            if (ret.varPatterns) {
                NSMutableSet *ms=ret.varPatterns.mutableCopy;
                [ms unionSet:avarPatterns];
                ret.varPatterns=ms;
            }
            else ret.varPatterns=avarPatterns.copy;
        }
    }
    else ret=[[WClass alloc] initClassWithName:aname superClass:superClass protocolList:protocolList varPatterns:avarPatterns];
    return(ret);
}

+ (WClass*)getProtocolWithName:(NSString *)aname superList:(NSArray *)asuperList varPatterns:(NSSet*)avarPatterns {
    WClass *ret=([WClasses getDefault].protocols)[aname];
    if (ret) {
        if (asuperList) [ret.superType addClass:nil protocols:asuperList];
        if (avarPatterns) {
            if (ret.varPatterns) {
                NSMutableSet *ms=ret.varPatterns.mutableCopy;
                [ms unionSet:avarPatterns];
                ret.varPatterns=ms;
            }
            else ret.varPatterns=avarPatterns.copy;
        }
    }
    else ret=[[WClass alloc] initProtocolWithName:aname superList:asuperList varPatterns:avarPatterns];
    return(ret);
}

-(NSString*)filename {
    for (NSString *p in self.varPatterns) {
        if ([p hasPrefix:@"fn:"]) {
            return([p substringFromIndex:@"fn:".length]);
        }
        if ([p hasPrefix:@"_fn:"]) {
            return([p substringFromIndex:@"_fn:".length]);
        }
    }
    return(@"default");
}

-(bool)exists {
    bool ret=(!([self.varPatterns containsObject:@"nac"]||[self.varPatterns containsObject:@"nap"]||[self.varPatterns containsObject:@"notaclass"]));
    return(ret);
}

-(NSString*)localizeString:(NSString*)s {
    return([WProp string:s replacePairs:
        @"__ClassName__",self.name,
        @"__className__",[WProp lowerName:self.name],
        @"__WIClass__",(self.isProtocol?[NSString stringWithFormat:@"<%@>",self.name]:self.name),
        @"__Class__",[WType objCTypeWithClass:(self.isProtocol?nil:self) protocols:(self.isProtocol?[NSSet setWithObject:self]:nil) stars:-1],
        nil]);
}

-(WType*)localizeType:(WType*)atype {
    NSMutableSet *altypeps=(atype.protocols?[NSMutableSet set]:nil);
    for (WClass *p in atype.protocols) {
        [altypeps addObject:[WClass getProtocolWithName:[self localizeString:p.name]]];
    }
    NSString *altypec=[self localizeString:atype.clas.name];
    if (![altypec isEqualToString:atype.clas.name]) {
        WReader *r=[[WReader alloc] init];
        r.fileString=altypec;
        WPotentialType *t=[[WClasses getDefault] readPotentialType:r];
        altypec=t.clas;
        for (NSString *p in t.protocols) {
            [altypeps addObject:[WClass getProtocolWithName:p]];
        }
    }
    return([WType newWithClass:[WClass getClassWithName:altypec] protocols:altypeps.allObjects addObject:NO]);
}


+(NSString*)objCTypeWithClass:(WClass*)type_class protocols:(NSSet*)type_protocols stars:(Int)stars {
    NSMutableString *ret=(type_class?[NSMutableString stringWithFormat:(type_class.isProtocol?@"NSObject<%@>":(type_class.isType?(type_class.vars.count?@"struct %@":@"%@"):@"%@")),type_class.name]:[NSMutableString stringWithString:@"NSObject"]);
    if (((!type_class)||!(type_class.isProtocol||type_class.isType))&&type_protocols.count) {
        bool fst=YES;
        for (WClass *c in type_protocols) {
            if (c.isProtocol) {
                [ret appendFormat:(fst?@"<%@":@",%@"),c.name];
                fst=NO;
            }
        }
        if (!fst) [ret appendString:@">"];
    }
    if ((!stars)&&!type_class.isType) stars=1;
    while (stars-->0) [ret appendString:@"*"];
    return(ret);
}

- (Int)depthWithStack:(NSMutableSet *)stack {
    if (!stack) stack=[NSMutableSet set];
    if (_depth==NSNotFound) {
        if ([stack containsObject:self]) {
            NSMutableString *s=[NSMutableString string];
            for (WClass *c in stack) [s appendFormat:@"%@ ",c.name];
            [WClasses error:[NSString stringWithFormat:@"Circular super structure involving : %@",s] withToken:nil context:nil];
            _depth=0;
        }
        else {
            [stack addObject:self];
            Int maxch=-1;
            if (self.superType.clas) {
                maxch=[self.superType.clas depthWithStack:stack];
            }
            for (WClass *c in self.superType.protocols) {
                maxch=MAX(maxch,[c depthWithStack:stack]);
            }
            _depth=maxch+1;
        }
    }
    return(_depth);
}
- (Int)depth {
    return([self depthWithStack:nil]);
}

- (void)getNames {
    self.fnNames=[self.fns.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *n1=(NSString*)obj1,*n2=(NSString*)obj2;
        return([WFn compareName:n1 withName:n2]);
    }];
    self.varNames=[self.vars.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *n1=(NSString*)obj1,*n2=(NSString*)obj2;
        return([WVar compareName:n1 withName:n2]);
    }];
}



- (void)appendWithSelector:(SEL)sel string:(NSMutableString*)s {
    for (NSString *n in self.varNames) {
        WVar *v=(self.vars)[n];
        if ([v respondsToSelector:sel]) {
            COMPAT(v,[v performUnknownSelector:sel withObject:s]);
        }
    }    
    for (NSString *n in self.fnNames) {
        WFn *fn=(self.fns)[n];
        if ([fn respondsToSelector:sel]) {
            COMPAT(fn,[fn performUnknownSelector:sel withObject:s]);
        }
    }    
}

- (void)appendObjCToString_iface:(NSMutableString*)s {
    [self getNames];
    //NSArray *props=[WClasses getDefault].props;
    NSMutableString *protStr=[NSMutableString string];
    NSArray *names=[NSMutableArray array];
    
    if (self.superType.protocols.count) {
        names=[[self addSuperProtocolNamesTo:nil].allObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return([(NSString*)obj1 compare:obj2]);
            }];
    }
    if ((!superType.clas)||superType.clas.isType||superType.clas.isSys) {
        if ((![self.varPatterns containsObject:@"-Object"])&&![names containsObject:@"Object"]) {
            names=[names arrayByAddingObject:@"Object"];
        }
    }
    else {
        if ((![self.varPatterns containsObject:@"-Object"])&&![names containsObject:@"DerivedObject"]) {
            names=[names arrayByAddingObject:@"DerivedObject"];
        }
    }
    if ((![self.varPatterns containsObject:@"-Object"])&&![names containsObject:@"ClassObject"]) {
        names=[names arrayByAddingObject:@"ClassObject"];
    }

    if (names.count) {
        bool fst=YES;
        for (NSString *n in names) {
            [protStr appendFormat:@"%@%@",fst?@"<":@", ",n];
            fst=NO;
        }
        if (!fst) [protStr appendString:@">"];
    }
    
    if (isSys) [s appendFormat:@"@interface %@(winterface)\n",self.name];
    else {
        WClass *sup;for (sup=self.superType.clas;sup&&!sup.exists;sup=sup.superType.clas);
        [s appendFormat:@"@interface %@ : %@%@ {\n",self.name,sup?sup.name:@"NSObject",protStr];
    }
    if (!isSys) {
        [self appendWithSelector:@selector(appendObjCToString_ivar:) string:s];
/*    for (WProp *prop in props) {
        if (prop.myclas==self) [prop appendObjCToString_ivar_myclass:s];
        if (prop.hisclas==self) [prop appendObjCToString_ivar_hisclass:s];
    }*/
    
        [s appendFormat:@"}"];
    }
    [s appendFormat:@"\n\n"];
    [self appendWithSelector:@selector(appendObjCToString_iface:) string:s];
    /*
    for (WProp *prop in props) {
        if (prop.myclas==self) [prop appendObjCToString_iface_myclass:s];
        if (prop.hisclas==self) [prop appendObjCToString_iface_hisclass:s];
    }
    */
    [s appendFormat:@"\n@end\n"];
}

- (void)appendObjCToString_impl:(NSMutableString*)s {
    [self getNames];
    //NSArray *props=[WClasses getDefault].props;
    [s appendFormat:@"#define _ClassName_ %@\n",[self localizeString:@"__ClassName__"]];
    [s appendFormat:@"#define _WIClass_ %@__\n",[self localizeString:@"__WIClass__"]];
    [s appendFormat:@"#define _className_ %@\n",[self localizeString:@"__className__"]];
    [s appendFormat:@"#define _Class_ %@__\n",[self localizeString:@"__Class__"]];
    [s appendFormat:(isSys?@"@implementation %@(winterface)\n\n":@"@implementation %@\n\n"),self.name];
    [self appendWithSelector:@selector(appendObjCToString_impl:) string:s];
/*    for (WProp *prop in props) {
        if (prop.myclas==self) [prop appendObjCToString_impl_myclass:s];
        if (prop.hisclas==self) [prop appendObjCToString_impl_hisclass:s];
     }
     */
    [s appendFormat:@"\n@end\n"];
    [s appendFormat:@"#undef _ClassName_\n"];
    [s appendFormat:@"#undef _WIClass_\n"];
    [s appendFormat:@"#undef _className_\n"];
    [s appendFormat:@"#undef _Class_\n"];
}

- (NSMutableSet*)addSuperProtocolNamesTo:(NSMutableSet*)to {
    if (!to) to=[NSMutableSet set];
    for (WClass *c in self.superType.protocols) if (![to containsObject:c.name]) {
        if (c.exists) [to addObject:c.name];
        else [c addSuperProtocolNamesTo:to];
    }
    return(to);
}

- (void)appendObjCToString_protocol:(NSMutableString*)s {
    [self getNames];
    if (self.isSys) return;
    NSMutableString *protStr=[NSMutableString string];
    if (self.superType.protocols.count) {
        NSArray *names=[[self addSuperProtocolNamesTo:nil].allObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return([(NSString*)obj1 compare:obj2]);
            }];
        bool fst=YES;
        for (NSString *n in names) {
            [protStr appendFormat:@"%@%@",fst?@"<":@", ",n];
            fst=NO;
        }
        if (!fst) [protStr appendString:@">"];
    }
    [s appendFormat:@"@protocol %@ %@\n",self.name,protStr];
    [self appendWithSelector:@selector(appendObjCToString_iface:) string:s];
    [s appendFormat:@"\n@end\n"];
}

- (void)appendObjCToString_struct:(NSMutableString*)s {
    [self getNames];
    [s appendFormat:@"struct %@ {\n",self.name];
    [self appendWithSelector:@selector(appendObjCToString_ivar:) string:s];
    [s appendFormat:@"};\n"];
}

- (bool)empty {
    return(isSys&&!(vars.count||fns.count));
}

- (void)addProtocolToClass:(WClass*)forClas included:(NSMutableSet*)included stack:(NSMutableArray*)stack {
    if ([included containsObject:self.name]) return;
    if (![self.varPatterns containsObject:@"multi"]) [included addObject:self.name];
    
    for (WVar *v in self.vars.allValues) {
//        if (![WVar getExistingVarWithName:v.name clas:forClas]) {
            //WVar *newv=
            NSMutableSet *attrs=(v.attributes?[NSMutableSet set]:nil);
            if (attrs) for (NSString *s in v.attributes) {
                [attrs addObject:[WClasses processClassString:s class:forClas protocols:stack]];
            }
        
            Int stars=0;
            WVar *v2=[WVar getVarWithType:[WClasses processClassType:v.type class:forClas protocols:stack tostars:&stars]
                stars:v.stars+stars
                name:[WClasses processClassString:v.name class:forClas protocols:stack]
                qname:[WClasses processClassString:v.qname class:forClas protocols:stack]
                defVal:[WClasses processClassString:v.defaultValue class:forClas protocols:stack]
                defValLevel:v.defLevel attributes:attrs clas:forClas];
            v2.useLocationsFrom=v.useLocationsFrom;
            for (NSString *fn in v.inFilesLocations) {
                for (NSValue *vv in (NSSet*)(v.inFilesLocations)[fn]) {
                    [v2 addInFilename:fn line:(Int)vv.rangeValue.location column:(Int)vv.rangeValue.length];
                }
            }
//        }
    }
    for (WFn *fn in self.fns.allValues) {
//        WFn *prvFn;
//        if (!((prvFn=[WFn getExistingFnWithSig:fn.sig clas:forClas])&&prvFn.body)) {
            //WFn *newfn=
            WFn *fn2=[WFn getFnWithSig:
                [WClasses processClassString:fn.sig class:forClas protocols:stack]
                body:[WClasses processClassString:fn.body class:forClas protocols:stack]
                clas:forClas];
        fn2.useLocationsFrom=fn.useLocationsFrom;
        for (NSString *fname in fn.inFilesLocations) {
            for (NSValue *vv in (NSSet*)(fn.inFilesLocations)[fname]) {
                [fn2 addInFilename:fname line:(Int)vv.rangeValue.location column:(Int)vv.rangeValue.length];
            }
        }
//            newfn.imaginary=fn.imaginary;
//        }
    }
    if (self.superType.protocols) {
        [stack addObject:self];
        for (WClass *p in self.superType.protocols) if (!(forClas.isProtocol&&p.exists)) {
            [p addProtocolToClass:forClas included:included stack:stack];
        }
        [stack removeLastObject];
    }
}

-(void)addProtocolToFns {
    [self addClassToFns];
}
- (void)addClassToFns {
    if (addedToFns) return;
    if (!([varPatterns containsObject:@"undefined"]||self.hasDef)) {
        [WClasses error:[NSString stringWithFormat:(isProtocol?@"Protocol %@ is used but never really defined, and is likely a typo":@"Class %@ is used but never really defined, and is likely a typo"),self.name] withToken:nil context:self];
    }
    if (isType) return;
    addedToFns=YES;
    if (!(self.isProtocol||superType.clas.isType)) [WProp stadd:self];
    NSMutableSet *included=[NSMutableSet set];
    if (self.superType.protocols) {
        if (!self.isProtocol) {
            for (WClass *p in self.superType.protocols) {
                [p addProtocolToClass:self included:included stack:[NSMutableArray array]];
            }
        }
        else {
            for (WClass *p in self.superType.protocols) if (!p.exists) {
                [p addProtocolToClass:self included:included stack:[NSMutableArray array]];
            }
        }
    }
    if (!self.isProtocol) {
        if (!isSys) {
            if (![varPatterns containsObject:@"-Object"]) {
                WClass *objectClass;
                if ((!superType.clas)||superType.clas.isType||superType.clas.isSys) {
                    objectClass=([WClasses getDefault].protocols)[@"Object"];
                    if (objectClass) {
                        [objectClass addProtocolToClass:self included:included stack:[NSMutableArray array]];
                        [self.superType.protocols addObject:objectClass];
                    }
                }
                else {
                    objectClass=([WClasses getDefault].protocols)[@"DerivedObject"];
                    if (objectClass) {
                        [objectClass addProtocolToClass:self included:included stack:[NSMutableArray array]];
                        [self.superType.protocols addObject:objectClass];
                    }
                }
            }
            if (![varPatterns containsObject:@"-Object"]) {
                WClass *classClass=([WClasses getDefault].protocols)[@"ClassObject"];
                if (classClass) {
                    [classClass addProtocolToClass:self included:included stack:[NSMutableArray array]];
                    [self.superType.protocols addObject:classClass];
                }
            }
        }
        for (WVar *v in self.vars.allValues) [v addToFns];
    }
}

-(WType*)wType {
    return([WType newWithClass:(self.isProtocol?nil:self) protocols:(self.isProtocol?@[self]:nil) addObject:NO]);
}

//@synthesize name,superType,varNames,vars,fns,varPatterns,fnNames,isProtocol,isType,isSys,hasDef,isWIOnly;

-(NSString*)tag {return([NSString stringWithFormat:(isProtocol?@"protocol_%@":@"class_%@"),name]);}

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

-(void)addjsvars:(NSMutableDictionary*)dict {
    NSMutableString *val=[NSMutableString stringWithString:@"<ul>"];
    if (self.superType.clas) {
        NSString *n=[NSString stringWithFormat:@"super_%@",self.superType.clas.tag];
        [val appendFormat:@"<li><span style='color:%@' onclick=\"classclick('PATH_%@_own','%@','own')\">%@</span>",self.color,n,self.superType.clas.tag,[WClasses htmlStringForString:self.superType.clas.wType.wiType]];
        [val appendFormat:@"<span style='color:%@' onclick=\"classclick('PATH_%@_info','%@','info')\"> -- (info)</span><span id='PATH_%@_info'></span><span id='PATH_%@_own'></<span>",self.superType.clas.color,n,self.superType.clas.tag,n,n];
        [val appendFormat:@"</li>"];
    }
    for (WClass *p in self.superType.protocols) {
        NSString *n=[NSString stringWithFormat:@"prot_%@",p.tag];
        [val appendFormat:@"<li><span style='color:%@' onclick=\"classclick('PATH_%@_own','%@','own')\">%@</span>",self.color,n,p.tag,[WClasses htmlStringForString:p.wType.wiType]];
        [val appendFormat:@"<span style='color:%@' onclick=\"classclick('PATH_%@_info','%@','info')\"> -- (info)</span><span id='PATH_%@_info'></span><span id='PATH_%@_own'></<span>",p.color,n,p.tag,n,n];
        [val appendFormat:@"</li>"];
    }
    [val appendString:@"</ul>"];
//    [dict setObject:val forKey:[self.tag stringByAppendingString:@"_super"]];
    
//    val=[NSMutableString stringWithString:@"<ul>"];
    [val appendString:@"<ul>"];
    for (NSString *vn in varNames) {
        WVar *v=vars[vn];
        if (!(v.type.clas.isSys||!v.retains)) {
            NSString *n=[NSString stringWithFormat:@"own_var_%@",vn];
            [val appendFormat:@"<li><span style='color:%@' onclick=\"classclick('PATH_%@_own','%@','own')\">%@</span> %@",v.color,n,v.type.clas.tag,[WClasses htmlStringForString:v.type.clas.wType.wiType],[WClasses htmlStringForString:v.name]];
            if (v.defaultValue) [val appendFormat:@"=%@",[WClasses htmlStringForString:v.defaultValue]];
            if (v.attributes) {
                [val appendFormat:@" ("];
                for (NSString *a in v.attributes) [val appendFormat:@" %@",[WClasses htmlStringForString:a]];
                [val appendFormat:@" )"];
            }
            [val appendFormat:@"<span style='color:%@' onclick=\"classclick('PATH_%@_info','%@','info')\"> -- (info)</span><span id='PATH_%@_info'></span><span id='PATH_%@_own'></<span>",v.color,n,v.type.clas.tag,n,n];
            [val appendFormat:@"</li>"];
        }
    }
    for (WProp *p in [WClasses getDefault].props) {
        if (p.myclas==self) {
            NSString *n=[NSString stringWithFormat:@"myprop_%@",p.hisname];
            [val appendFormat:@"<li>as %@",p.myname];
            if (p.myqname) [val appendFormat:@">>%@",p.myqname];
            [val appendFormat:@" %@ <span style='color:%@' onclick=\"classclick('PATH_%@_own','%@','own')\">%@</span> %@",[WClasses htmlStringForString:p.origType],p.hisclas.color,n,p.hisclas.tag,[WClasses htmlStringForString:p.hisclas.wType.wiType],p.hisname];
            if (p.hisqname) [val appendFormat:@">>%@",p.hisqname];
            [val appendFormat:@"<span onclick=\"classclick('PATH_%@_info','%@','info')\"> -- (info)</span><span id='PATH_%@_info'></span><span id='PATH_%@_own'></<span>",n,p.hisclas.tag,n,n];
            [val appendFormat:@"</li>"];
        }
        if (p.hisclas==self) {
            NSString *n=[NSString stringWithFormat:@"hisprop_%@",p.myname];
            [val appendFormat:@"<li>as %@",p.hisname];
            if (p.hisqname) [val appendFormat:@">>%@",p.hisqname];
            [val appendFormat:@" %@ <span style='color:%@' onclick=\"classclick('PATH_%@_own','%@','own')\">%@</span> %@",[WClasses htmlStringForString:p.origType],p.myclas.color,n,p.myclas.tag,[WClasses htmlStringForString:p.myclas.wType.wiType],p.myname];
            if (p.myqname) [val appendFormat:@">>%@",p.myqname];
            [val appendFormat:@"<span onclick=\"classclick('PATH_%@_info','%@','info')\"> -- (info)</span><span id='PATH_%@_info'></span><span id='PATH_%@_own'></<span>",n,p.myclas.tag,n,n];
            [val appendFormat:@"</li>"];
        }
    }
    [val appendFormat:@"</ul>\n"];
    dict[[self.tag stringByAppendingString:@"_own"]] = val;
    //[dict setObject:@"jj" forKey:[self.tag stringByAppendingString:@"_own"]];
    
    dict[[self.tag stringByAppendingString:@"_info"]] = self.infoStr;


    val=[NSMutableString stringWithFormat:@"<span style='color:%@' onclick=\"classclick('PATH_own','%@','own')\">%@</span><span onclick=\"classclick('PATH_info','%@','info')\">(info)</span><span id='PATH_info'></span><span id='PATH_own'></<span>",self.color,self.tag,[WClasses htmlStringForString:self.wType.wiType],self.tag];
    dict[[self.tag stringByAppendingString:@"_."]] = val;
}
    

-(NSString*)infoStr {
    NSMutableString *ret=[NSMutableString stringWithFormat:@"%@%@%@%@%@",self.swiftCompatible?@"":@"(C++) ",self.ocppCompatible?@"":@"(swift) ",isSys?@"sys ":@"",isBlock?@"block ":@"",isType?@"type ":@""];
    for (NSString *p in varPatterns) [ret appendFormat:@"'%@' ",[WClasses htmlStringForString:p]];
    if (varNames.count) {
        [ret appendFormat:@"<ul>"];
        for (NSString *n in varNames) {
            WVar *v=vars[n];
            if (v.type.clas.isSys||!v.retains) {
                [ret appendFormat:@"<li><span style='color:%@'>%@ %@</span>",v.color,[WClasses htmlStringForString:v.type.wiType],v.localizedVarName];
                if (v.defaultValue) [ret appendFormat:@"=%@",[WClasses htmlStringForString:v.defaultValue]];
                if (v.attributes) {
                    [ret appendFormat:@" ("];
                    for (NSString *a in v.attributes) [ret appendFormat:@" %@",[WClasses htmlStringForString:a]];
                    [ret appendFormat:@" )"];
                }
                [ret appendFormat:@"</li>\n"];
            }
        }
        [ret appendFormat:@"</ul>\n"];
    }
    if (fnNames.count) {
        [ret appendFormat:@"<ul>"];
        for (NSString *n in fnNames) {
            WFn *fn=fns[n];
            [ret appendFormat:@"<li><span style='color:%@'>%@</span></li>\n",fn.color,[WClasses htmlStringForString:fn.sig]];
        }
        [ret appendFormat:@"</ul>\n"];
    }
    return(ret);
}
-(void)addOwnership {
    [self getNames];
    ownsNum=0;
    for (NSString *n in varNames) {
        WVar *v=vars[n];
        if ((v.type.clas!=self)&&!(v.type.clas.isSys||!v.retains)) {
            ownsNum++;
            v.type.clas.ownedNum++;
        }
    }
    for (WProp *p in [WClasses getDefault].props) {
        if ((p.myclas==self)&&(p.hisclas!=self)&&p.ownerIsMe) {
            ownsNum++;
            p.hisclas.ownedNum++;
        }
        if ((p.hisclas==self)&&(p.myclas!=self)&&p.ownerIsHim) {
            ownsNum++;
            p.myclas.ownedNum++;
        }
    }
    if (self.superType.clas) {
        ownsNum++;
        self.superType.clas.ownedNum++;
    }
    for (WClass *p in self.superType.protocols) {
        p.ownedNum++;
        ownsNum++;
    }
}

-(NSString*)html:(NSMutableDictionary*)tags andName:(bool)andName {
    [self getNames];
    if (tags[[self tag]]) return(andName?tags[[self tag]]:@"");
    tags[[self tag]] = [NSString stringWithFormat:@"<b>%@</b>",name];

    NSMutableString *ret=[NSMutableString string];
    if (andName) [ret appendFormat:@"<span id='class_%@'><b>%@</b>",name,[WClasses htmlStringForString:self.wType.wiType]];
    [ret appendFormat:@"<span id='classinfo_%@'> %@ </span><span id='classlinks_%@'>",name,[self infoStr],name];
    [ret appendFormat:@"<ul>\n"];
    if (self.superType.clas) {
        [ret appendFormat:@"<li>%@</li>",[self.superType.clas html:tags andName:YES]];
    }
    for (WClass *p in self.superType.protocols) {
        [ret appendFormat:@"<li>%@</li>",[p html:tags andName:YES]];
    }
    for (NSString *n in varNames) {
        WVar *v=vars[n];
        if (!(v.type.clas.isSys||!v.retains)) {
            [ret appendFormat:@"<li><span style='color:%@'>%@ %@</span>",v.color,[WClasses htmlStringForString:v.type.wiType],v.localizedVarName];
            if (v.defaultValue) [ret appendFormat:@"=%@",[WClasses htmlStringForString:v.defaultValue]];
            if (v.attributes) {
                [ret appendFormat:@" ("];
                for (NSString *a in v.attributes) [ret appendFormat:@" %@",[WClasses htmlStringForString:a]];
                [ret appendFormat:@" )"];
            }
            [ret appendFormat:@"%@",[v.type.clas html:tags andName:NO]];
            [ret appendFormat:@"</li>\n"];
        }
    }
    for (WProp *p in [WClasses getDefault].props) {
        if (p.myclas==self) {            
            [ret appendFormat:@"<li>as %@",p.myname];
            if (p.myqname) [ret appendFormat:@">>%@",p.myqname];
            [ret appendFormat:@" %@ <b>%@</b> %@",[WClasses htmlStringForString:p.origType],[WClasses htmlStringForString:p.hisclas.wType.wiType],p.hisname];
            if (p.hisqname) [ret appendFormat:@">>%@",p.hisqname];
            if (p.ownerIsMe) {
                [ret appendString:[p.hisclas html:tags andName:NO]];
            }
            [ret appendFormat:@"</li>\n"];
        }
        if (p.hisclas==self) {
            [ret appendFormat:@"<li>as %@",p.hisname];
            if (p.hisqname) [ret appendFormat:@">>%@",p.hisqname];
            [ret appendFormat:@" %@ <b>%@</b> %@",[WClasses htmlStringForString:p.origType],[WClasses htmlStringForString:p.myclas.wType.wiType],p.myname];
            if (p.myqname) [ret appendFormat:@">>%@",p.myqname];
            if (p.ownerIsHim) {
                [ret appendString:[p.myclas html:tags andName:NO]];
            }
            [ret appendFormat:@"</li>\n"];
        }
    }
    [ret appendFormat:@"</ul></span>\n"];
    return(ret);
}




-(NSRegularExpression*)getterSetterRE {
    if (!self.vars.count) {
        getterSetterRE=nil;
    }
    else if (!getterSetterRE) {
        NSError *err=nil;
        NSMutableString *s=[NSMutableString string];
        for (NSString *k in self.vars) {
            WVar *v=(self.vars)[k];
            [s appendFormat:(s.length?@"|%@":@"%@"),[NSRegularExpression escapedPatternForString:v.localizedName]];
        }
        getterSetterRE=[NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"(?<![\\w\\d_\\.\\s]|->)\\s*(?:%@)(?:$|[^\\w\\d_])",s] options:0 error:&err];
        if (err) {
            NSLog(@"WInterface internal error %@",err.description);
            exit(1);
        }
    }
    return(getterSetterRE);
}

@end




