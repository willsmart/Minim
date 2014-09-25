@implementation WProp
@synthesize myclas,myname,hisclas,hisname,type,myqname,hisqname,origType;
- (void)dealloc {
    self.myname=self.hisname=self.type=nil;
    self.myclas=self.hisclas=nil;
    }
- (id)initWithType:(NSString*)atype origType:(NSString*)aorigType myClass:(WClass*)amyclas myName:(NSString*)amyname myQName:(NSString *)amyqname hisClass:(WClass*)ahisclas hisName:(NSString*)ahisname hisQName:(NSString *)ahisqname {
    if (!(self=[super init])) return(nil);
    dprnt("Prop : %s:%s\n",amyclas.name.UTF8String,amyname.UTF8String);
    [[WClasses getDefault].props addObject:self];
    self.myclas=amyclas;
    self.myname=amyname;
    self.myqname=amyqname;
    self.hisclas=ahisclas;
    self.hisname=ahisname;
    self.hisqname=ahisqname;
    self.origType=aorigType;
    self.type=atype;
    addedToFns=NO;
    return(self);
}
+ (WProp*)getPropWithMyClass:(WClass *)amyclass myName:(NSString *)amyname myQName:(NSString *)amyqname type:(NSString *)atype origType:(NSString*)aorigType hisClass:(WClass *)ahisclass hisName:(NSString *)ahisname hisQName:(NSString *)ahisqname {
    return([[WProp alloc] initWithType:atype origType:aorigType myClass:amyclass myName:amyname myQName:amyqname hisClass:ahisclass hisName:ahisname hisQName:ahisqname]);
}

- (char)myType {
    if (([type rangeOfString:@">a-"].location!=NSNotFound)||([type rangeOfString:@">A-"].location!=NSNotFound)) return('A');
    else if (([type rangeOfString:@">m-"].location!=NSNotFound)||([type rangeOfString:@">M-"].location!=NSNotFound)) return('D');
    else if (([type rangeOfString:@">-"].location!=NSNotFound)||([type rangeOfString:@">s-"].location!=NSNotFound)||([type rangeOfString:@">S-"].location!=NSNotFound)||([type rangeOfString:@">s<"].location!=NSNotFound)||([type rangeOfString:@">S<"].location!=NSNotFound)) return('S');
    else return('1');
}
- (char)hisType {
    if (([type rangeOfString:@"-a<"].location!=NSNotFound)||([type rangeOfString:@"-A<"].location!=NSNotFound)) return('A');
    else if (([type rangeOfString:@"-m<"].location!=NSNotFound)||([type rangeOfString:@"-M<"].location!=NSNotFound)) return('D');
    else if (([type rangeOfString:@"-<"].location!=NSNotFound)||([type rangeOfString:@"-s<"].location!=NSNotFound)||([type rangeOfString:@"-S<"].location!=NSNotFound)||([type rangeOfString:@">s<"].location!=NSNotFound)||([type rangeOfString:@">S<"].location!=NSNotFound)) return('S');
    else return('1');
}
- (bool)ownerIsMe {
    return([type hasPrefix:@"o"]||[type hasPrefix:@"O"]);
}
- (bool)ownerIsHim {
    return([type hasSuffix:@"o"]||[type hasSuffix:@"O"]);
}


-(WType*)myWType {
    return([WType newWithClass:(myclas.isProtocol?nil:myclas) protocols:(myclas.isProtocol?[NSArray arrayWithObject:myclas]:nil) addObject:NO]);
}
-(WType*)hisWType {
    return([WType newWithClass:(hisclas.isProtocol?nil:hisclas) protocols:(hisclas.isProtocol?[NSArray arrayWithObject:hisclas]:nil) addObject:NO]);
}


