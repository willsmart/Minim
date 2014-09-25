

#define drprnt(...) do{if ([r.fileName hasPrefix:@"hint"]) BPNOW;dprnt("[%s:%s:%d] ",WClasses.getDefault.readFNStack.description.UTF8String,r.fileName.UTF8String,r.currentToken.linei);dprnt(__VA_ARGS__);}while(0)


#define SPACER @"\n\n\n\n\n\n\n\n\n"


@implementation WClasses
@synthesize classes,protocols,skipNewLines;
@synthesize classContext,logContext,classContextBracket,classContextLinei,propertyContexts,settingsContext,propertyContextBrackets,propertyContextLineis,props,propFiles,taskList,readFNStack,includes,taskFn;
@synthesize ins_first_decl,ins_after_decl_decl,ins_after_structs_decl,ins_after_protocols_decl,ins_after_ifaces_decl,ins_last_decl,incls,ins_after_imports_decl;
@synthesize ins_first_iface,ins_after_decl_iface,ins_after_structs_iface,ins_after_protocols_iface,ins_after_ifaces_iface,ins_last_iface,ins_after_imports_iface;
@synthesize ins_first_impl,ins_after_decl_impl,ins_after_structs_impl,ins_after_protocols_impl,ins_after_ifaces_impl,ins_last_impl,ins_after_imports_impl,hasErrors,hasWarnings,finishedParse;
@synthesize ins_set_first_decl,ins_set_after_decl_decl,ins_set_after_structs_decl,ins_set_after_protocols_decl,ins_set_after_ifaces_decl,ins_set_last_decl,ins_set_after_imports_decl;
@synthesize ins_set_first_iface,ins_set_after_decl_iface,ins_set_after_structs_iface,ins_set_after_protocols_iface,ins_set_after_ifaces_iface,ins_set_last_iface,ins_set_after_imports_iface;
@synthesize ins_set_first_impl,ins_set_after_decl_impl,ins_set_after_structs_impl,ins_set_after_protocols_impl,ins_set_after_ifaces_impl,ins_set_last_impl,ins_set_after_imports_impl;
@synthesize ins_each_impl,ins_set_each_impl;

- (void)dealloc {
    self.classes=self.protocols=nil;
    self.classContext=nil;
    self.logContext=nil;
    self.propertyContexts=nil;
    self.settingsContext=nil;
    self.propertyContextBrackets=nil;
    self.propertyContextLineis=nil;
    self.props=nil;
    self.propFiles=nil;
    self.includes=nil;
    self.readFNStack=nil;
    self.taskList=nil;
    self.taskFn=nil;
    self.incls=nil;
    self.ins_first_decl=self.ins_after_decl_decl=self.ins_after_structs_decl=self.ins_after_protocols_decl=self.ins_after_ifaces_decl=self.ins_last_decl=self.ins_after_imports_decl=nil;
    self.ins_first_iface=self.ins_after_decl_iface=self.ins_after_structs_iface=self.ins_after_protocols_iface=self.ins_after_ifaces_iface=self.ins_last_iface=self.ins_after_imports_iface=nil;
    self.ins_first_impl=self.ins_after_decl_impl=self.ins_after_structs_impl=self.ins_after_protocols_impl=self.ins_after_ifaces_impl=self.ins_last_impl=self.ins_after_imports_impl=nil;
    self.ins_set_first_decl=self.ins_set_after_decl_decl=self.ins_set_after_structs_decl=self.ins_set_after_protocols_decl=self.ins_set_after_ifaces_decl=self.ins_set_last_decl=self.ins_set_after_imports_decl=nil;
    self.ins_set_first_iface=self.ins_set_after_decl_iface=self.ins_set_after_structs_iface=self.ins_set_after_protocols_iface=self.ins_set_after_ifaces_iface=self.ins_set_last_iface=self.ins_set_after_imports_iface=nil;
    self.ins_set_first_impl=self.ins_set_after_decl_impl=self.ins_set_after_structs_impl=self.ins_set_after_protocols_impl=self.ins_set_after_ifaces_impl=self.ins_set_last_impl=self.ins_set_after_imports_impl=nil;
    self.ins_set_each_impl=nil;
    self.ins_each_impl=nil;
    }

- (id)init {
    if (!(self=[super init])) return(nil);
    self.classes=[NSMutableDictionary dictionary];
    self.protocols=[NSMutableDictionary dictionary];
    self.props=[NSMutableArray array];
    self.propertyContexts=[NSMutableArray array];
    self.settingsContext=NSMutableDictionary.dictionary;
    self.propertyContextBrackets=[NSMutableIndexSet indexSet];
    self.propertyContextLineis=[NSMutableArray array];
    self.taskList=[NSMutableArray array];
    self.classContext=nil;
    self.includes=[NSMutableArray array];
    self.readFNStack=[NSMutableSet set];
    self.classContextLinei=-1;
    self.classContextBracket=0;
    self.propFiles=[NSMutableDictionary dictionary];
    self.ins_first_decl=[NSMutableString string];
    self.ins_after_imports_decl=[NSMutableString string];
    self.ins_after_decl_decl=[NSMutableString string];
    self.ins_after_structs_decl=[NSMutableString string];
    self.ins_after_protocols_decl=[NSMutableString string];
    self.ins_after_ifaces_decl=[NSMutableString string];
    self.ins_last_decl=[NSMutableString string];
    self.ins_first_iface=[NSMutableString string];
    self.ins_after_imports_iface=[NSMutableString string];
    self.ins_after_decl_iface=[NSMutableString string];
    self.ins_after_structs_iface=[NSMutableString string];
    self.ins_after_protocols_iface=[NSMutableString string];
    self.ins_after_ifaces_iface=[NSMutableString string];
    self.ins_last_iface=[NSMutableString string];
    self.ins_first_impl=[NSMutableString string];
    self.ins_after_imports_impl=[NSMutableString string];
    self.ins_after_decl_impl=[NSMutableString string];
    self.ins_after_structs_impl=[NSMutableString string];
    self.ins_after_protocols_impl=[NSMutableString string];
    self.ins_after_ifaces_impl=[NSMutableString string];
    self.ins_last_impl=[NSMutableString string];
    self.ins_each_impl=[NSMutableString string];
    self.ins_set_first_decl=[NSMutableSet set];
    self.ins_set_after_imports_decl=[NSMutableSet set];
    self.ins_set_after_decl_decl=[NSMutableSet set];
    self.ins_set_after_structs_decl=[NSMutableSet set];
    self.ins_set_after_protocols_decl=[NSMutableSet set];
    self.ins_set_after_ifaces_decl=[NSMutableSet set];
    self.ins_set_last_decl=[NSMutableSet set];
    self.ins_set_first_iface=[NSMutableSet set];
    self.ins_set_after_imports_iface=[NSMutableSet set];
    self.ins_set_after_decl_iface=[NSMutableSet set];
    self.ins_set_after_structs_iface=[NSMutableSet set];
    self.ins_set_after_protocols_iface=[NSMutableSet set];
    self.ins_set_after_ifaces_iface=[NSMutableSet set];
    self.ins_set_last_iface=[NSMutableSet set];
    self.ins_set_first_impl=[NSMutableSet set];
    self.ins_set_after_imports_impl=[NSMutableSet set];
    self.ins_set_after_decl_impl=[NSMutableSet set];
    self.ins_set_after_structs_impl=[NSMutableSet set];
    self.ins_set_after_protocols_impl=[NSMutableSet set];
    self.ins_set_after_ifaces_impl=[NSMutableSet set];
    self.ins_set_last_impl=[NSMutableSet set];
    self.ins_set_each_impl=[NSMutableSet set];
    self.incls=[NSMutableArray array];
    return(self);
}

static WClasses *_default=nil;
+ (WClasses*)getDefault {
    if (!_default) {
        NSArray *a=@[@"Base",
            @"11",@"S1",@"A1",@"D1",@"1S",@"1A",@"1D",@"SS"];
        NSMutableDictionary *d=[NSMutableDictionary dictionary];
        for (NSString *s in a) {
            WReader *r=[[WReader alloc] init];
            NSString *fn=[NSString stringWithFormat:@"/Users/Will/Documents/WInterface/WInterface/Wis/Prop%@.wi",s];
            [InFiles clearMarksFromFiles:@[fn]];
            r.fileName=fn;
            d[s] = r.fileString;
        }
        a=@[@"T1",
            @"NSM",@"NS1M,NS1",@"NS1",@"NSA",@"NS1A,NS1",@"NSS"];
        for (NSString *s in a) {
            WReader *r=[[WReader alloc] init];
            if ([s rangeOfString:@","].location!=NSNotFound) {
                NSArray *ss=[s componentsSeparatedByString:@","];
                NSMutableString *agg=[NSMutableString string];
                for (NSString *s2 in ss) {
                    NSString *fn=[NSString stringWithFormat:@"/Users/Will/Documents/WInterface/WInterface/Wis/Model%@.wi",s2];
                    [InFiles clearMarksFromFiles:@[fn]];
                    r.fileName=fn;
                    [agg appendFormat:@"%@\n",r.fileString];
                }
                d[ss[0]] = agg;
            }
            else {
                NSString *fn=[NSString stringWithFormat:@"/Users/Will/Documents/WInterface/WInterface/Wis/Model%@.wi",s];
                [InFiles clearMarksFromFiles:@[fn]];
                r.fileName=fn;
                d[s] = r.fileString;
            }
        }
        _default=[[WClasses alloc] init];
        _default.propFiles=d;
    }
    return(_default);
}

+ (void)clearStaticData {
    _default=nil;
}

-(NSSet*)filenames {
    NSMutableSet *ret=[NSMutableSet setWithObjects:@"default",@"inserts", nil];
    for (NSString *name in self.classes) [ret addObject:((WClass*)(self.classes)[name]).filename];
    return(ret);
}

+ (NSString*)htmlStringForString:(NSString*)str {
    return([WProp string:str replacePairs:@"&",@"&amp;",@"<",@"&lt;",@">",@"&gt;",@"\"",@"&quot;",nil]);
}
+ (NSString*)jsStringForString:(NSString*)str {
    return([WProp string:str replacePairs:@"\\",@"\\\\",@"\"",@"\\\"",@"\n",@"\\n",@"\r",@"",nil]);
}

