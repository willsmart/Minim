


@implementation WFn
@synthesize sig,body,clas,sigWithArgs;
- (void)dealloc {
    self.sig=self.sigWithArgs=self.body=nil;
    self.clas=nil;
    }

+(NSString*)trimmedReplaceString:(NSString*)s {
    NSRange r=[s rangeOfString:@"__"];
    if (r.location!=NSNotFound) s=[s substringToIndex:r.location];
    return(s);
}

-(NSString*)sortedBody {
    return([self.class mergedBody:body with:@""]);
}

+(NSComparisonResult)compareName:(NSString*)n1 withName:(NSString*)n2 {
    NSRange r1=[n1 rangeOfString:@")"];
    if (r1.location==NSNotFound) r1.location=0;
    NSRange r2=[n2 rangeOfString:@")"];
    if (r2.location==NSNotFound) r2.location=0;
    NSComparisonResult res=[[n1 substringFromIndex:r1.location] compare:[n2 substringFromIndex:r2.location] options:NSCaseInsensitiveSearch];
    if ((res==NSOrderedSame)&&(r1.location||r2.location)) {
        res=[n1 compare:n2 options:NSCaseInsensitiveSearch];
    }
    return(res);
}
    

- (id)initWithSig:(NSString*)asig body:(NSString*)abody clas:(WClass*)aclas {
    if (!(self=[super init])) return(nil);
    dprnt("Fn : %s:%s\n",aclas.name.UTF8String,asig.UTF8String);
    asig=[asig stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.sigWithArgs=asig;
    self.sig=(self.imaginary?self.sigWithArgs:NSStringFromSelector(NSSelectorFromString(asig)));
    self.body=abody;
    ((self.clas=aclas).fns)[self.sig] = self;
    return(self);
}

- (bool) imaginary {
    NSString *asig=self.sigWithArgs;
    for (Int i=1;i<asig.length;i++) {
        if (![[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[asig characterAtIndex:i]]) {
            return([asig characterAtIndex:i]!='(');
        }
    }
    return(YES);
}

#define NONUMBER 0x80000000
+ (Int)tokenMergeNumber:(WReaderTokenizer*)tk pos:(NSUInteger)pos append:(bool*)pappend retNumTokens:(Int*)pnumTokens {
    if ((tk.tokens.count>=pos+1)&&[((WReaderToken*)(tk.tokens)[pos]).str isEqualToString:@"@"]) {
        NSUInteger p=pos+1;
        WReaderToken *t=(WReaderToken*)(tk.tokens)[p];
        bool append=([t.str isEqualToString:@"!"]?NO:YES);
        if (!append) t=(WReaderToken*)(tk.tokens)[++p];
        Int sgn=([t.str isEqualToString:@"-"]?-1:1);
        if (sgn==-1) t=(WReaderToken*)(tk.tokens)[++p];
        if (t.type=='n') {
            p++;
            Int N=atoi(t.str.UTF8String);
            if (pappend) *pappend=append;
            if (pnumTokens) *pnumTokens=(Int)(p-pos);
            return(N*sgn);
        }
    }
    return(NONUMBER);
}

+ (void)getFnBlocksFromString:(NSString*)str ret:(NSMutableArray*)ret pveIndexes:(NSMutableIndexSet*)pve nveIndexes:(NSMutableIndexSet*)nve forceIndexes:(NSMutableSet*)forceIndexes {
    WReaderTokenizer *tk=[[WReaderTokenizer alloc] initWithReader:nil];
    tk.str=str;
    Int n=0,sn=NONUMBER;
    NSMutableString *s=nil;
    bool append=YES,ignore=NO;
    for (NSUInteger pos=0;pos<tk.tokens.count;pos++) {
        WReaderToken *t=(tk.tokens)[pos];
        Int numTokens;
        Int tki=[WFn tokenMergeNumber:tk pos:pos append:&append retNumTokens:&numTokens];
        if (tki!=NONUMBER) {
            pos+=numTokens-1;
            n=tki;
            continue;
        }
        else if (sn!=n) {
            if ([forceIndexes containsObject:@(n)]) ignore=YES;
            else {
                ignore=NO;
                sn=n;
                if (n<0) {
                    Int i=0,j;
                    for (j=(Int)nve.lastIndex;(j!=NSNotFound)&&(-j<n);j=(Int)[nve indexLessThanIndex:j],i++);
                    if (-j==n) s=ret[i];
                    else {
                        [ret insertObject:s=[NSMutableString string] atIndex:i];
                        [nve addIndex:-n];
                    }
                }
                else {
                    Int i=(Int)nve.count,j;
                    for (j=(Int)pve.firstIndex;(j!=NSNotFound)&&(j<n);j=(Int)[pve indexGreaterThanIndex:j],i++);
                    if (j==n) s=ret[i];
                    else {
                        [ret insertObject:s=[NSMutableString string] atIndex:i];
                        [pve addIndex:n];
                    }
                }
            }
        }
        if (!ignore) {
            if (!append) {
                [forceIndexes addObject:@(sn)];
                append=YES;
                [s setString:t.str];
            }
            else [s appendString:t.str];
        }
        
    }
}
+ (NSString*)mergedBody:(NSString*)a with:(NSString*)b {
    NSMutableArray *ss=[NSMutableArray array];
    NSMutableIndexSet *pve=[NSMutableIndexSet indexSet],*nve=[NSMutableIndexSet indexSet];
    NSMutableSet *force=[NSMutableSet set];
    [WFn getFnBlocksFromString:a ret:ss pveIndexes:pve nveIndexes:nve forceIndexes:force];
    [WFn getFnBlocksFromString:b ret:ss pveIndexes:pve nveIndexes:nve forceIndexes:force];
    Int i=0;
    NSMutableString *ret=[NSMutableString string];
    for (Int j=(Int)nve.lastIndex;j!=NSNotFound;j=(Int)[nve indexLessThanIndex:j]) {
        NSString *s=ss[i++];
        if (s.length) [ret appendFormat:@"@%@%d %@",[force containsObject:@(-j)]?@"!":@"",(int)-j,s];
    }
    for (Int j=(Int)pve.firstIndex;j!=NSNotFound;j=(Int)[pve indexGreaterThanIndex:j]) {
        NSString *s=ss[i++];
        if (s.length) {
            if (ret.length||j) [ret appendFormat:@"@%@%d %@",[force containsObject:@(j)]?@"!":@"",(int)j,s];
            else [ret appendFormat:@"%@",s];
        }
    }
    return(ret);
}

+ (WFn*)getExistingFnWithSig:(NSString *)asig clas:(WClass *)aclas {
    NSString *sig=NSStringFromSelector(NSSelectorFromString(asig));
    return((aclas.fns)[sig]);
}

+ (WFn*)getFnWithSig:(NSString*)asig body:(NSString*)abody clas:(WClass*)aclas {
    NSString *sig=NSStringFromSelector(NSSelectorFromString(asig));
    WFn *ret=(aclas.fns)[sig];
    if (!ret) return([[WFn alloc] initWithSig:asig body:abody clas:aclas]);

    ret.sigWithArgs=asig;
    if (abody) {
        if (ret.body) ret.body=[ret.body stringByAppendingFormat:@"@0\n%@",abody];//[WFn mergedBody:ret.body with:abody];
        else ret.body=abody;
    }
    return(ret);
}


- (NSString*)finalSigStr:(NSString*)asig {
    asig=[asig stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange r=NSMakeRange(NSNotFound,0);
    if ([asig isEqualToString:@"-(init)"]) {
        if (clas.isProtocol) return(nil);
        asig=@"-(void)_startObjectOfClass__WIClass__";
    }
    else if ([asig hasPrefix:@"-(init)"]||([asig hasPrefix:@"-(init["]&&((r=[asig rangeOfString:@"])"]).location!=NSNotFound))) {
        NSUInteger st=(r.location==NSNotFound?@"-(init)".length:(r.location+2));
        asig=[@"-(__Class__*)" stringByAppendingString:[asig substringFromIndex:st]];
    }
    if (asig.length&&(([asig characterAtIndex:0]=='-')||([asig characterAtIndex:0]=='+'))) {
        NSString *asig2=[NSString stringWithFormat:@"[self%@]",[asig substringFromIndex:1]];
        asig2=[self bodyByReplacingSettersAndGettersInBody:asig2];
        asig=[NSString stringWithFormat:@"%c%@",[asig characterAtIndex:0],[asig2 substringWithRange:NSMakeRange(5, asig2.length-6)]];
    }
    return([WProp string:asig replacePairs:
        @"__ClassName__",clas.name,
        @"__className__",[WProp lowerName:clas.name],
        @"__WIClass__",(clas.isProtocol?[NSString stringWithFormat:@"<%@>",clas.name]:clas.name),
        @"__Class__",[WType objCTypeWithClass:(clas.isProtocol?nil:clas) protocols:(clas.isProtocol?[NSSet setWithObject:clas]:nil) stars:-1],
        nil]);
}

+(NSString*)balance:(NSString*)s {
    Int depth=1;
    WReaderTokenizer *tkn=[[WReaderTokenizer alloc] initWithReader:nil];
    tkn.str=s;
    bool wasnl=YES,wasmk=NO;
    Int level;
    for (Int i=0;i<tkn.tokens.count;i++) {
        WReaderToken *t=(tkn.tokens)[i];
        Int numTokens;
        if (wasnl) {
            NSMutableString *s=[NSMutableString string];
            for (Int d=0;d<MIN(40,depth);d++) [s appendString:@"  "];
            if (t.type!='r') {
                if (t.type=='z') t.str=s;
                else [tkn.tokens insertObject:[[WReaderToken alloc] initWithTokenizer:tkn string:s bracketCount:t.bracketCount linei:t.linei type:'z'] atIndex:i];
                wasnl=NO;
            }
        }
        else if (wasmk) {
            if ((t.type=='z')||(t.type=='r')) {
                [tkn.tokens removeObjectAtIndex:i--];
            }
            else if ((level=[WFn tokenMergeNumber:tkn pos:i append:nil retNumTokens:&numTokens])!=NONUMBER) {
                [tkn.tokens removeObjectsInRange:NSMakeRange(i-1,numTokens+1)];i--;
                [tkn.tokens insertObject:[[WReaderToken alloc] initWithTokenizer:tkn string:[NSString stringWithFormat:@"/*i%d*/",(int)level] bracketCount:t.bracketCount linei:t.linei type:'c'] atIndex:i];
            }
            else {
                wasmk=NO;
            }
        }
        else if (t.type=='r') {wasnl=YES;wasmk=NO;}
        else if ((level=[WFn tokenMergeNumber:tkn pos:i append:nil retNumTokens:&numTokens])!=NONUMBER) {
            [tkn.tokens removeObjectsInRange:NSMakeRange(i,numTokens)];
            NSMutableString *s=[NSMutableString string];
            for (Int d=0;d<MIN(40,depth);d++) [s appendString:@"  "];
            [tkn.tokens insertObject:[[WReaderToken alloc] initWithTokenizer:tkn string:@"\n" bracketCount:t.bracketCount linei:t.linei type:'r'] atIndex:i++];
            [tkn.tokens insertObject:[[WReaderToken alloc] initWithTokenizer:tkn string:s bracketCount:t.bracketCount linei:t.linei type:'z'] atIndex:i++];
            [tkn.tokens insertObject:[[WReaderToken alloc] initWithTokenizer:tkn string:[NSString stringWithFormat:@"/*i%d*/",(int)level] bracketCount:t.bracketCount linei:t.linei type:'c'] atIndex:i];
            wasmk=YES;wasnl=NO;
        }
        else {
            if ([t.str isEqualToString:@"{"]||[t.str isEqualToString:@"["]||[t.str isEqualToString:@"("]) depth++;
            else if ([t.str isEqualToString:@"}"]||[t.str isEqualToString:@"]"]||[t.str isEqualToString:@")"]) depth=MAX(0,depth-1);
            wasnl=wasmk=NO;
        }
    }
    NSMutableString *ret=[NSMutableString string];
    for (WReaderToken *t in tkn.tokens) [ret appendString:t.str];
    return(ret);
}


- (NSString*)finalBodyStr:(NSString*)abody withSig:(NSString*)asig {
    asig=[asig stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange r=NSMakeRange(NSNotFound,0);
    if ([asig isEqualToString:@"-(init)"]) {
        if (clas.isProtocol) return(nil);
    }
    else if ([asig hasPrefix:@"-(init)"]||([asig hasPrefix:@"-(init["]&&((r=[asig rangeOfString:@"])"]).location!=NSNotFound))) {
        NSString *sup;
        if (r.location==NSNotFound) sup=[NSString stringWithFormat:@"[super %@]",[asig substringFromIndex:@"-(init)".length]];
        else sup=[asig substringWithRange:NSMakeRange(@"-(init".length, r.location+1-@"-(init".length)];
        abody=[WFn mergedBody:[NSString stringWithFormat:@"@!-10001 if (!(self=%@)) return(nil);\n@11 [self _startObjectOfClass__WIClass__];\n@!10001 return(self);",sup] with:abody];
    }
    NSMutableString *s=abody.mutableCopy;
    NSError *err=nil;
    WClass *sup;
    for (sup=self.clas.superType.clas;sup&&!sup.exists;sup=sup.superType.clas);
    bool supIsWI=(sup&&!sup.isSys);
    
    [[NSRegularExpression regularExpressionWithPattern:@"__WIDerived__>>>(.*?)<<<" options:0 error:&err] replaceMatchesInString:s options:0 range:NSMakeRange(0, s.length) withTemplate:(supIsWI?@"$1":@"")];
    [[NSRegularExpression regularExpressionWithPattern:@"__WIBase__>>>(.*?)<<<" options:0 error:&err] replaceMatchesInString:s options:0 range:NSMakeRange(0, s.length) withTemplate:(!supIsWI?@"$1":@"")];
    s=[self bodyByReplacingSettersAndGettersInBody:[WFn mergedBody:s with:@""]].mutableCopy;
    return([WFn balance:[WProp string:s replacePairs:
        @"__ClassName__",clas.name,
        @"__className__",[WProp lowerName:clas.name],
        @"__WIClass__",(clas.isProtocol?[NSString stringWithFormat:@"<%@>",clas.name]:clas.name),
        @"__Class__",[WType objCTypeWithClass:(clas.isProtocol?nil:clas) protocols:(clas.isProtocol?[NSSet setWithObject:clas]:nil) stars:-1],
        nil]]);
}
- (bool)invalidProtocolFunction {
    return(clas.isProtocol&&(
        ([self.sigWithArgs isEqualToString:@"-(init)"]||
            ([self.sigWithArgs rangeOfString:@"__WIClass__"].location!=NSNotFound)||
            ([self.sigWithArgs rangeOfString:@"__Class__"].location!=NSNotFound))));
}

- (void)appendObjCToString_iface:(NSMutableString*)s {
    if (self.imaginary||[self invalidProtocolFunction]) return;
    [s appendFormat:@"%@;\n",[self finalSigStr:self.sigWithArgs]];
}
- (void)appendObjCToString_impl:(NSMutableString*)s {
    if (self.imaginary||[self invalidProtocolFunction]) return;
    if (self.body) {
        [s appendFormat:@"%@ {%@%@}\n",[self finalSigStr:self.sigWithArgs],
            ([clas.varPatterns containsObject:@"notrace"]?@"":
                [NSString stringWithFormat:@"MSGSTART(\"%@:%@\")\n",
                    clas.wType.wiType,
                    [self finalSigStr:self.sigWithArgs]
                ]
            ),
            [self finalBodyStr:self.body withSig:self.sigWithArgs]
        ];
    }
    else [[WClasses getDefault].taskList addObject:[NSString stringWithFormat:@"Need to implement %@ :: %@",self.clas.name,self.sig]];
}




-(NSString*)bodyByReplacingSettersAndGettersInBody:(NSString*)abody {
    return(abody);
    /*
    if (!abody) return(nil);
    
    if (![self.sig hasPrefix:@"-"]) return(abody);
    
    NSRegularExpression *gsre=clas.getterSetterRE;

    if (![gsre firstMatchInString:abody options:0 range:NSMakeRange(0, abody.length)]) return(abody);

    WReader *r=[[WReader alloc] init];
    r.fileString=abody;
    [r.tokenizer addSelectorTokens];

    bool changed=NO;
    
    NSMutableString *ps=[NSMutableString string];
    NSMutableString *seencolon=[NSMutableString string];
    NSString *bs=@"";
    
    bool issel=NO;
    Int bad=0,pos=-1;
    bool maybearg=NO;
    
    //for (WReaderToken *t in r.tokenizer.tokens) printf("%c:notes:\"%s\":str:\"%s\" --",t.type, t.notes.UTF8String,t.str.UTF8String);printf("\n");
    for (WReaderToken *t in r.tokenizer.tokens) {
        pos++;
        bool maybearg2=NO;
        
                //NSLog(@"%c %d \"%@\" \"%@\" \"%@\"",t.type,maybearg,t.str,ps,bs);
        switch (t.type) {
            case '[':issel=YES;break;
            case '(':{
                bs=t.notes;
                WReaderToken *t2=[r.tokenizer.tokens objectAtIndex:pos+1];
                switch ([t2.str characterAtIndex:0]) {
                    case '(':case '{':case '[':[ps appendString:(issel?@"[":@"x")];[seencolon appendString:@"n"];break;
                    case ')':case '}':case ']':maybearg2=YES;[ps deleteCharactersInRange:NSMakeRange(ps.length-1, 1)];[seencolon deleteCharactersInRange:NSMakeRange(seencolon.length-1,1)];break;
                }
                issel=NO;
                //NSLog(@"%@ \"%@\"",ps,bs);
            }
            break;
            case 'o':
            switch ([t.str characterAtIndex:0]) {
                case ')':case '}':case ']':maybearg2=maybearg;break;
            }
            
            if (seencolon.length&&[t.str isEqualToString:@":"]) [seencolon replaceCharactersInRange:NSMakeRange(seencolon.length-1,1)withString:@"Y"];
            
            if ([t.str isEqualToString:@"."]) bad=1;
            else if ([t.str isEqualToString:@"-"]) bad=-1;
            else if ([t.str isEqualToString:@">"]&&(bad==-1)) bad=1;
            else if ([t.str isEqualToString:@"@"]) bad=-2;
            else if ((bad==-3)&&[t.str isEqualToString:@"("]) bad=-4;
            //else if ([t.str isEqualToString:@")"]||[t.str isEqualToString:@"]"]) bad=1;
            else bad=0;
            break;
            case 'n':case 's':
                maybearg2=YES;
                bad=1;
                break;
            case 'z':case 'r':case 'c':
            maybearg2=maybearg;
            if ([t.str hasSuffix:@"ivar* /"]) {
                bad=1;
            }
            else if ((bad==-1)||(bad==-2)) bad=0;
            break;
            case 'w':
            maybearg2=YES;
            if (bad==-2) {
                bad=-3;
            }
            else if (bad==-4) {
                bad=1;
            }
            else if (bad<=0) do {
                bad=0;
                if (ps.length&&([ps characterAtIndex:ps.length-1]=='[')&&maybearg) {
                    bool isArg=NO;
                    for (Int pos2=pos+1;pos2<r.tokenizer.tokens.count;pos2++) {
                        WReaderToken *ta=[r.tokenizer.tokens objectAtIndex:pos2];
                        if ((ta.type=='o')&&([ta.str isEqualToString:@":"]||(([seencolon characterAtIndex:seencolon.length-1]=='n')&&[ta.str isEqualToString:@"]"]))) {
                            isArg=YES;break;
                        }
                        if (!((ta.type=='c')||(ta.type=='r')||(ta.type=='z')||(ta.type=='(')||(ta.type=='['))) break;
                    }
                    if (isArg) {maybearg2=NO;break;}
                }
                        
                WVar *v=nil;
                for (NSString *k in clas.vars) {
                    WVar *v2=[clas.vars objectForKey:k];
                    if ([t.str isEqualToString:v2.localizedName]) {v=v2;break;}
                }
                if (v) {
                    bool isSetter=NO,isGetter=YES,got=NO;Int setterEqPos=0;
                    for (Int pos2=pos+1;(pos2<r.tokenizer.tokens.count)&&!got;pos2++) {
                        WReaderToken *t2=[r.tokenizer.tokens objectAtIndex:pos2];
                        switch (t2.type) {
                            case 'o':
                                if ((isSetter=[t2.str isEqualToString:@"="])) {
                                    setterEqPos=pos2;
                                }
                                isGetter=(!isSetter)&&![t2.str isEqualToString:@"("];
                                got=YES;
                                break;
                            case 'w':case 'n':case 's':break;
                        }
                    }
                    bool isForSetterGetter=NO;
                    if (isSetter||isGetter) {
                        isForSetterGetter=([sig isEqualToString:v.localizedGetterSig]||[sig isEqualToString:v.localizedSetterSig]||[sig isEqualToString:v.getterSig]||[sig isEqualToString:v.setterSig]);
                    }
                    bool hasIVar=v.hasIVar;
                    if (isSetter) {
                        t.str=(isForSetterGetter?
                            (hasIVar?
                                [NSString stringWithFormat:@"/ *setter* /(*&%@)",v.localizedVarName]:
                                [NSString stringWithFormat:@" This is a Winterface issue, this property should be marked as having an ivar called %@ ",v.localizedVarName]):
                            (v.objc_readonly?
                                [NSString stringWithFormat:@"/ *readonly* /(*&%@)",v.localizedVarName]:
                                (v.readonly?
                                    [NSString stringWithFormat:@"/ *set* /privateaccess(self.%@",v.localizedName]:
                                    [NSString stringWithFormat:@"/ *set* /self.%@",v.localizedName]
                                )
                            )
                        );
                        changed=YES;
                        if ((!isForSetterGetter)&&(!v.objc_readonly)&&v.readonly) {
                            NSMutableArray *bs=[NSMutableArray array];
                            bool malformed=NO;
                            bool found=NO;
                            for (Int pos2=setterEqPos+1;(pos2<r.tokenizer.tokens.count);pos2++) {
                                WReaderToken *t=[r.tokenizer.tokens objectAtIndex:pos2];
                                if ((t.type=='z')||(t.type=='c')||(t.type=='r')) continue;
                                if ([t.str isEqualToString:@"["]) [bs addObject:@"[]"];
                                else if ([t.str isEqualToString:@"{"]) [bs addObject:@"{}"];
                                else if ([t.str isEqualToString:@"("]) [bs addObject:@"()"];
                                else if ([t.str isEqualToString:@"]"]) {
                                    if ((!bs.count)||![(NSString*)[bs lastObject] isEqualToString:@"[]"]) {malformed=YES;break;}
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
                                if ([t.str isEqualToString:@";"]&&!bs.count) {
                                    t.str=[@")" stringByAppendingString:t.str];
                                    found=YES;
                                    break;
                                }
                            }
                            if (!found) {
                                [WClasses error:[NSString stringWithFormat:@"Could not detect end of publicreadonly setter value, please surround it yourself with something like privateaccess(self.%@=...)",v.localizedName] withToken:nil context:self];
                            }
                        }
                    }
                            
                    
                    if (isGetter) {
                        t.str=(hasIVar?
                            (isForSetterGetter?
                                [NSString stringWithFormat:@"/ *getter* /(*&%@)",v.localizedVarName]:
                                [NSString stringWithFormat:@"/ *get* /(*&%@)",v.localizedVarName]):
                            [NSString stringWithFormat:@"/ *get* /self.%@",v.localizedName]);
                        changed=YES;
                    }
                }
            } while (NO);
            break;
        }
        maybearg=maybearg2;
    }
    NSString *ret=abody;
    if (changed) {
        ret=[r stringWithTokensInRange:NSMakeRange(0,r.tokenizer.tokens.count)];
    }
    return(ret);
    */
}





@end