+ (NSString*)lowerName:(NSString*)s {
    if (!s) return(@"");
    if (s.length) {
        unichar c=[s characterAtIndex:0];
        if ((c>='A')&&(c<='Z')) s=[NSString stringWithFormat:@"%c%@",c+('a'-'A'),[s substringFromIndex:1]];
    }
    return(s);
}

+ (NSString*)upperName:(NSString*)s {
    if (!s) return(@"");
    if (s.length) {
        unichar c=[s characterAtIndex:0];
        if ((c>='a')&&(c<='z')) s=[NSString stringWithFormat:@"%c%@",c-('a'-'A'),[s substringFromIndex:1]];
    }
    return(s);
}

+ (NSString*)__lowerName:(NSString*)s {
    if (!s) return(@"");
    if (s.length) {
        NSUInteger i=0;for (;(i<s.length)&&([s characterAtIndex:i]=='_');i++);
        unichar c=[s characterAtIndex:i];
        if ((c>='A')&&(c<='Z')) s=[NSString stringWithFormat:@"%@%c%@",[s substringToIndex:i],c+('a'-'A'),[s substringFromIndex:i+1]];
    }
    return(s);
}

+ (NSString*)__upperName:(NSString*)s {
    if (!s) return(@"");
    if (s.length) {
        NSUInteger i=0;for (;(i<s.length)&&([s characterAtIndex:i]=='_');i++);
        unichar c=[s characterAtIndex:i];
        if ((c>='a')&&(c<='z')) s=[NSString stringWithFormat:@"%@%c%@",[s substringToIndex:i],c-('a'-'A'),[s substringFromIndex:i+1]];
    }
    return(s);
}

+ (NSString*)string:(NSString*)as replacePairs:(NSObject*)firstObject,... {
    NSMutableString *s=as.mutableCopy;
    va_list args;va_start(args,firstObject);
    for (NSObject *k=firstObject;k!=nil;k=va_arg(args,NSObject*)) {
        NSObject *o=va_arg(args,NSObject*);
        if (!o) break;
        if ([k isKindOfClass:[NSString class]]&&[o isKindOfClass:[NSString class]]) {
            [s replaceOccurrencesOfString:(NSString*)k withString:(NSString*)o options:0 range:NSMakeRange(0, s.length)];
        }
    }
    return(s.copy);
}