-(NSString*)html {
    for (NSString *cname in self.classes) {
        WClass *c=(self.classes)[cname];
        c.ownedNum=c.ownsNum=0;
    }
    for (NSString *pname in self.protocols) {
        WClass *p=(self.protocols)[pname];
        p.ownedNum=p.ownsNum=0;
    }
    for (NSString *cname in self.classes) {
        WClass *c=(self.classes)[cname];
        [c addOwnership];
    }
    for (NSString *pname in self.protocols) {
        WClass *p=(self.protocols)[pname];
        [p addOwnership];
    }
    NSMutableDictionary *varDict=[NSMutableDictionary dictionary];
    for (NSString *cname in self.classes) {
        WClass *c=(self.classes)[cname];
        [c addjsvars:varDict];
    }
    for (NSString *pname in self.protocols) {
        WClass *p=(self.protocols)[pname];
        [p addjsvars:varDict];
    }
    
    NSMutableString *ret=[NSMutableString stringWithFormat:@"<!DOCTYPE html><meta charset=\"utf-8\"><title>WI</title><script>var classVars={"];
    for (NSString *type in varDict) [ret appendFormat:@"\"%@\":\"%@\",\n",[WClasses jsStringForString:type],[WClasses jsStringForString:varDict[type]]];
    
    [ret appendFormat:@"'':''};"
    "function classclick(path,clas,type) {"
    "console.log('path: '+path+' clas:'+clas+' type:'+type);"
    "console.log('v:'+(clas+'_'+type)+' = '+classVars[clas+'_'+type]);"
    "var spn = document.getElementById(path);"
    "if (spn.expanded) {spn.innerHTML='';spn.expanded=false;}"
    "else {spn.innerHTML=classVars[clas+'_'+type].replace(/PATH/g,path+'--'+clas+':'+type);spn.expanded=true;}"
    "}"
    "</script>"];
    
    
    
    NSMutableArray *cnames=[NSMutableArray array];
    NSMutableArray *pnames=[NSMutableArray array];
    for (NSString *cname in self.classes) {
        [cnames addObject:cname];
    }
    for (NSString *pname in self.protocols) {
        [pnames addObject:pname];
    }
    [cnames sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *n1=(NSString*)obj1,*n2=(NSString*)obj2;
        return([n1 compare:n2 options:NSCaseInsensitiveSearch]);
    }];
    [pnames sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *n1=(NSString*)obj1,*n2=(NSString*)obj2;
        return([n1 compare:n2 options:NSCaseInsensitiveSearch]);
    }];
    

    [ret appendFormat:@"<h1>Classes</h1><ul>"];
    //<h1>Protocols</h1>%@<h1>Types and sys</h1>%@</body></html>\n",retclass,retprotocol,rettype];
    
    for (NSString *n in cnames) {
        WClass *c=(self.classes)[n];
        if (!(c.isType||c.isSys)) {
            NSString *s=varDict[[c.tag stringByAppendingString:@"_."]];
            [ret appendFormat:@"<li>%@</li>\n",[s stringByReplacingOccurrencesOfString:@"PATH" withString:c.tag]];
        }
    }

    [ret appendFormat:@"</ul><h1>Protocols</h1><ul>\n"];
    //<h1>Protocols</h1>%@<h1>Types and sys</h1>%@</body></html>\n",retclass,retprotocol,rettype];
    
    for (NSString *n in pnames) {
        WClass *p=(self.protocols)[n];
        if (!(p.isType||p.isSys)) {
            NSString *s=varDict[[p.tag stringByAppendingString:@"_."]];
            [ret appendFormat:@"<li>%@</li>\n",[s stringByReplacingOccurrencesOfString:@"PATH" withString:p.tag]];
        }
    }
    

    [ret appendFormat:@"</ul><h1>Types and sys</h1><ul>\n"];
    //<h1>Protocols</h1>%@<h1>Types and sys</h1>%@</body></html>\n",retclass,retprotocol,rettype];
    
    for (NSString *n in cnames) {
        WClass *c=(self.classes)[n];
        if (c.isType||c.isSys) {
            NSString *s=varDict[[c.tag stringByAppendingString:@"_."]];
            [ret appendFormat:@"<li>%@</li>\n",[s stringByReplacingOccurrencesOfString:@"PATH" withString:c.tag]];
        }
    }
    [ret appendFormat:@"</ul>\n"];
    
    /*
    NSMutableString *retprotocol=[NSMutableString string];
    NSMutableString *retclass=[NSMutableString string];
    NSMutableString *rettype=[NSMutableString string];
    
    NSMutableDictionary *tags=[NSMutableDictionary dictionary];
    for (Int oi=0;tags.count!=self.classes.count+self.protocols.count;oi++) {
        dprnt("%ld %ld\n",tags.count,self.classes.count+self.protocols.count);
    
        NSMutableArray *notOwnedc=[NSMutableArray array];
        NSMutableArray *notOwnedp=[NSMutableArray array];
        for (NSString *cname in self.classes) {
            WClass *c=[self.classes objectForKey:cname];
            if (c.ownedNum==oi) {
                [notOwnedc addObject:cname];
            }
        }
        for (NSString *pname in self.protocols) {
            WClass *p=[self.protocols objectForKey:pname];
            if (p.ownedNum==oi) {
                [notOwnedp addObject:pname];
            }
        }
        [notOwnedp sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *n1=(NSString*)obj1,*n2=(NSString*)obj2;
            return([n1 compare:n2 options:NSCaseInsensitiveSearch]);
        }];
        [notOwnedc sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *n1=(NSString*)obj1,*n2=(NSString*)obj2;
            return([n1 compare:n2 options:NSCaseInsensitiveSearch]);
        }];
        for (NSString *cname in notOwnedc) {
            WClass *c=[self.classes objectForKey:cname];
            NSString *s=[c html:tags andName:YES];
            [(c.isSys||c.isType?rettype:retclass) appendString:s];
        }
        for (NSString *pname in notOwnedp) {
            WClass *p=[self.protocols objectForKey:pname];
            NSString *s=[p html:tags andName:YES];
            [(p.isSys||p.isType?rettype:retprotocol) appendString:s];
        }
    }
    NSMutableString *ret=[NSMutableString stringWithFormat:@"</body></html><h1>Classes</h1>%@<h1>Protocols</h1>%@<h1>Types and sys</h1>%@</body></html>\n",retclass,retprotocol,rettype];
    */
    return(ret);
}

- (void)clear {
    [self.classes removeAllObjects];
    [self.protocols removeAllObjects];
    [self.propertyContexts removeAllObjects];
    [self.settingsContext removeAllObjects];
    [self.props removeAllObjects];
    [self.propertyContextBrackets removeAllIndexes];
    [self.propertyContextLineis removeAllObjects];
    [self.taskList removeAllObjects];
    self.classContext=nil;
    [self.includes removeAllObjects];
    [self.readFNStack removeAllObjects];
    classContextLinei=0;
    classContextBracket=0;
    skipNewLines=YES;
    hasErrors=hasWarnings=finishedParse=NO;
}

// Word[:Word][(word word)]
// (-|+)(word).* {...}
// (-|+)(word).*;
// [Word]word [--|-a<|-s<|>a-|>s-] [Word]word
// word word[=["..."|word|num]][(word,?word)]

- (WReaderToken*)skipSpaces:(WReader*)r {
    while (true) {
        WReaderToken *t=r.currentToken;
        if ((!t)||!((skipNewLines&&(t.type=='r'))||(t.type=='z')||(t.type=='c'))) return(t);
        r.pos++;
    }
}

- (WReaderToken*)skipSpacesAndSemicolons:(WReader*)r {
    while (true) {
        WReaderToken *t=r.currentToken;
        if ((!t)||!((skipNewLines&&(t.type=='r'))||(t.type=='z')||(t.type=='c')||((t.type=='o')&&[t.str isEqualToString:@";"]))) return(t);
        r.pos++;
    }
}

- (WReaderToken*)skipSpacesOnOneLine:(WReader*)r {
    while (true) {
        WReaderToken *t=r.currentToken;
        if ((!t)||!((t.type=='z')||(t.type=='c'))) return(t);
        r.pos++;
    }
}

- (WReaderToken*)skipSpacesAndSemicolonsOnOneLine:(WReader*)r {
    while (true) {
        WReaderToken *t=r.currentToken;
        if ((!t)||!((t.type=='z')||(t.type=='c')||((t.type=='o')&&[t.str isEqualToString:@";"]))) return(t);
        r.pos++;
    }
}

- (Int)read:(WReader*)r options:(SEL*)options numOptions:(Int)N retObject:(NSObject*__strong*)po {
    Int pos=r.pos;
    for (Int i=0;i<N;i++) {
        NSObject *o=[self performUnknownSelector:options[i] withObject:r];
        if (o) {
            (*po)=o;
            return(i);
        }
        else r.pos=pos;
    }
    return(NSNotFound);
}

-(NSString*)processedStringForString:(NSString*)s inToken:(WReaderToken*)token {
    if (token.type=='w') return([WClasses processClassString:s reader:token.tokenizer.reader]);
    else return(s);
}

- (NSString*)readString:(WReader*)r {
    WReaderToken *t=[self skipSpaces:r];
    if (t&&(t.type=='s')) {
        r.pos++;
        return(t.str);
    }
    else return(nil);
}
- (NSString*)readNumber:(WReader*)r {
    WReaderToken *t=[self skipSpaces:r];
    if (t&&(t.type=='n')) {
        r.pos++;
        return(t.str);
    }
    else return(nil);
}
- (NSString*)readWord:(WReader*)r {
    WReaderToken *t=[self skipSpaces:r];
    if (t&&(t.type=='w')) {
        r.pos++;
        return(t.str);
    }
    else return(nil);
}
- (unichar)readWordc:(WReader*)r {
    WReaderToken *t=[self skipSpaces:r];
    if (t&&(t.type=='w')&&(t.str.length==1)) {
        r.pos++;
        return([t.str characterAtIndex:0]);
    }
    else return(0);
}
- (bool)readc:(WReader*)r anyof:(NSString*)s {
    WReaderToken *t=[self skipSpaces:r];
    if (t&&(t.str.length==1)&&([s rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:t.str]].location!=NSNotFound)) {
        r.pos++;
        return(YES);
    }
    else return(NO);
}
- (NSString*)readOp:(WReader*)r {
    WReaderToken *t=[self skipSpaces:r];
    if (t&&(t.type=='o')) {
        r.pos++;
        return(t.str);
    }
    else return(nil);
}
- (unichar)readOpc:(WReader*)r {
    WReaderToken *t=[self skipSpaces:r];
    if (t&&(t.type=='o')) {
        r.pos++;
        return([t.str characterAtIndex:0]);
    }
    else return(0);
}
- (unichar)readOpOrWordc:(WReader*)r {
    unichar c=[self readOpc:r];
    if (!c) c=[self readWordc:r];
    return(c);
}

- (NSString*)readStringOnOneLine:(WReader*)r {
    WReaderToken *t=[self skipSpacesOnOneLine:r];
    if (t&&(t.type=='s')) {
        r.pos++;
        return(t.str);
    }
    else return(nil);
}
- (NSString*)readNumberOnOneLine:(WReader*)r {
    WReaderToken *t=[self skipSpacesOnOneLine:r];
    if (t&&(t.type=='n')) {
        r.pos++;
        return(t.str);
    }
    else return(nil);
}
- (NSString*)readWordOnOneLine:(WReader*)r {
    WReaderToken *t=[self skipSpacesOnOneLine:r];
    if (t&&(t.type=='w')) {
        r.pos++;
        return(t.str);
    }
    else return(nil);
}
- (unichar)readWordcOnOneLine:(WReader*)r {
    WReaderToken *t=[self skipSpacesOnOneLine:r];
    if (t&&(t.type=='w')&&(t.str.length==1)) {
        r.pos++;
        return([t.str characterAtIndex:0]);
    }
    else return(0);
}
- (bool)readcOnOneLine:(WReader*)r anyof:(NSString*)s {
    WReaderToken *t=[self skipSpacesOnOneLine:r];
    if (t&&(t.str.length==1)&&([s rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:t.str]].location!=NSNotFound)) {
        r.pos++;
        return(YES);
    }
    else return(NO);
}
- (NSString*)readOpOnOneLine:(WReader*)r {
    WReaderToken *t=[self skipSpacesOnOneLine:r];
    if (t&&(t.type=='o')) {
        r.pos++;
        return(t.str);
    }
    else return(nil);
}
- (unichar)readOpcOnOneLine:(WReader*)r {
    WReaderToken *t=[self skipSpacesOnOneLine:r];
    if (t&&(t.type=='o')) {
        r.pos++;
        return([t.str characterAtIndex:0]);
    }
    else return(0);
}
- (unichar)readOpOrWordcOnOneLine:(WReader*)r {
    unichar c=[self readOpcOnOneLine:r];
    if (!c) c=[self readWordcOnOneLine:r];
    return(c);
}

- (NSString*)readPropType:(WReader*)r {
    Int pos=r.pos;
    switch ([self readOpc:r]) {
        case '-':{
            switch ([self readOpOrWordc:r]) {
                case '-':return(@"--");break;
                case '~':return(@"--o");break;
                case 'a':case 'A':{
                    switch ([self readOpc:r]) {
                        case '{':return(@"-a<o");
                        case '<':
                            if ([r.currentToken.str isEqualToString:@"~"]) {
                                r.pos++;
                                return(@"-a<o");
                            }
                            return(@"-a<");
                        case '~':{
                            switch ([self readOpc:r]) {
                                case '<':return(@"-a<o");
                            }
                        }
                    }
                }break;
                case 's':case 'S':{
                    switch ([self readOpc:r]) {
                        case '{':return(@"-s<o");
                        case '<':
                            if ([r.currentToken.str isEqualToString:@"~"]) {
                                r.pos++;
                                return(@"-s<o");
                            }
                            return(@"-s<");
                        case '~':{
                            switch ([self readOpc:r]) {
                                case '<':return(@"-s<o");
                            }
                        }
                    }
                }break;
                case 'm':case 'M':case 'd':case 'D':{
                    switch ([self readOpc:r]) {
                        case '{':return(@"-m<o");
                        case '<':
                            if ([r.currentToken.str isEqualToString:@"~"]) {
                                r.pos++;
                                return(@"-m<o");
                            }
                            return(@"-m<");
                        case '~':{
                            switch ([self readOpc:r]) {
                                case '<':return(@"-m<o");
                            }
                        }
                    }
                }break;
            }            
        }break;
        case '~':{
            switch ([self readOpOrWordc:r]) {
                case '-':return(@"o--");break;
                case 'a':case 'A':{
                    switch ([self readOpc:r]) {
                        case '<':return(@"o-a<");
                    }
                }break;
                case 's':case 'S':{
                    switch ([self readOpc:r]) {
                        case '<':return(@"o-s<");
                    }
                }break;
                case 'm':case 'M':case 'd':case 'D':{
                    switch ([self readOpc:r]) {
                        case '<':return(@"o-m<");
                    }
                }break;
            }            
        }break;
        case '>':{
            switch ([self readOpOrWordc:r]) {
                case '~':{
                    switch ([self readWordc:r]) {
                        case 'a':case 'A':{
                            switch ([self readOpc:r]) {
                                case '-':return(@"o>a-");
                            }
                        }break;
                        case 's':case 'S':{
                            switch ([self readOpc:r]) {
                                case '-':return(@"o>s-");
                                case '<':return(@"o>s<");
                            }
                        }break;
                        case 'm':case 'M':case 'd':case 'D':{
                            switch ([self readOpc:r]) {
                                case '-':return(@"o>m-");
                            }
                        }break;
                    }
                }   
                case 'a':case 'A':{
                    switch ([self readOpc:r]) {
                        case '-':return(@">a-");
                        case '~':return(@">a-o");
                    }
                }break;
                case 's':case 'S':{
                    switch ([self readOpc:r]) {
                        case '-':return(@">s-");
                        case '{':return(@">s<o");
                        case '<':{
                            if ([r.currentToken.str isEqualToString:@"~"]) {
                                r.pos++;
                                return(@">s<o");
                            }
                            else return(@">s<");
                        }
                        case '~':return(@">s-o");
                    }
                }break;
                case 'm':case 'M':case 'd':case 'D':{
                    switch ([self readOpc:r]) {
                        case '-':return(@">m-");
                        case '~':return(@">m-o");
                    }
                }break;
            }   
        }break;
    }
    r.pos=pos;
    return(nil);
}

- (WProp*)enclosingPropNoSkip:(WReader*)r {
    Int pi,bc;
    for (pi=(Int)self.propertyContextBrackets.count-1,bc=(Int)self.propertyContextBrackets.lastIndex;(bc!=NSNotFound)&&(bc>=r.currentToken.bracketCount);bc=(Int)[self.propertyContextBrackets indexLessThanIndex:bc],pi--);
    
    if (pi>=0) return((WProp*)(self.propertyContexts)[pi]);
    else return(nil);
}
- (WClass*)enclosingClassNoSkip:(WReader*)r {
    WClass *c=nil;
    WProp *p=[self enclosingPropNoSkip:r];
    if (p) c=p.hisclas;
    else if (self.classContext) {
        if ((r.currentToken.bracketCount>self.classContextBracket)||(r.currentToken.linei==self.classContextLinei)) c=self.classContext;
    }
    return(c);
}
- (WProp*)enclosingProp:(WReader*)r {
    WReaderToken *t=[self skipSpaces:r];
    if (!t) return(nil);
    return([self enclosingPropNoSkip:r]);
}
- (WClass*)enclosingClass:(WReader*)r {
    WReaderToken *t=[self skipSpaces:r];
    if (!t) return(nil);
    return([self enclosingClassNoSkip:r]);
}
- (NSString*)readBlock:(WReader*)r retPrefix:(NSString*__strong*)pprefix linei:(Int)pli bracketCount:(Int)pbc clearBrackets:(bool)clearBrackets {
    Int pos=r.pos;
    Int bc=0;

    NSMutableString *sameLine=[NSMutableString new];
    NSMutableString *preBracket=[NSMutableString new];
    NSMutableString *mid=[NSMutableString new];
    NSMutableString *postBracket=[NSMutableString new];

    bool hadBracket=NO,hadMid=NO,hadTwo=NO,useBracket=YES;
    WReaderToken *t;
    for (t=r.currentToken;t;r.pos++,t=r.currentToken) {
        if ([t.str isEqualToString:@"{"]) {
            if (!bc++) {
                if (hadMid) {hadBracket=NO;hadTwo=YES;}
                else hadBracket=YES;
            }
        }

        if (hadMid) {
            if ((!bc)&&(t.linei>pli)&&(t.bracketCount<=pbc)) break;
            [postBracket appendString:t.str];
            if ((t.type!='z')&&(t.type!='c')&&(t.type!='r')) hadTwo=YES;
        }
        else if (hadBracket) [mid appendString:t.str];
        else if (!bc) {
            if (t.linei==pli) {
                if ((t.type!='z')&&(t.type!='c')&&(t.type!='r')&&!pprefix) {t=nil;break;}
                if ([t.str isEqualToString:@";"]) {
                    r.pos++;
                    break;
                }
                else if (t.type=='r') {
                    [sameLine appendString:[t.str substringToIndex:1]];
                    [preBracket appendString:[t.str substringFromIndex:1]];
                }
                else [sameLine appendString:t.str];
            }
            else if (t.bracketCount>pbc) {
                useBracket=NO;
                [preBracket appendString:t.str];
                if ((t.type!='z')&&(t.type!='c')&&(t.type!='r')&&!pprefix) {t=nil;break;}
            }
            else break;
        }

        if ([t.str isEqualToString:@"}"]) {
            if (!--bc) {
                hadMid=YES;
                if (t.bracketCount>pbc) {hadBracket=NO;hadTwo=YES;}
                if (useBracket||(t.linei==pli)||(t.bracketCount<=pbc)) {
                    r.pos++;
                    break;
                }
            }
        }
    }

    NSString *ret=nil;
    if (!t) {
        r.pos=pos;
    }
    else if (hadTwo) {
        if (pprefix) *pprefix=sameLine;
        ret=[preBracket stringByAppendingFormat:@"%@%@\n",mid,postBracket];
    }
    else if (hadMid) {
        if (pprefix) *pprefix=[sameLine stringByAppendingString:preBracket];
        ret=mid;
    }
    else {
        if (pprefix) *pprefix=sameLine;
        ret=[preBracket stringByAppendingString:[mid stringByAppendingString:@"\n"]];
    }
    if (ret&&clearBrackets) {
        NSString *trimRet=[ret stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([trimRet hasPrefix:@"{"]&&[trimRet hasSuffix:@"}"]) {
            ret=[trimRet substringWithRange:NSMakeRange(1, trimRet.length-2)];
        }
    }
    return(ret);
}

- (NSString*)readIndentBlock:(WReader*)r  {
    Int pos=r.pos;
    if (![self readc:r anyof:@"{"]) {r.pos=pos;return(nil);}
    Int bc=1;
    NSMutableString *ret=[NSMutableString string];
    WReaderToken *t;
    for (t=r.currentToken;t;r.pos++,t=r.currentToken) {
        if ([t.str isEqualToString:@"{"]) bc++;
        else if ([t.str isEqualToString:@"}"]) {
            if (!--bc) break;
        }
        [ret appendString:t.str];
    }
    if (!t) {r.pos=pos;return(nil);}
    r.pos++;
    return(ret);
}

- (NSString*)readVarAttribute:(WReader*)r {
    Int pos=r.pos;
    NSString *ret=[self readWord:r],*w;
    if ((!ret)&&[self readc:r anyof:@"-+"]) {
        r.pos=pos;
        NSMutableString *s=[NSMutableString string];
        for (WReaderToken *t=r.currentToken;t&&![t.str isEqualToString:@";"];r.pos++,t=r.currentToken) {
            [s appendString:t.str];
        }
        if (r.currentToken) r.pos++;
        ret=s.copy;
    }
    else if (([ret isEqualToString:@"privateivar"]||[ret isEqualToString:@"ivar"]||[ret isEqualToString:@"justivar"]||[ret isEqualToString:@"class"]||[ret isEqualToString:@"getter"]||[ret isEqualToString:@"setter"])&&[self readc:r anyof:@"="]&&(w=[self readWord:r])) {
        ret=[ret stringByAppendingFormat:([self readc:r anyof:@":"]?@"=%@:":@"=%@"),w];
    }
    else if ([ret isEqualToString:@"readonly"]&&[self readc:r anyof:@"!"]) {
        ret=[ret stringByAppendingString:@"!"];
    }
        
    return(ret);
}

- (NSString*)readVarDefaultValue:(WReader*)r {
    Int pos=r.pos;
    [self readc:r anyof:@"="];
    NSString *ret=nil;
    //[WClasses note:[NSString stringWithFormat:@"def : %@",r.localString] withToken:r.currentToken context:nil];
    if ((ret=[self readWord:r])||(ret=[self readString:r])||(ret=[self readNumber:r])) return(ret);
    if ([self readc:r anyof:@"@"]) {
        if ((ret=[self readString:r])) return([@"@" stringByAppendingString:ret]);
        r.pos=pos;
    }
    if ([self readc:r anyof:@"-"]) {
        if ((ret=[self readNumber:r])) return([@"-" stringByAppendingString:ret]);
        r.pos=pos;
    }
    if ([self readc:r anyof:@"["]) {
        NSMutableString *ret=[NSMutableString stringWithString:@"["];
        WReaderToken *t=r.currentToken;
        Int d=1;
        while (t&&(d>0)) {
            [ret appendString:t.str];
            if ([t.str isEqualToString:@"]"]) d--;
            else if ([t.str isEqualToString:@"["]) d++;
            t=r.nextToken;
        }
        if (!d) return(ret);
    }
    r.pos=pos;
    return(nil);
}

-(bool)readType:(WReader*)r retclas:(WClass*__strong*)pclas retprotocolList:(NSArray*__strong*)pprotocolList needColon:(bool)needColon {
    Int pos=r.pos;
    unichar ch=[self readOpcOnOneLine:r];
    WClass *clas=nil;
    
    WReaderToken *t0=r.currentToken;
    
    if (pclas) {
        NSString *name;
        if (ch=='<') {
            name=@"NSObject";
        }
        else {
            Int pos2=pos;
            if (needColon) {
                if (ch==':') {
                    pos2=r.pos;
                    ch=[self readOpcOnOneLine:r];
                }
                else {
                    r.pos=pos;
                    return(NO);
                }
            }
            if (ch) {
                r.pos=pos;
                return(NO);
            }
            else {
                r.pos=pos2;
                if (!(name=[self readWordOnOneLine:r])) {
//                [WClasses error:@"Bad super name" withReader:r];
                    r.pos=pos;
                    return(NO);
                }
            }
            pos=r.pos;
            ch=[self readOpcOnOneLine:r];
        }
        clas=[WClass getClassWithName:name];
    }
    NSMutableArray *protocolList=nil;
    if (ch=='<') {
        protocolList=[NSMutableArray array];
        while (YES) {
            WReaderToken *t=[self skipSpaces:r];
            if (!t) {
                r.pos=pos;
                [WClasses error:@"Expected end of protocol list" withToken:t0 context:nil];
                return(NO);
            }
            r.pos++;
            if ([t.str isEqualToString:@">"]) break;
            else if ([t.str isEqualToString:@"+"]||[t.str isEqualToString:@"-"]) [protocolList addObject:t.str];
            else if (t.type=='w') {
                WClass *c=[WClass getProtocolWithName:t.str];
                if (c) [protocolList addObject:c];
            }
            else if (![t.str isEqualToString:@","]) {
                [WClasses error:@"Expected a protocol word" withToken:t0 context:nil];
            }
        }
    }
    else r.pos=pos;
    if ((clas==nil)&&(protocolList.count==0)) {
        r.pos=pos;
        return(NO);
    }
    if (pclas) *pclas=clas;
    if (pprotocolList) *pprotocolList=protocolList;
    return(YES);
}

-(bool)readPotentialType:(WReader*)r retclas:(NSString*__strong*)pclas retprotocolList:(NSArray*__strong*)pprotocolList needColon:(bool)needColon {
    Int pos=r.pos;
    unichar ch=[self readOpcOnOneLine:r];
    NSString *clas=nil;
    
    WReaderToken *t0=r.currentToken;

    if (pclas) {
        NSString *name;
        if (ch=='<') {
            name=@"NSObject";
        }
        else {
            Int pos2=pos;
            if (needColon) {
                if (ch==':') {
                    pos2=r.pos;
                    ch=[self readOpcOnOneLine:r];
                }
                else {
                    r.pos=pos;
                    return(NO);
                }
            }
            if (ch) {
                r.pos=pos;
                return(NO);
            }
            else {
                r.pos=pos2;
                if (!(name=[self readWordOnOneLine:r])) {
//                [WClasses error:@"Bad super name" withReader:r];
                    r.pos=pos;
                    return(NO);
                }
            }
            pos=r.pos;
            ch=[self readOpcOnOneLine:r];
        }
        clas=name;
    }
    NSMutableArray *protocolList=nil;
    if (ch=='<') {
        protocolList=[NSMutableArray array];
        while (YES) {
            WReaderToken *t=[self skipSpaces:r];
            if (!t) {
                r.pos=pos;
                [WClasses error:@"Expected end of protocol list" withToken:t0 context:nil];
                return(NO);
            }
            r.pos++;
            if ([t.str isEqualToString:@">"]) break;
            else if ([t.str isEqualToString:@"+"]||[t.str isEqualToString:@"-"]) [protocolList addObject:t.str];
            else if (t.type=='w') {
                [protocolList addObject:t.str];
            }
            else if (![t.str isEqualToString:@","]) {
                [WClasses error:@"Expected a protocol word" withToken:t0 context:nil];
            }
        }
    }
    else r.pos=pos;
    if ((clas==nil)&&(protocolList.count==0)) {
        r.pos=pos;
        return(NO);
    }
    if (pclas) *pclas=clas;
    if (pprotocolList) *pprotocolList=protocolList;
    return(YES);
}


-(WType*)readType:(WReader*)r {
    WClass *clas;
    NSArray *protocolList;
    if (![self readType:r retclas:&clas retprotocolList:&protocolList needColon:NO]) return(nil);
    return([WType newWithClass:clas protocols:protocolList addObject:NO]);
}
-(WPotentialType*)readPotentialType:(WReader*)r {
    NSString *clas;
    NSArray *protocolList;
    if (![self readPotentialType:r retclas:&clas retprotocolList:&protocolList needColon:NO]) return(nil);
    return([WPotentialType newWithClass:clas protocols:protocolList addObject:NO]);
}



- (NSArray*)readVar:(WReader*)r {
    return([self readVar:r asStrongThisTime:NO]);
}

- (NSArray*)readVar:(WReader*)r asStrongThisTime:(bool)asStrongThisTime {
    bool redoAsStrong=NO;
    Int pos1=r.pos;
    WReaderToken *t0=r.currentToken;

    do {
//        [WClasses warning:[NSString stringWithFormat:@"rv"] withReader:r];
        WClass *c=[self enclosingClass:r];
        if (!c) return(nil);

//        [WClasses warning:[NSString stringWithFormat:@"rv2"] withReader:r];

        [[WClasses getDefault] skipSpaces:r];
        Int bc=r.currentToken.bracketCount;
        Int linei=r.currentToken.linei;
        
        WPotentialType *ptype;
        if (!(ptype=[self readPotentialType:r])) return(nil);
        NSString *aname,*aqname=nil;

        NSMutableArray *names=[NSMutableArray array],*defaultValues=[NSMutableArray array],*defLevels=[NSMutableArray array],*getters=[NSMutableArray array],*setters=[NSMutableArray array],*setterVars=[NSMutableArray array],*tags=[NSMutableArray array],*qnames=[NSMutableArray array],*starss=[NSMutableArray array];
        NSMutableSet *attr=nil;
        
//        [WClasses warning:[NSString stringWithFormat:@"var"] withReader:r];

        unichar ch;
        Int stars=0;
        while ((ch=[self readOpc:r])=='*') stars++;
        if (ch) {
            break;
        }
        if (!(aname=[self readWord:r])) break;
        if ([aname isEqualToString:@"metaEnabledURLRegistry"]) {
        }
//        [WClasses warning:[NSString stringWithFormat:@"%@",aname] withReader:r];
        Int posq=r.pos;
        if (!([self readc:r anyof:@">"]&&[self readc:r anyof:@">"]&&(aqname=[self readWord:r]))) {
            r.pos=posq;
        }
        
        [names addObject:aname];
        [starss addObject:@(stars)];
        [qnames addObject:aqname?aqname:[NSNull null]];
        
        Int pos2=r.pos;
        ch=[self readOpc:r];
        NSString *tag=nil;
        if ((ch==':')&&(tag=[self readWord:r])) {
            [tags addObject:tag];
            pos2=r.pos;
            ch=[self readOpc:r];
        }
        else [tags addObject:[NSNull null]];
            
        //[WClasses warning:[NSString stringWithFormat:@"posttags"] withReader:r];

        while (YES) {
            if (ch=='=') {
                

                NSString *def=nil,*getter=nil,*setter=nil,*setterVar=nil;
                Int defLevel=0;
                bool changed=YES;
                while (changed) {
                    //[WClasses note:r.localString withToken:t0 context:nil];
                    changed=NO;
                    Int pos2=r.pos;
                    if (r.currentToken.type=='c') {
                        bool appendb;
                        Int numTokens;
                        Int n=[WFn tokenMergeNumber:r.tokenizer pos:r.pos append:&appendb retNumTokens:&numTokens];
                        if (n!=NSNotFound) {
                            r.pos+=numTokens;
                            if ((!def)&&((def=[self readVarDefaultValue:r]))) {
                                changed=YES;
                                defLevel=n;
                            }
                        }
                    }
                    if (!changed) {
                        WReaderToken *gstoken=r.currentToken;
                        if ((!def)&&((def=[self readVarDefaultValue:r]))) changed=YES;
                        else if ((!getter)&&((getter=[self readBlock:r retPrefix:nil linei:gstoken.linei bracketCount:gstoken.bracketCount clearBrackets:YES]))) changed=YES;
                        else if ((!setter)&&[self readc:r anyof:@"-"]&&((setterVar=[self readWord:r]))&&((setter=[self readBlock:r retPrefix:nil linei:gstoken.linei bracketCount:gstoken.bracketCount clearBrackets:YES]))) changed=YES;
                    }
                    if (changed) {
                        Int lni=r.currentToken.linei;
                        [self skipSpaces:r];
                        //[WClasses warning:[NSString stringWithFormat:@"linei=%d:%d bc=%d:%d",linei,r.currentToken.linei,bc,r.currentToken.bracketCount] withReader:r];
                        if ((!r.currentToken)||((r.currentToken.linei>lni)&&(r.currentToken.bracketCount<=bc))) break;
                    }
                    else r.pos=pos2;
                }
                [defLevels addObject:(def?@(defLevel):[NSNull null])];
                [defaultValues addObject:(def?def:[NSNull null])];
                [getters addObject:(getter?getter:[NSNull null])];
                [setters addObject:(setter?setter:[NSNull null])];
                [setterVars addObject:(setterVar?setterVar:[NSNull null])];
                pos2=r.pos;
                ch=[self readOpc:r];
            }
            else {
                [defaultValues addObject:[NSNull null]];
                [defLevels addObject:[NSNull null]];
                [getters addObject:[NSNull null]];
                [setters addObject:[NSNull null]];
                [setterVars addObject:[NSNull null]];
            }

                    //[WClasses note:r.localString withToken:t0 context:nil];

                    //[WClasses warning:[NSString stringWithFormat:@"here"] withReader:r];
            if (ch!=',') break;

            stars=0;
            while ((ch=[self readOpc:r])=='*') stars++;
            if (ch) {
                [WClasses error:@"Expected * (2)" withToken:t0 context:nil];
                break;
            }
            if (!(aname=[self readWord:r])) {           
                [WClasses error:@"expected name" withToken:t0 context:nil];
                break;
            }
            Int posq=r.pos;
            if (!([self readc:r anyof:@">"]&&[self readc:r anyof:@">"]&&(aqname=[self readWord:r]))) {
                r.pos=posq;
            }
            [names addObject:aname];
            [qnames addObject:aqname?aqname:[NSNull null]];
            [starss addObject:@(stars)];
            pos2=r.pos;
                    //[WClasses warning:[NSString stringWithFormat:@"here"] withReader:r];
            ch=[self readOpc:r];
        }
        //[WClasses warning:[NSString stringWithFormat:@"%c",ch] withReader:r];

        bool implThisVar=!asStrongThisTime;
        
        if (ch=='(') {
            attr=[NSMutableSet set];
            NSString *s;
            bool strongVer=NO;
            for (s=[self readVarAttribute:r];s;s=[self readVarAttribute:r]) {
                if ([s isEqualToString:@"weakandstrong"]) {
                    if (asStrongThisTime) {
                        s=@"strong";implThisVar=strongVer=YES;
                        for (Int i=0;i<names.count;i++) names[i]=[names[i] stringByAppendingString:@"_strong"];
                        for (Int i=0;i<qnames.count;i++) if ([qnames[i] isKindOfClass:NSString.class]) qnames[i]=[qnames[i] stringByAppendingString:@"_strong"];
                    }
                    else {s=@"weak";redoAsStrong=YES;}
                }
                [attr addObject:s];
                while ([self readc:r anyof:@","]);
                if ([self readc:r anyof:@")"]) break;
            }
            if (strongVer) {
                NSMutableSet *attr2=nil;
                for (NSString *a in attr) if ([a hasPrefix:@"ivar="]) {
                    attr2=attr.mutableCopy;
                    [attr2 removeObject:a];
                    [attr2 addObject:[a stringByAppendingString:@"_strong"]];
                }
                if (attr2) attr=attr2;
            }
                
            if (!s) {
                [WClasses error:@"Bad attribute array" withToken:t0 context:nil];
                r.pos=pos2;
                [attr removeAllObjects];
            }
            if ([attr containsObject:@"attribute"]) {
                [attr addObject:@"imaginary"];
                [attr addObject:@"nodef"];
                for (Int i=0;i<names.count;i++) {
                    [WFn getFnWithSig:[NSString stringWithFormat:@"-(SHAttribute*)%@",names[i]] body:[NSString stringWithFormat:@"@999 return([self.program.attributes objectForKey:@\"%@\"]);",names[i]] clas:c];
                }
            }
            if ([attr containsObject:@"uniform"]) {
                [attr addObject:@"imaginary"];
                [attr addObject:@"nodef"];
                for (Int i=0;i<names.count;i++) {
                    [WFn getFnWithSig:[NSString stringWithFormat:@"-(SHUniform*)%@",names[i]] body:[NSString stringWithFormat:@"@999 return([self.program.uniforms objectForKey:@\"%@\"]);",names[i]] clas:c];
                }
            }
            if ([attr containsObject:@"ivargetter"]) {
                [attr addObject:@"readonly"];
                [attr addObject:@"dealloc"];
                [attr addObject:@"ivar"];
            }
        }
        else r.pos=pos2;
        drprnt("Var : %s\n",[[r stringWithTokensInRange:NSMakeRange(pos1, r.pos-pos1)] cStringUsingEncoding:NSASCIIStringEncoding]);
        [self skipSpacesAndSemicolons:r];
        
        if (implThisVar) {
            NSMutableArray *rets=[NSMutableArray array];
            Int i=0;
            WType *type;
            for (NSString *name in names) {
                NSMutableSet *attr2=attr;
                Int stars=((NSNumber*)starss[i]).intValue;
                if ([getters[i] isKindOfClass:[NSString class]]&&![setters[i] isKindOfClass:[NSString class]]) {
                    //attr2=(attr2?attr2.mutableCopy:[NSMutableSet set]);
                    //[attr2 addObject:@"readonly"];
                }
                if (!i) {
                    type=[WType newWithPotentialType:ptype];
                }
                WVar *v=[WVar getVarWithType:type stars:stars name:name qname:[qnames[i] isKindOfClass:[NSString class]]?qnames[i]:nil defVal:[defaultValues[i] isKindOfClass:[NSNull class]]?nil:defaultValues[i] defValLevel:[defLevels[i] isKindOfClass:[NSNull class]]?0:((NSNumber*)defLevels[i]).intValue attributes:attr2 clas:c];
                [v addInFilename:r.filePath line:linei column:0];
                [rets addObject:v];
    //            if ([attr containsObject:@"modelretain"]) {
    //                [getters replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"return(%@);",v.varName]];
    //                if (![attr2 containsObject:@"readonly"]) {
    //                    [setters replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"[%@ modelrelease];\n%@=[v modelretain];",v.varName,v.varName]];
    //                    [setterVars replaceObjectAtIndex:i withObject:@"v"];
    //                }
    //            }
                if ([getters[i] isKindOfClass:[NSString class]]) {
                    WFn *fn=[WFn getFnWithSig:[NSString stringWithFormat:@"-(%@)%@",v.objCType,name] body:(NSString*)getters[i] clas:c];
                    [fn addInFilename:r.filePath line:linei column:0];
                }
                if ([setters[i] isKindOfClass:[NSString class]]) {
                    WFn *fn=[WFn getFnWithSig:[NSString stringWithFormat:@"-(void)set%@:(%@)%@",[WProp upperName:name],v.objCType,setterVars[i]] body:(NSString*)setters[i] clas:c];
                    [fn addInFilename:r.filePath line:linei column:0];

                }
                i++;
            }


            for (WVar *ret in rets) {
                [ret add:r];
            }
            if (redoAsStrong) {
                Int redopos=r.pos;
                r.pos=pos1;
                NSArray *rets2=[self readVar:r asStrongThisTime:YES];
                r.pos=redopos;
                if (rets2) [rets addObjectsFromArray:rets2];
            }
            return(rets);
        }
        else return(nil);
        
    } while (false);
    r.pos=pos1;
    return(nil);
}

- (WFn*)readFn:(WReader*)r {
    WClass *c=[self enclosingClass:r];
    if (!c) return(nil);

    Int linei=r.currentToken.linei;
    Int bc=r.currentToken.bracketCount;
    Int pos=r.pos;
    
    unichar ch;
    switch ((ch=[self readOpc:r])) {
        default:return(nil);
        case '-':case '+':break;
    }
    NSString *sig=nil;
    NSString *body=nil;

    body=[self readBlock:r retPrefix:&sig linei:linei bracketCount:bc clearBrackets:YES];
    if (!body) {r.pos=pos;return(nil);}

    sig=[NSString stringWithFormat:@"%c%@",ch,[sig stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];

    drprnt("Fn : %s | %s\nFrom : %s\n",sig.UTF8String,body.UTF8String,[[r stringWithTokensInRange:NSMakeRange(pos, r.pos-pos)] cStringUsingEncoding:NSASCIIStringEncoding]);
    [self skipSpacesAndSemicolons:r];
    WFn *fn=[WFn getFnWithSig:sig body:body clas:c];
    [fn addInFilename:r.filePath line:linei column:0];
    return(fn);
}

- (WProp*)readProp:(WReader*)r {
    [self skipSpaces:r];
    Int bc=r.currentToken.bracketCount;
    Int linei=r.currentToken.linei;
    
    WProp *p=[self enclosingProp:r];
    WClass *c=(p?p.hisclas:[self enclosingClass:r]);
    NSString *name,*tag=nil,*qname=nil,*hisName,*hisTag=nil,*hisqname=nil,*type,*s;
    
    WClass *hisClass=nil;
    Int pos=r.pos;
    if (!(name=[self readWord:r])) {
        r.pos=pos;
        return(nil);
    }
    Int posq=r.pos;
    if (!([self readc:r anyof:@">"]&&[self readc:r anyof:@">"]&&(qname=[self readWord:r]))) {
        r.pos=posq;
    }
    Int post=r.pos;
    if (!([self readc:r anyof:@":"]&&(tag=[self readWord:r]))) r.pos=post;
    Int tposWas=r.pos;
    if (!(type=[self readPropType:r])) {
        r.pos=pos;
        return(nil);
    }
    
    NSMutableString *origType=[NSMutableString string];
    for (Int p=tposWas;p<r.pos;p++) [origType appendString:((WReaderToken*)(r.tokenizer.tokens)[p]).str];

    bool isProtocol=NO;
    if (!(s=[self readWord:r])) {
        if (!([self readc:r anyof:@"<"]&&(s=[self readWord:r])&&[self readc:r anyof:@">"])) {
            r.pos=pos;
            return(nil);
        }
        isProtocol=YES;
    }
    Int pos2=r.pos;
    if ((r.currentToken.type=='z')&&(r.nextToken.type=='w')) {
        hisClass=(isProtocol?[WClass getProtocolWithName:s]:[WClass getClassWithName:s]);
        hisName=r.currentToken.str;
        r.pos++;
    }
    else {
        if (isProtocol) {
            r.pos=pos;
            return(nil);
        }
        hisName=s;
        r.pos=pos2;
    }
    posq=r.pos;
    if (!([self readc:r anyof:@">"]&&[self readc:r anyof:@">"]&&(hisqname=[self readWord:r]))) {
        r.pos=posq;
    }
    post=r.pos;
    if (!([self readc:r anyof:@":"]&&(hisTag=[self readWord:r]))) r.pos=post;
    WProp *ret=[WProp getPropWithMyClass:c myName:name myQName:qname type:type origType:origType hisClass:hisClass hisName:hisName hisQName:hisqname];
    if (!ret) return(nil);

    [ret addInFilename:r.filePath line:linei column:0];

    [ret add:r];
    drprnt("Prop : %s\n",[[r stringWithTokensInRange:NSMakeRange(pos, r.pos-pos)] cStringUsingEncoding:NSASCIIStringEncoding]);
    [self skipSpacesAndSemicolons:r];
    [self.propertyContexts addObject:ret];
    [self.propertyContextBrackets addIndex:bc];
    [self.propertyContextLineis addObject:@(linei)];
    while (YES) {
        [self skipSpaces:r];
        if ((!r.currentToken)||(r.currentToken.bracketCount<=bc)) break;
        if (!(
              [self readVar:r]||
              [self readFn:r]||
              [self readProp:r]
              )) {
            [WClasses error:[NSString stringWithFormat:@"Expected var, fn, or prop in prop %@ %@ :: %@ %@",c.name,name,hisClass.name,hisName] withToken:r.currentToken context:ret];
            break;
        }
    }
    [self.propertyContexts removeObject:ret];
    [self.propertyContextBrackets removeIndex:bc];
    [self.propertyContextLineis removeLastObject];
    drprnt("Prop and children : %s\n",[[r stringWithTokensInRange:NSMakeRange(pos, r.pos-pos)] cStringUsingEncoding:NSASCIIStringEncoding]);
    [self skipSpacesAndSemicolons:r];
    return(ret);
}

- (WClass*)readClass:(WReader*)r {
    if (self.classContext) return(nil);
    [self skipSpaces:r];
    Int bc=r.currentToken.bracketCount;
    Int linei=r.currentToken.linei;
    
    NSString *name;
    NSMutableSet *varPatterns=nil;
    bool isSys=NO,isType=NO,isBlock=NO,isWIOnly=NO;
    
    Int pos=r.pos;
    if (!(name=[self readWord:r])) return(nil);
    
    while (true) {
        if ((!isWIOnly)&&[name isEqualToString:@"wi"]) {
            isWIOnly=YES;
            if (!(name=[self readWord:r])) {r.pos=pos;return(nil);}
        }
        else if ((!isSys)&&[name isEqualToString:@"sys"]) {
            isSys=YES;
            if (!(name=[self readWord:r])) {r.pos=pos;return(nil);}
        }
        else if ((!isType)&&[name isEqualToString:@"type"]) {
            isType=YES;
            if (!(name=[self readWord:r])) {r.pos=pos;return(nil);}
        }
        else if ((!isType)&&[name isEqualToString:@"block"]) {
            isBlock=YES;
            if (!(name=[self readWord:r])) {r.pos=pos;return(nil);}
        }
        else break;
    }
    if (isBlock) isType=YES;
    
    WClass *superClass=nil;
    NSArray *protocolList=nil;
    if ([self readType:r retclas:&superClass retprotocolList:&protocolList needColon:YES]&&[superClass.name isEqualToString:@"NSObject"]) superClass=nil;
    
    
    while (YES) {
        WReaderToken *t=[self skipSpaces:r];
        if (t.type=='s') {
            if (varPatterns==nil) varPatterns=[NSMutableSet set];
            if (t.str.length>2) [varPatterns addObject:[t.str substringWithRange:NSMakeRange(1,t.str.length-2)]];
            r.pos++;
        }
        else break;
    }
    
    WClass *c=[WClass getClassWithName:name superClass:superClass protocolList:protocolList varPatterns:varPatterns];
    [c addInFilename:r.filePath line:linei column:0];

    if (c==nil) return(nil);
    if (isSys) c.isSys=isSys;
    if (isWIOnly) c.isWIOnly=isWIOnly;
    if (isType) c.isType=isType;
    if (isBlock) c.isBlock=isBlock;

    if (!finishedParse) c.hasDef=YES;
    
    drprnt("Class : %s\n",[[r stringWithTokensInRange:NSMakeRange(pos, r.pos-pos)] cStringUsingEncoding:NSASCIIStringEncoding]);
    [self skipSpacesAndSemicolons:r];
    bool hasChild=NO;
    self.classContext=c;
    self.classContextBracket=bc;
    self.classContextLinei=linei;
    bool bch=[self readc:r anyof:@"{"];
    while (YES) {
        [self skipSpaces:r];
        if ((!r.currentToken)||(bch&&[r.currentToken.str isEqualToString:@"}"])||((r.currentToken.bracketCount<=bc)&&(r.currentToken.linei>linei))) break;
        if (!(
              [self readVar:r]||
              [self readFn:r]||
              [self readProp:r]
              )) {
            [WClasses error:[NSString stringWithFormat:@"Expected var, fn, or prop in class %@",name] withToken:r.currentToken context:c];
            break;
        }
        hasChild=YES;
    }
    if (bch) [self readc:r anyof:@"}"];
    else if (!(hasChild||[self readVar:r]||[self readFn:r]||[self readProp:r])) {}
    self.classContext=nil;
    self.classContextBracket=-1;
    self.classContextLinei=-1;
    drprnt("Class and children : %s\n",[[r stringWithTokensInRange:NSMakeRange(pos, r.pos-pos)] cStringUsingEncoding:NSASCIIStringEncoding]);
    [self skipSpacesAndSemicolons:r];

    if (c&&self.settingsContext[@"fn"]) {
        bool hasFn=NO;
        NSString *deffn=nil;
        for (NSObject *o in c.varPatterns) if ([o isKindOfClass:NSString.class]) {
            if ([(NSString*)o hasPrefix:@"fn:"]) {hasFn=YES;break;}
            if ([(NSString*)o hasPrefix:@"_fn:"]) {deffn=(NSString*)o;break;}
        }
        if (!hasFn) {
            if (deffn&&![deffn isEqualToString:@"_fn:default"]) {
                NSMutableSet *s=c.varPatterns.mutableCopy;
                [s removeObject:deffn];
                [s removeObject:@"_fn:default"];
                c.varPatterns=s.copy;
            }
            if (!deffn) {
                if (!c.varPatterns) c.varPatterns=NSMutableSet.set;
                c.varPatterns=[c.varPatterns setByAddingObject:[@"_fn:" stringByAppendingString:self.settingsContext[@"fn"]]];
            }
        }
    }
    return(c);
}


- (WClass*)readProtocol:(WReader*)r {
//return(nil);
    if (self.classContext) return(nil);
    [self skipSpaces:r];
    Int bc=r.currentToken.bracketCount;
    Int linei=r.currentToken.linei;
    WReaderToken *t0=r.currentToken;
    
    NSString *name;
    NSMutableSet *varPatterns=nil;
    NSMutableArray *superNames=nil;
    bool issys=NO;
    
    Int pos=r.pos;
    NSString *w=[self readWord:r];
    if (w) {
        if (![w isEqualToString:@"sys"]) r.pos=pos;
        else issys=YES;
    }
    
    if (!(([self readOpc:r]=='<')&&(name=[self readWord:r]))) {
        r.pos=pos;
        return(nil);
    }
    Int pos2=r.pos;
    unichar ch;
    if ((ch=[self readOpc:r])==':') {
        superNames=[NSMutableArray array];
        while (YES) {
            WReaderToken *t=[self skipSpaces:r];
            if (!t) {
                r.pos=pos;
                [WClasses error:@"Expected end of protocol super list" withToken:t0 context:nil];
                return(NO);
            }
            r.pos++;
            if ([t.str isEqualToString:@">"]) break;
            else if ([t.str isEqualToString:@"+"]||[t.str isEqualToString:@"-"]) [superNames addObject:t.str];
            else if (t.type=='w') {
                WClass *c=[WClass getProtocolWithName:t.str];
                if (c) [superNames addObject:c];
            }
            else if (![t.str isEqualToString:@","]) {
                [WClasses error:@"Expected a super protocol word" withToken:t0 context:nil];
            }
        }
    }
    else if (ch!='>') {
        [WClasses error:@"Expected > to end protocol name" withToken:t0 context:nil];
        r.pos=pos2;
        return(nil);
    }
        
    
    while (YES) {
        WReaderToken *t=[self skipSpaces:r];
        if (t.type=='s') {
            if (varPatterns==nil) varPatterns=[NSMutableSet set];
            if (t.str.length>2) [varPatterns addObject:[t.str substringWithRange:NSMakeRange(1,t.str.length-2)]];
            r.pos++;
        }
        else break;
    }
    
    WClass *c=[WClass getProtocolWithName:name superList:superNames varPatterns:varPatterns];
    if (issys) c.isSys=YES;
    [c addInFilename:r.filePath line:linei column:0];
    
    if (!finishedParse) c.hasDef=YES;
    
    if (c==nil) return(nil);
    drprnt("Protocol : %s\n",[[r stringWithTokensInRange:NSMakeRange(pos, r.pos-pos)] cStringUsingEncoding:NSASCIIStringEncoding]);
    [self skipSpacesAndSemicolons:r];
    bool hasChild=NO;
    self.classContext=c;
    self.classContextBracket=bc;
    self.classContextLinei=linei;
    while (YES) {
        [self skipSpaces:r];
        if ((!r.currentToken)||(r.currentToken.bracketCount<=bc)) break;
        if (!(
              [self readVar:r]||
              [self readFn:r]||
              [self readProp:r]
              )) {
            [WClasses error:@"Expected var, fn, or prop in protocol" withToken:r.currentToken context:c];
            break;
        }
        hasChild=YES;
    }
    if (!(hasChild||[self readVar:r]||[self readFn:r]||[self readProp:r])) {}
    self.classContext=nil;
    self.classContextBracket=-1;
    self.classContextLinei=-1;
    drprnt("Protocol and children : %s\n",[[r stringWithTokensInRange:NSMakeRange(pos, r.pos-pos)] cStringUsingEncoding:NSASCIIStringEncoding]);
    [self skipSpacesAndSemicolons:r];
    return(c);
}

+ (void)changeToFileDir:(NSString*)fn {
    fn=[fn stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    Int ind=(Int)[fn rangeOfString:@"/" options:NSBackwardsSearch].location;
    if (ind==NSNotFound) return;
    NSFileManager *fm=[NSFileManager defaultManager];
    [fm changeCurrentDirectoryPath:[fn substringToIndex:ind+1]];
}

- (bool)readInclude:(WReader*)r {
    if (self.classContext) return(NO);
    Int pos=r.pos;
    NSString *w,*name=[self readString:r];
    if (name) {
        name=[name substringWithRange:NSMakeRange(1, name.length-2)];
        if ([name hasPrefix:@"<"]&&[name hasSuffix:@">"]) {
            if (![self.incls containsObject:name]) [self.incls addObject:name];
        }
        else if ([name hasPrefix:@"'"]&&[name hasSuffix:@"'"]) {
            name=[NSString stringWithFormat:@"\"%@\"",[name substringWithRange:NSMakeRange(1, name.length-2)]];
            if (![self.incls containsObject:name]) [self.incls addObject:name];
        }
        else if ([name hasSuffix:@".h"]) {
            name=[NSString stringWithFormat:@"\"%@\"",name];
            if (![self.incls containsObject:name]) [self.incls addObject:name];
        }
        else if ([name hasPrefix:@"fn:"]) {
            self.settingsContext[@"fn"]=[name substringFromIndex:3];
        }
        else {
            NSString *fn=name;
            if (fn) {
                printf("Include: %s\n",fn.UTF8String);
                if ([self.readFNStack containsObject:fn]) {
                    [WClasses error:@"File already included" withToken:r.currentToken context:nil];
                }
                else {
                    WReader *r2=[[WReader alloc] init];
                    r2.tokenizer.tokenDelegate=[WClasses getDefault];
                    [InFiles clearMarksFromFiles:@[fn]];
                    r2.fileName=fn;
                    if (r2.fileString.length==0) {
                        [WClasses error:
                            ([fn isEqualToString:name]?
                                [NSString stringWithFormat:@"File \"%@\" is empty or doesn't exist",name]:
                                [NSString stringWithFormat:@"File \"%@\" (i.e. %@) is empty or doesn't exist",name,fn]
                            ) withToken:r.currentToken context:nil];
                    }
                    else {
                        NSFileManager *fm=[NSFileManager defaultManager];
                        NSString *wasDir=fm.currentDirectoryPath;
                        [[self class] changeToFileDir:fn];
                        [self.readFNStack addObject:fn];
                        if ([fn hasSuffix:@"wierrors.wi"]) [InFiles addInFilename:r2.filePath line:0 column:0 format:@"%@",[InFiles excessMsg]];
                        [self read:r2 logContext:nil];
                        [self.readFNStack removeObject:fn];
                        [fm changeCurrentDirectoryPath:wasDir];
                        if (![name isEqualToString:fn]) {
                            [WClasses note:[NSString stringWithFormat:@"(i.e. %@)",fn] withToken:r.currentToken context:nil];
                        }
                    }
                }
            }
        }
        return(YES);
    }
            
    bool isAng=NO;
    if (!((w=[self readWord:r])&&([w isEqualToString:@"import"]||[w isEqualToString:@"include"])&&((isAng=[self readc:r anyof:@"<"])||(name=[self readString:r])))) {
        r.pos=pos;
        return(NO);
    }
    Int pos2=r.pos;
    if (isAng) {
        NSMutableString *s=[NSMutableString stringWithString:@"<"];
        WReaderToken *t;
        while ((t=r.currentToken)&&![t.str isEqualToString:@">"]) [s appendString:t.str];
        if (!t) {
            r.pos=pos2;
            [WClasses error:@"Expected end of include" withToken:r.currentToken context:nil];
            return(NO);
        }
        [s appendString:@">"];
        name=s;
    }
    [self.includes addObject:[w stringByAppendingFormat:@" %@",name]];
    return(YES);
}


-(NSMutableString*)importsDeclWithName:(NSString*)s nameUsed:(NSString*__strong*)pnameUsed {
    NSString *nn,*__strong*n=(pnameUsed?pnameUsed:&nn);
    if ([s hasPrefix:*n=@"top:decl"]) return(ins_first_decl);
    else if ([s hasPrefix:*n=@"imports:decl"]) return(ins_after_imports_decl);
    else if ([s hasPrefix:*n=@"decl:decl"]) return(ins_after_decl_decl);
    else if ([s hasPrefix:*n=@"structs:decl"]) return(ins_after_structs_decl);
    else if ([s hasPrefix:*n=@"protocols:decl"]) return(ins_after_protocols_decl);
    else if ([s hasPrefix:*n=@"interfaces:decl"]) return(ins_after_ifaces_decl);
    else if ([s hasPrefix:*n=@"bottom:decl"]) return(ins_last_decl);

    else if ([s hasPrefix:*n=@"top:iface"]) return(ins_first_iface);
    else if ([s hasPrefix:*n=@"imports:iface"]) return(ins_after_imports_iface);
    else if ([s hasPrefix:*n=@"decl:iface"]) return(ins_after_decl_iface);
    else if ([s hasPrefix:*n=@"structs:iface"]) return(ins_after_structs_iface);
    else if ([s hasPrefix:*n=@"protocols:iface"]) return(ins_after_protocols_iface);
    else if ([s hasPrefix:*n=@"interfaces:iface"]) return(ins_after_ifaces_iface);
    else if ([s hasPrefix:*n=@"bottom:iface"]) return(ins_last_iface);

    else if ([s hasPrefix:*n=@"top:impl"]) return(ins_first_impl);
    else if ([s hasPrefix:*n=@"imports:impl"]) return(ins_after_imports_impl);
    else if ([s hasPrefix:*n=@"decl:impl"]) return(ins_after_decl_impl);
    else if ([s hasPrefix:*n=@"structs:impl"]) return(ins_after_structs_impl);
    else if ([s hasPrefix:*n=@"protocols:impl"]) return(ins_after_protocols_impl);
    else if ([s hasPrefix:*n=@"interfaces:impl"]) return(ins_after_ifaces_impl);
    else if ([s hasPrefix:*n=@"bottom:impl"]) return(ins_last_impl);

    else if ([s hasPrefix:*n=@"top"]) return(ins_first_iface);
    else if ([s hasPrefix:*n=@"imports"]) return(ins_after_imports_iface);
    else if ([s hasPrefix:*n=@"decl"]) return(ins_after_decl_iface);
    else if ([s hasPrefix:*n=@"structs"]) return(ins_after_structs_iface);
    else if ([s hasPrefix:*n=@"protocols"]) return(ins_after_protocols_iface);
    else if ([s hasPrefix:*n=@"interfaces"]) return(ins_after_ifaces_iface);
    else if ([s hasPrefix:*n=@"bottom"]) return(ins_last_iface);

    else if ([s hasPrefix:*n=@"iface"]) return(ins_after_decl_iface);
    else if ([s hasPrefix:*n=@"impl"]) return(ins_after_decl_impl);

    else if ([s hasPrefix:*n=@"each:impl"]) return(ins_each_impl);

    else {*n=@"";return(nil);}
}


-(NSMutableSet*)importsSetWithName:(NSString*)s nameUsed:(NSString*__strong*)pnameUsed {
    NSString *nn,*__strong*n=(pnameUsed?pnameUsed:&nn);
    if ([s hasPrefix:*n=@"top:decl"]) return(ins_set_first_decl);
    else if ([s hasPrefix:*n=@"imports:decl"]) return(ins_set_after_imports_decl);
    else if ([s hasPrefix:*n=@"decl:decl"]) return(ins_set_after_decl_decl);
    else if ([s hasPrefix:*n=@"structs:decl"]) return(ins_set_after_structs_decl);
    else if ([s hasPrefix:*n=@"protocols:decl"]) return(ins_set_after_protocols_decl);
    else if ([s hasPrefix:*n=@"interfaces:decl"]) return(ins_set_after_ifaces_decl);
    else if ([s hasPrefix:*n=@"bottom:decl"]) return(ins_set_last_decl);

    else if ([s hasPrefix:*n=@"top:iface"]) return(ins_set_first_iface);
    else if ([s hasPrefix:*n=@"imports:iface"]) return(ins_set_after_imports_iface);
    else if ([s hasPrefix:*n=@"decl:iface"]) return(ins_set_after_decl_iface);
    else if ([s hasPrefix:*n=@"structs:iface"]) return(ins_set_after_structs_iface);
    else if ([s hasPrefix:*n=@"protocols:iface"]) return(ins_set_after_protocols_iface);
    else if ([s hasPrefix:*n=@"interfaces:iface"]) return(ins_set_after_ifaces_iface);
    else if ([s hasPrefix:*n=@"bottom:iface"]) return(ins_set_last_iface);

    else if ([s hasPrefix:*n=@"top:impl"]) return(ins_set_first_impl);
    else if ([s hasPrefix:*n=@"imports:impl"]) return(ins_set_after_imports_impl);
    else if ([s hasPrefix:*n=@"decl:impl"]) return(ins_set_after_decl_impl);
    else if ([s hasPrefix:*n=@"decl:impl"]) return(ins_set_after_decl_impl);
    else if ([s hasPrefix:*n=@"structs:impl"]) return(ins_set_after_structs_impl);
    else if ([s hasPrefix:*n=@"protocols:impl"]) return(ins_set_after_protocols_impl);
    else if ([s hasPrefix:*n=@"interfaces:impl"]) return(ins_set_after_ifaces_impl);
    else if ([s hasPrefix:*n=@"bottom:impl"]) return(ins_set_last_impl);

    else if ([s hasPrefix:*n=@"top"]) return(ins_set_first_iface);
    else if ([s hasPrefix:*n=@"imports"]) return(ins_set_after_imports_iface);
    else if ([s hasPrefix:*n=@"decl"]) return(ins_set_after_decl_iface);
    else if ([s hasPrefix:*n=@"structs"]) return(ins_set_after_structs_iface);
    else if ([s hasPrefix:*n=@"protocols"]) return(ins_set_after_protocols_iface);
    else if ([s hasPrefix:*n=@"interfaces"]) return(ins_set_after_ifaces_iface);
    else if ([s hasPrefix:*n=@"bottom"]) return(ins_set_last_iface);

    else if ([s hasPrefix:*n=@"iface"]) return(ins_set_after_decl_iface);
    else if ([s hasPrefix:*n=@"impl"]) return(ins_set_after_decl_impl);

    else if ([s hasPrefix:*n=@"each:impl"]) return(ins_set_each_impl);

    else {*n=@"";return(nil);}
}



-(void)finalizeImportsString:(NSMutableString*)str withSet:(NSMutableSet*)set {
    NSArray *sa=[set.allObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return([(NSString*)obj1 compare:obj2]);
        }];
    for (NSString *s in sa) [str appendFormat:@"%@\n",s];
    [set removeAllObjects];
}

-(void)finalizeAllImports {
    [self finalizeImportsString:ins_first_decl withSet:ins_set_first_decl];
    [self finalizeImportsString:ins_after_imports_decl withSet:ins_set_after_imports_decl];
    [self finalizeImportsString:ins_after_decl_decl withSet:ins_set_after_decl_decl];
    [self finalizeImportsString:ins_after_structs_decl withSet:ins_set_after_structs_decl];
    [self finalizeImportsString:ins_after_protocols_decl withSet:ins_set_after_protocols_decl];
    [self finalizeImportsString:ins_after_ifaces_decl withSet:ins_set_after_ifaces_decl];
    [self finalizeImportsString:ins_last_decl withSet:ins_set_last_decl];
    [self finalizeImportsString:ins_first_iface withSet:ins_set_first_iface];
    [self finalizeImportsString:ins_after_imports_iface withSet:ins_set_after_imports_iface];
    [self finalizeImportsString:ins_after_decl_iface withSet:ins_set_after_decl_iface];
    [self finalizeImportsString:ins_after_structs_iface withSet:ins_set_after_structs_iface];
    [self finalizeImportsString:ins_after_protocols_iface withSet:ins_set_after_protocols_iface];
    [self finalizeImportsString:ins_after_ifaces_iface withSet:ins_set_after_ifaces_iface];
    [self finalizeImportsString:ins_last_iface withSet:ins_set_last_iface];
    [self finalizeImportsString:ins_first_impl withSet:ins_set_first_impl];
    [self finalizeImportsString:ins_after_imports_impl withSet:ins_set_after_imports_impl];
    [self finalizeImportsString:ins_after_decl_impl withSet:ins_set_after_decl_impl];
    [self finalizeImportsString:ins_after_structs_impl withSet:ins_set_after_structs_impl];
    [self finalizeImportsString:ins_after_protocols_impl withSet:ins_set_after_protocols_impl];
    [self finalizeImportsString:ins_after_ifaces_impl withSet:ins_set_after_ifaces_impl];
    [self finalizeImportsString:ins_last_impl withSet:ins_set_last_impl];
    [self finalizeImportsString:ins_each_impl withSet:ins_set_each_impl];
}



- (Int)readComments:(WReader*)r fromIndex:(Int)from toBeforeIndex:(Int)to {
    if ((from<0)||(from>=r.tokenizer.tokens.count)) return((Int)r.tokenizer.tokens.count);
    if ((to<0)||(to>r.tokenizer.tokens.count)) to=(Int)r.tokenizer.tokens.count;
    
    for (Int pos=from;pos<to;pos++) {
        WReaderToken *t=(r.tokenizer.tokens)[pos];
        if (t&&(t.type=='c')&&([t.str hasPrefix:@"/*"]||[t.str hasPrefix:@"//"])) {
            NSString *s=[t.str substringWithRange:NSMakeRange(2, t.str.length-2-([t.str hasPrefix:@"/*"]&&[t.str hasSuffix:@"*/"]?2:0))];
            NSString *nameUsed=nil;
            NSMutableString *decl=[self importsDeclWithName:s nameUsed:&nameUsed];
            if (decl) {
                [decl appendFormat:@"%@\n",[s substringFromIndex:nameUsed.length]];
            }
        }
    }
    return(to);
}

- (void)readKeepingContext:(WReader *)r {
    Int posWas=0;
    for (r.pos=0;r.pos<r.tokenizer.tokens.count;) {
        posWas=[self readComments:r fromIndex:posWas toBeforeIndex:r.pos];
        if (!([self readInclude:r]||[self readClass:r]||[self readProtocol:r]||[self readProp:r])) r.pos++;
    }
    [self readComments:r fromIndex:posWas toBeforeIndex:-1];
}

- (void)read:(WReader *)r {
    [self read:r logContext:nil];
}
- (void)read:(WReader *)r logContext:(InFiles*)alogContext {
    WClass *cwas=self.classContext;
    NSMutableDictionary *settingsWere=self.settingsContext;
    NSMutableArray *pwas=self.propertyContexts;
    NSMutableIndexSet *pbwas=self.propertyContextBrackets;
    NSMutableArray *plwas=self.propertyContextLineis;
    Int cbwas=self.classContextBracket;
    Int clwas=self.classContextLinei;

    self.settingsContext=NSMutableDictionary.dictionary;
    self.classContext=nil;
    self.classContextBracket=0;
    self.classContextLinei=-1;
    self.propertyContexts=[NSMutableArray array];
    self.propertyContextBrackets=[NSMutableIndexSet indexSet];
    self.propertyContextLineis=[NSMutableArray array];

    InFiles *logContextWas=self.logContext;
    if (alogContext) {
        while (alogContext.useLocationsFrom) alogContext=alogContext.useLocationsFrom;
        self.logContext=alogContext;
    }
    
    [self readKeepingContext:r];
    
    self.logContext=logContextWas;

    self.settingsContext=settingsWere;
    self.classContext=cwas;
    self.propertyContexts=pwas;
    self.propertyContextBrackets=pbwas;
    self.propertyContextLineis=plwas;
    self.classContextBracket=cbwas;
    self.classContextLinei=clwas;
}




-(void)makeImportSets {
    if (madeImportSets) return;
    madeImportSets=YES;
    WClass *p=(self.protocols)[@"perclassdefn"];
    if (p) {
        for (NSString *fnnm in p.fns) {
            WFn *fn=(p.fns)[fnnm];
            NSString *s=[[fn.sigWithArgs substringFromIndex:1] stringByAppendingString:fn.sortedBody];
            for (NSString *cnm in self.classes) {
                WClass *c=(self.classes)[cnm];
                [ins_set_after_decl_decl addObject:[c localizeString:s]];
            }
        }
    }
    p=(self.protocols)[@"perprotocoldefn"];
    if (p) {
        for (NSString *fnnm in p.fns) {
            WFn *fn=(p.fns)[fnnm];
            NSString *s=[[fn.sigWithArgs substringFromIndex:1] stringByAppendingString:fn.sortedBody];
            for (NSString *cnm in self.protocols) {
                WClass *c=(self.protocols)[cnm];
                [ins_set_after_decl_decl addObject:[c localizeString:s]];
            }
        }
    }
    for (NSString *cnm in self.classes) {
        WClass *c=(self.classes)[cnm];
        for (NSString *fnnm in c.fns) {
            WFn *fn=(c.fns)[fnnm];
            if ([fn.sigWithArgs hasPrefix:@"-"]) {
                NSString *nameUsed=nil;
                NSMutableSet *ss=([fn.sigWithArgs isEqualToString:@"-"]?ins_set_after_decl_decl:[self importsSetWithName:[fn.sigWithArgs substringFromIndex:1] nameUsed:&nameUsed]);
                if (ss) {
                    [ss addObject:[c localizeString:fn.sortedBody]];
                }
            }
        }
    }
    for (NSString *cnm in self.protocols) {
        WClass *c=(self.protocols)[cnm];
        for (NSString *fnnm in c.fns) {
            WFn *fn=(c.fns)[fnnm];
            if ([fn.sigWithArgs hasPrefix:@"+"]) {
                NSString *nameUsed=nil;
                NSMutableSet *ss=([fn.sigWithArgs isEqualToString:@"+"]?ins_set_after_decl_decl:[self importsSetWithName:[fn.sigWithArgs substringFromIndex:1] nameUsed:&nameUsed]);
                if (ss) {
                    [ss addObject:[c localizeString:fn.sortedBody]];
                }
            }
        }
    }
    
}




- (void)addToFns {
    [WClass getProtocolWithName:@"Object"].hasDef=YES;
    [WClass getProtocolWithName:@"DerivedObject"].hasDef=YES;
    [WClass getProtocolWithName:@"ClassObject"].hasDef=YES;
    for (WClass *clas in self.classes.allValues) [clas addClassToFns];
    for (WClass *clas in self.protocols.allValues) [clas addProtocolToFns];
}

- (NSString*)appendObjCToString:(NSMutableString*)_s iface:(bool)iface impl:(bool)impl classFilename:(NSString*)cfn headerFilename:(NSString*)hfn {
    finishedParse=YES;
    [self addToFns];

    [self makeImportSets];
    [self finalizeAllImports];

    NSString *ins_first=(impl?([cfn isEqualToString:@"inserts"]?self.ins_first_impl:@""):(iface?self.ins_first_iface:self.ins_first_decl));
    NSString *ins_after_imports=(impl?([cfn isEqualToString:@"inserts"]?self.ins_after_imports_impl:@""):(iface?self.ins_after_imports_iface:self.ins_after_imports_decl));
    NSString *ins_after_structs=(impl?([cfn isEqualToString:@"inserts"]?self.ins_after_structs_impl:@""):(iface?self.ins_after_structs_iface:self.ins_after_structs_decl));
    NSString *ins_after_decl=(impl?([cfn isEqualToString:@"inserts"]?self.ins_after_decl_impl:@""):(iface?self.ins_after_decl_iface:self.ins_after_decl_decl));
    NSString *ins_after_protocols=(impl?([cfn isEqualToString:@"inserts"]?self.ins_after_protocols_impl:@""):(iface?self.ins_after_protocols_iface:self.ins_after_protocols_decl));
    NSString *ins_after_ifaces=(impl?([cfn isEqualToString:@"inserts"]?self.ins_after_ifaces_impl:@""):(iface?self.ins_after_ifaces_iface:self.ins_after_ifaces_decl));
    NSString *ins_last=(impl?([cfn isEqualToString:@"inserts"]?self.ins_last_impl:@""):(iface?self.ins_last_iface:self.ins_last_decl));
    NSString *ins_each_class=(impl?self.ins_each_impl:@"");

    NSMutableString *s=[NSMutableString stringWithString:ins_first];



    NSArray *cs=[self.classes.allValues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        WClass *c1=(WClass*)obj1,*c2=(WClass*)obj2;
        Int d1=c1.depth,d2=c2.depth;
//        Int d1=0,d2=0;
        return(d1<d2?NSOrderedAscending:(d1>d2?NSOrderedDescending:[c1.name compare:c2.name options:NSCaseInsensitiveSearch]));
    }];
    NSArray *ps=[self.protocols.allValues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        WClass *c1=(WClass*)obj1,*c2=(WClass*)obj2;
        Int d1=c1.depth,d2=c2.depth;
//        Int d1=0,d2=0;
        return(d1<d2?NSOrderedAscending:(d1>d2?NSOrderedDescending:[c1.name compare:c2.name options:NSCaseInsensitiveSearch]));
    }];


    Int myClassCount=0;

    if (impl) {
        for (WClass *c in cs) if (c.exists&&((!cfn)||[cfn isEqualToString:c.filename])&&!(c.isType||c.empty)) {
            myClassCount++;
        }
        if (myClassCount) {
            [s appendFormat:@"\n\n#pragma mark -\n#pragma mark Interfaces:\n#ifdef INCLUDE_IFACE\n\n"];
            Int depthWas=-1;
            for (WClass *c in cs) if (c.exists&&((!cfn)||[cfn isEqualToString:c.filename])&&!(c.isType||c.empty)) {
                Int depth=c.depth;
                if (depthWas!=depth) {
                    if (depthWas!=-1) {
                        [s appendFormat:@"#endif // INCLUDE_IFACE_D%d\n\n",(int)depthWas];
                    }
                    depthWas=depth;
                    [s appendFormat:@"#ifdef INCLUDE_IFACE_D%d\n",(int)depth];
                    [s appendString:SPACER];
                }

                [c appendObjCToString_iface:s];
                [s appendString:SPACER];
            }
            if (depthWas!=-1) {
                [s appendFormat:@"#endif // INCLUDE_IFACE_D%d\n\n",(int)depthWas];
            }
            [s appendFormat:@"#else // INCLUDE_IFACE\n\n"];
            [s appendString:SPACER];
        }
    }






    if (impl&&(hasErrors||hasWarnings)) {
        [s appendString:@"static void __wi__warner() {\n"];
        if (hasErrors) [s appendString:@"  wi_reported_errors=1;\n"];
        if (hasWarnings) [s appendString:@"  Int wi_reported_warnings=1;\n"];
        [s appendString:@"}\n\n"];
    }
    
    if (iface) {
        for (NSString __strong*incl in self.incls) {
            if (incl) {
                if ([incl hasPrefix:@"\"include:"]) [s appendFormat:@"#include \"%@\n",[incl substringFromIndex:@"\"include:".length]];
                else if ([incl hasPrefix:@"<include:"]) [s appendFormat:@"#include <%@\n",[incl substringFromIndex:@"<include:".length]];
                else if ([incl hasPrefix:@"include:"]) [s appendFormat:@"#include %@\n",[incl substringFromIndex:@"include:".length]];
                else [s appendFormat:@"#import %@\n",incl];
            }
        }
        if (self.incls.count) [s appendString:SPACER];
    }
    if (hfn) [s appendFormat:@"#include \"%@\"\n",hfn];
    
    if (ins_after_imports.length) {
        [s appendString:ins_after_imports];
        [s appendString:SPACER];
        [s appendString:SPACER];
    }

    Int classCount=0,typeCount=0;


    for (WClass *c in ps) if (iface&&c.exists&&!c.isSys) [s appendFormat:@"@protocol %@;\n",c.name];
    for (WClass *c in cs) if (iface&&c.exists&&!(c.isType||c.isSys)) [s appendFormat:@"@class %@;\n",c.name];
    

    for (Int depth=-2;depth<=2;depth++) {
        for (WClass *c in cs) {
        //            if ([c.name isEqualToString:@"CommitStage"]) printf("CS %s %s %s\n",c.name.UTF8String,c.vars.description.UTF8String,c.varPatterns.description.UTF8String);
            if (c.isType&&(!c.vars.count)&&(c.varPatterns.count>=1)) {
                bool first=YES;
                for (NSString *p in c.varPatterns) {
                    if (iface) {
                    if (c.isBlock) {
                    }
                        NSString *typedefPrefix=(c.isBlock?(first&&!depth?@"":nil):(depth?[NSString stringWithFormat:@"typedef@%d:",(int)depth]:@"typedef:"));
                        if (typedefPrefix&&((!typedefPrefix.length)||[p hasPrefix:typedefPrefix])) {
                            NSString *t=[p substringFromIndex:typedefPrefix.length];
                            NSError *err=nil;
                            NSRegularExpression *regex=[NSRegularExpression regularExpressionWithPattern:@"(?s)^\\s*+(.*?)\\s*+((?:\\[\\s*+\\d++\\s*+(?:,\\s*+\\d++\\s*+)*+\\])?+)\\s*+$" options:0 error:&err];
                            NSTextCheckingResult *match = [regex firstMatchInString:t options:0 range:NSMakeRange(0, t.length)];
                            if (match) {
                                NSRange r=[t rangeOfString:@"__type__"];
                                if (r.location!=NSNotFound) {
                                    [s appendFormat:@"typedef %@ %@;\n",[[t substringWithRange:[match rangeAtIndex:1]] stringByReplacingCharactersInRange:r withString:c.name],[t substringWithRange:[match rangeAtIndex:2]]];
                                }
                                else {
                                    [s appendFormat:@"typedef %@ %@%@;\n",[t substringWithRange:[match rangeAtIndex:1]],c.name,[t substringWithRange:[match rangeAtIndex:2]]];
                                }
                            }
                            break;
                        }
                    }
                    first=NO;
                }
            }
        }
    }
    for (WClass *c in cs) if (c.exists) {
        if (!(c.isType||c.isSys)) classCount++; else if (c.vars.count) typeCount++;
    }

    [s appendString:SPACER];
    if (ins_after_decl.length) {
        [s appendString:ins_after_decl];
        [s appendString:SPACER];
        [s appendString:SPACER];
    }
    
    
        
    
    if (iface) {
        if (typeCount) {
            [s appendFormat:@"\n\n#pragma mark -\n#pragma mark Structs:\n\n"];
            for (WClass *c in cs) if (c.isType&&c.vars.count) [c appendObjCToString_struct:s];
            [s appendString:SPACER];
        }
    }

    if (ins_after_structs.length) {
        [s appendString:ins_after_structs];
        [s appendString:SPACER];
        [s appendString:SPACER];
    }

    if (iface) {
        if (ps.count) {
            [s appendFormat:@"\n\n#pragma mark -\n#pragma mark Protocols:\n\n"];
            for (WClass *c in ps) if (c.exists) {
                [c appendObjCToString_protocol:s];
                [s appendString:SPACER];
            }
            [s appendString:SPACER];
        }
    }

    if (ins_after_protocols.length) {
        [s appendString:ins_after_protocols];
        [s appendString:SPACER];
        [s appendString:SPACER];
    }

    if (iface) {
        if (classCount) {
            NSMutableDictionary *depths=NSMutableDictionary.dictionary;

            for (WClass *c in cs) if (c.exists&&!(c.isType||c.empty)) {
                Int depth=c.depth;
                if (!depths[@(depth)]) depths[@(depth)]=NSMutableSet.set;
                [((NSMutableSet*)depths[@(depth)]) addObject:c.filename];
            }
            NSArray *depthsa=[depths.allKeys sortedArrayUsingSelector:@selector(compare:)];

            [s appendFormat:@"\n\n#pragma mark -\n#pragma mark Include interfaces:\n#define INCLUDE_IFACE\n\n"];

            for (NSNumber *depth in depthsa) {
                [s appendFormat:@"#pragma mark -\n#pragma mark Include interfaces:\n#define INCLUDE_IFACE_D%d\n",depth.intValue];
                NSArray *fns=[((NSSet*)depths[depth]).allObjects sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
                for (NSString *fn in fns) {
                    [s appendFormat:@"    #include \"%@.mm\"\n",fn];
                }
                [s appendFormat:@"#undef INCLUDE_IFACE_D%d\n\n",depth.intValue];
            }
            [s appendFormat:@"#undef INCLUDE_IFACE\n\n"];
            [s appendString:SPACER];
        }
    }

    if (ins_after_ifaces.length) {
        [s appendString:ins_after_ifaces];
        [s appendString:SPACER];
        [s appendString:SPACER];
    }
        
    if (impl) {
        if (classCount) {
            cs=[self.classes.allValues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    WClass *c1=(WClass*)obj1,*c2=(WClass*)obj2;
                    //Int d1=c1.depth,d2=c2.depth;
                    Int d1=0,d2=0;
                    return(d1<d2?NSOrderedAscending:(d1>d2?NSOrderedDescending:[c1.name compare:c2.name options:NSCaseInsensitiveSearch]));
                }];
            [s appendFormat:@"\n\n#pragma mark -\n#pragma mark Implementations:\n\n"];
            unichar fl=0;
            for (WClass *c in cs) if (c.exists&&((!cfn)||[cfn isEqualToString:c.filename])&&!(c.isType||c.empty)) {
                unichar fl2=[c.name.lowercaseString characterAtIndex:0];
                if (fl2!=fl) {
                    [s appendFormat:@"%@// !!!: Implementations: %C\n%@%@",SPACER,fl2,SPACER,SPACER];
                    fl=fl2;
                }
                [s appendString:[c localizeString:ins_each_class]];
                [c appendObjCToString_impl:s];
                [s appendString:SPACER];
            }
            [s appendString:SPACER];
        }
    }
        
    if (ins_last.length) {
        [s appendString:ins_last];
        [s appendString:SPACER];
    }

    if (impl&&myClassCount) [s appendFormat:@"#endif // INCLUDE_IFACE\n"];

        
    NSMutableString *ret=nil;
    //NSDate *date=[NSDate date];
    [_s appendFormat:@"//WInterface autogenerated this file. HaND\n\n"];
    if (self.taskList.count) {
        ret=[NSMutableString string];
        [_s appendString:@"//Tasks:\n"];
        for (NSString *task in self.taskList) {
            [_s appendFormat:@"//    %@\n",task];
            if ([task hasPrefix:@"// !!!:"]||[task hasPrefix:@"// ???:"]) [ret appendFormat:@"%@\n",task];
        }
        [_s appendString:@"\n\n"];
    }
    [_s appendString:s];
    return(ret.length?ret:nil);
}