+ (NSString*)string:(NSString*)s withMyType:(WType*)mytype myName:(NSString*)myname iamOwner:(bool)iamOwner myQName:(NSString*)myqname hisType:(WType*)histype hisName:(NSString*)hisname heIsOwner:(bool)heIsOwner hisQName:(NSString*)hisqname qprop:(NSString*)qprop noPlurals:(bool)noPlurals {
    NSString *nshistype0=[histype objCTypeWithStars:0];
    NSString *nsmytype0=[mytype objCTypeWithStars:0];
    NSString *nshistype=[histype objCTypeWithStars:0];
    NSString *nsmytype=[mytype objCTypeWithStars:0];
    NSString *nshistype_noStar=[histype objCTypeWithStars:-1];
    NSString *nsmytype_noStar=[mytype objCTypeWithStars:-1];
    NSString *nsst=@"",*nsend=@"",*basest=@"",*baseend=@"";
    if (histype.clas.isType) {
        //NSString *ctype=nil;
        //for (NSString *s in histype.clas.varPatterns) {
        //    if ([s hasPrefix:@"ctype:"]) {
        //        ctype=[s substringFromIndex:@"ctype:".length];
        //    }
        //}
        NSString *ntype=nil;
        for (NSString *s in histype.clas.varPatterns) {
            if ([s hasPrefix:@"ntype:"]) {
                ntype=[s substringFromIndex:@"ntype:".length];
            }
        }
        if (ntype) {
            nshistype=@"NSNumber*";
            nshistype_noStar=@"NSNumber";
            nsst=[NSString stringWithFormat:@"[NSNumber numberWith%@:",[WProp upperName:ntype]];
            nsend=@"]";
            basest=@"";baseend=[NSString stringWithFormat:@".%@Value",[WProp lowerName:ntype]];
        }
    }
    s=[self string:s replacePairs:
        @"qprop",qprop,
        @"iretain",iamOwner?@"YES":@"NO",
        @" isHisClass]",histype.someWClass.isProtocol?@" conformsToProtocol:@protocol(JustHisClass)]":@" isKindOfClass:[JustHisClass class]]",
        @" isMyClass]",mytype.someWClass.isProtocol?@" conformsToProtocol:@protocol(JustMyClass)]":@" isKindOfClass:[JustMyClass class]]",
        @"[NSHisClass:",nsst,
        @":NSHisClass]",nsend,
        @"[BaseHisClass:",basest,
        @":BaseHisClass]",baseend,
        @"NSHisClass_noStar",nshistype_noStar,
        @"NSMyClass_noStar",nsmytype_noStar,
        @"NSHisClass",nshistype,
        @"NSMyClass",nsmytype,
        @"JustHisClass",histype.someWClass.name,
        @"JustMyClass",mytype.someWClass.name,
        @"justHisClass",[WProp lowerName:histype.someWClass.name],
        @"justMyClass",[WProp lowerName:mytype.someWClass.name],
        @"WIHisClass",histype.wiType,
        @"WIMyClass",mytype.wiType,
        @"BaseHisClass",nshistype0,
        @"BaseMyClass",nsmytype0,nil];
    if (!hisqname) s=[self string:s replacePairs:
        @"EndpointA_tracker",@"EndpointA",
        @"EndpointS_tracker",@"EndpointS",
        @"EndpointD_tracker",@"EndpointD",
        nil];
    if (noPlurals) s=[self string:s replacePairs:
        @"mynames",@"myname",
        @"Mynames",@"Myname",
        @"myqnames",@"myqname",
        @"Myqnames",@"Myqname",
        @"hisnames",@"hisname",
        @"Hisnames",@"Hisname",
        @"hisqnames",@"hisqname",
        @"Hisqnames",@"Hisqname",nil];
    s=[self string:s replacePairs:
        @"myname",[WProp lowerName:myname],
        @"Myname",[WProp upperName:myname],
        @"myqname",[WProp lowerName:myqname],
        @"Myqname",[WProp upperName:myqname],
        @"hisname",[WProp lowerName:hisname],
        @"Hisname",[WProp upperName:hisname],
        @"hisqname",[WProp lowerName:hisqname],
        @"Hisqname",[WProp upperName:hisqname],nil];
    return(s);
}


+ (NSString*)string:(NSString*)s withMyClass:(WClass*)myclass {
    s=[s stringByReplacingOccurrencesOfString:@"WIMyClass" withString:(myclass.isProtocol?@"<MyClass>":@"MyClass")];
    s=[s stringByReplacingOccurrencesOfString:@"NSMyClass" withString:[WType objCTypeWithClass:myclass protocols:nil stars:0]];
    return([s stringByReplacingOccurrencesOfString:@"MyClass" withString:myclass.name]);
}