- (WClass*)classForName:(NSString*)name {
    for (WClass *clas in self.classes.allValues) if (!clas.isProtocol) {
        for (NSString *patt in clas.varPatterns) {
            NSError *err=nil;
            NSRegularExpression *re=[NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"^%@$",patt] options:0 error:&err];
            if (re&&(!err)&&([re rangeOfFirstMatchInString:name options:0 range:NSMakeRange(0, name.length)].location!=NSNotFound)) {
                return(clas);
            }
        }
    }
    return(nil);
}



+ (void)_note:(NSString *)n withToken:(WReaderToken *)t context:(InFiles*)ctxt aggregatePattern:(NSString*)agg {

    while (ctxt.useLocationsFrom) ctxt=ctxt.useLocationsFrom;
    
     WClasses *cs=[WClasses getDefault];
     NSString *fn=t.tokenizer.reader.filePath;
     if (fn&&((!cs.taskFn)||![cs.taskFn isEqualToString:fn])) {
        [[WClasses getDefault].taskList addObject:@""];
        [[WClasses getDefault].taskList addObject:[NSString stringWithFormat:@"[%@]",cs.taskFn=fn]];
    }
    
    
    
    //n=(r?
    //    [NSString stringWithFormat:@"   %@  at  %@",[n stringByReplacingOccurrencesOfString:@"\n" withString:@"   "],[r.localString stringByReplacingOccurrencesOfString:@"\n" withString:@"   "]]:
    //   [NSString stringWithFormat:@"   %@",[n stringByReplacingOccurrencesOfString:@"\n" withString:@"   "]]);
    n=[n stringByReplacingOccurrencesOfString:@"\n" withString:@"   "];


    
    if (ctxt||fn) {
        NSError *err=nil;
        NSString *agg2=[[NSRegularExpression escapedPatternForString:agg] stringByReplacingOccurrencesOfString:@"##" withString:@"(\\d++)"];
        NSRegularExpression *re=[NSRegularExpression regularExpressionWithPattern:agg2 options:0 error:&err];
        if (re) {
            NSUInteger match=NSNotFound;
            NSUInteger i=0,c=0;
            for (NSString *s in [WClasses getDefault].taskList) {
                NSTextCheckingResult *matches=[re firstMatchInString:s options:0 range:NSMakeRange(0, s.length)];
                if (matches) {
                    match=i;
                    c=[s substringWithRange:[matches rangeAtIndex:1]].intValue;
                    break;
                }
                else i++;
            }
            NSString *m=[agg stringByReplacingOccurrencesOfString:@"##" withString:[NSString stringWithFormat:@"%ld",c+1]];
            
            if (match==NSNotFound) {
                [[WClasses getDefault].taskList addObject:m];
            }
            else {
                ([WClasses getDefault].taskList)[match] = m;
            }
            if (fn) {
                [InFiles addInFilename:fn line:t.linei column:0 format:@"%@",n];
            }
            else if (ctxt) {
                [ctxt addInFilesMessageUsingFormat:@"%@",n];
            }
        }
        else {
            NSLog(@"Bad regex: %@",agg2);
            [[WClasses getDefault].taskList addObject:n];
        }
    }
    else {
        [[WClasses getDefault].taskList addObject:n];
    }
}


+ (void)error:(NSString *)err withToken:(WReaderToken *)t context:(InFiles*)ctxt {
     [WClasses _note:[NSString stringWithFormat:@"! Fix error: %@",err] withToken:t context:ctxt aggregatePattern:@"Fix ## embedded errors (look for \"!!!:WI:\" in the code)"];
    [WClasses getDefault].hasErrors=YES;
}
+ (void)warning:(NSString *)err withToken:(WReaderToken *)t context:(InFiles*)ctxt {
     [WClasses _note:[NSString stringWithFormat:@"? Address warning: %@",err] withToken:t context:ctxt aggregatePattern:@"Address ## embedded warnings (look for \"???:WI:\" in the code)"];
    [WClasses getDefault].hasWarnings=YES;
}
+ (void)note:(NSString *)n withToken:(WReaderToken *)t context:(InFiles*)ctxt {
     [WClasses _note:[NSString stringWithFormat:@" Note: %@",n] withToken:t context:ctxt aggregatePattern:@"Embedded ## notes (look for \"MARK:WI:\" in the code)"];
}




+(WType*)processClassType:(WType*)t class:(WClass*)clas protocols:(NSArray*)protocols tostars:(Int*)pstars {
    if (!t) return(nil);
    if (pstars) *pstars=0;
    WPotentialType *pt=[WPotentialType newWithType:t];
    //NSLog(@"Type from %@  (%@<%@>)",t.wiType,pt.clas,pt.protocols.description);
    NSMutableSet *ps=[NSMutableSet set];
    if (pt.clas) {
        NSMutableString *s=[WClasses processClassString:pt.clas class:clas protocols:protocols].mutableCopy;
        while ([s hasSuffix:@"*"]) {
            if (pstars) (*pstars)++;
            [s deleteCharactersInRange:NSMakeRange(s.length-1,1)];
        }
        pt.clas=s;//!todo protcols
    }
    if (pt.protocols) {
        for (NSString *s in pt.protocols) [ps addObject:[WClasses processClassString:s class:clas protocols:protocols]];
        pt.protocols=ps;
    }
    else if (ps.count) pt.protocols=ps;
    
    WType *nt=[WType newWithPotentialType:pt];
    //NSLog(@"    >>> %@  (%@<%@>)",nt.wiType,pt.clas,pt.protocols.description);
    return(nt);
}