- (void)add:(WReader*)r {
    if (!((myclas||(self.myclas=[[WClasses getDefault] classForName:self.myname]))&&
          (hisclas||(self.hisclas=[[WClasses getDefault] classForName:self.hisname])))) {
        [WClasses error:[NSString stringWithFormat:@"Unknown class for property %@ %@ : %@ %@",myclas.name,self.myname,hisclas.name,self.hisname] withToken:nil context:self];
    }
    else {
//        if ([hisname isEqualToString:@"base"]) {
//            [WClasses note:[NSString stringWithFormat:@"%c%c my: %@ %@ %@ his: %@ %@ %@",self.myType,self.hisType,myclas.name,myname,myqname,hisclas.name,hisname,hisqname] withReader:r];
//        }
        WReader *r2=[[WReader alloc] init];
        r2.tokenizer.tokenDelegate=[WClasses getDefault];
        r2.fileString=[WProp string:[[WClasses getDefault].propFiles objectForKey:[NSString stringWithFormat:@"%c%c",self.myType,self.hisType]] withMyType:self.myWType myName:self.myname iamOwner:self.ownerIsMe myQName:self.myqname hisType:self.hisWType hisName:self.hisname heIsOwner:self.ownerIsHim hisQName:self.hisqname qprop:[NSString stringWithFormat:@"myname %@ WIHisClass hisname",self.type] noPlurals:NO];
        r2._fileName=[NSString stringWithFormat:@"%@:(%@ :: %@)",r.fileName,[self.myclas.wType wiType],self.hisname];
        [[WClasses getDefault] read:r2 logContext:self];
        r2=[[WReader alloc] init];
        r2.tokenizer.tokenDelegate=[WClasses getDefault];
        r2.fileString=[WProp string:[[WClasses getDefault].propFiles objectForKey:[NSString stringWithFormat:@"%c%c",self.hisType,self.myType]] withMyType:self.hisWType myName:self.hisname iamOwner:self.ownerIsHim myQName:self.hisqname hisType:self.myWType hisName:self.myname heIsOwner:self.ownerIsMe hisQName:self.myqname qprop:@"" noPlurals:NO];
        r2._fileName=[NSString stringWithFormat:@"%@:(%@ :: %@)",r.fileName,[self.hisclas.wType wiType],self.myname];
//        [WClasses note:r2.fileString withReader:r];
        [[WClasses getDefault] read:r2 logContext:self];
        if (hisqname) {
            r2=[[WReader alloc] init];
            r2.tokenizer.tokenDelegate=[WClasses getDefault];
            r2.fileString=[WProp string:[[WClasses getDefault].propFiles objectForKey:[NSString stringWithFormat:(hisclas.isType?@"T%c":@"NS%c"),self.hisType]] withMyType:self.myWType myName:self.myname iamOwner:self.ownerIsMe myQName:self.myqname hisType:self.hisWType hisName:self.hisname heIsOwner:self.ownerIsHim hisQName:self.hisqname qprop:@"" noPlurals:NO];
            r2._fileName=[NSString stringWithFormat:@"%@:(%@ >> %@)",r.fileName,[self.myclas.wType wiType],self.hisqname];
            [[WClasses getDefault] read:r2 logContext:self];
        }
        if (myqname) {
            r2=[[WReader alloc] init];
            r2.tokenizer.tokenDelegate=[WClasses getDefault];
            NSString *key=((self.hisType=='A')&&(self.myType=='1')?@"NS1A":
                ((self.hisType=='D')&&(self.myType=='1')?@"NS1D":
                [NSString stringWithFormat:(myclas.isType?@"T%c":@"NS%c"),self.myType]));
            r2.fileString=[WProp string:[[WClasses getDefault].propFiles objectForKey:key] withMyType:self.hisWType myName:self.hisname iamOwner:self.ownerIsHim myQName:self.hisqname hisType:self.myWType hisName:self.myname heIsOwner:self.ownerIsMe hisQName:self.myqname qprop:@"" noPlurals:NO];
            r2._fileName=[NSString stringWithFormat:@"%@:(%@ >> %@)",r.fileName,[self.hisclas.wType wiType],self.myqname];
            [[WClasses getDefault] read:r2 logContext:self];
        }
    }
}

+ (void)stadd:(WClass*)clas {
    if (clas.isSys) return;
    
    WReader *r2=[[WReader alloc] init];
    r2.tokenizer.tokenDelegate=[WClasses getDefault];

    r2.fileString=[WProp string:[[WClasses getDefault].propFiles objectForKey:@"Base"] withMyClass:clas];
    r2._fileName=[NSString stringWithFormat:@"%@:PropBase",[clas.wType wiType]];
    [[WClasses getDefault] read:r2 logContext:nil];
}




@end