+(NSString*)processClassString:(NSString*)s reader:(WReader*)r {
    WProp *p=[[WClasses getDefault] enclosingPropNoSkip:r];
    WClass *clas=(p?p.hisclas:[[WClasses getDefault] enclosingClassNoSkip:r]);
    return([WClasses processClassString:s class:clas protocols:nil]);
}


+(NSString*)processClassString:(NSString*)s class:(WClass*)clas protocols:(NSArray*)protocols {
    if (protocols) {
        for (Int i=protocols.count-1;i>=0;i--) {
            WClass *p=(WClass*)protocols[i];
            if (p) s=[WClasses processClassString:s class:p protocols:nil];
        }
    }
    if (clas) {
        s=[WProp string:s replacePairs:
            @"__ClassOrProtocolName__",clas.name,
            @"__classOrProtocolName__",[WProp lowerName:clas.name],
            @"__WIClassOrProtocol__",(clas.isProtocol?[NSString stringWithFormat:@"<%@>",clas.name]:clas.name),
            @"__ClassOrProtocol__",[WType objCTypeWithClass:(clas.isProtocol?nil:clas) protocols:(clas.isProtocol?[NSSet setWithObject:clas]:nil) stars:-1],
            nil];
        NSRange r;
        for (NSString *kv in clas.varPatterns) if ((r=[kv rangeOfString:@"=>"]).location!=NSNotFound) {
            NSString *k=[kv substringToIndex:r.location],*v=[kv substringFromIndex:r.location+r.length];
            if (k.length) {
                if ([s rangeOfString:k].location!=NSNotFound) {
                    s=[s stringByReplacingOccurrencesOfString:k withString:v];
                }
                NSString *uk=[WProp __upperName:k];
                if ((![k isEqualToString:uk])&&([s rangeOfString:uk].location!=NSNotFound)) {
                    s=[s stringByReplacingOccurrencesOfString:uk withString:[WProp __upperName:v]];
                }
            }
        }
    }
    return(s);
}

@end




