//
//  WReaderTokenizer.m
//  WInterface
//
//  Created by Will Smart on 8/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WReaderTokenizer.h"
#import "WReader.h"


@implementation WReaderToken : NSObject
@synthesize type,bracketCount,tokenizer,_str,_notes;
- (void)dealloc {
    self.str=nil;
    self.notes=nil;
    [super dealloc];
}

- (id)initWithTokenizer:(WReaderTokenizer*)atokenizer string:(NSString*)astr bracketCount:(int)bc linei:(int)linei type:(char)atype {
    return([self initWithTokenizer:atokenizer string:astr bracketCount:bc linei:linei type:atype note:nil]);
}

- (id)initWithTokenizer:(WReaderTokenizer*)atokenizer string:(NSString*)astr bracketCount:(int)bc linei:(int)linei type:(char)atype note:(NSString*)anote {
    if (!(self=[super init])) return(nil);
    tokenizer=atokenizer;
    self.str=[astr.copy autorelease];
    self.notes=[NSString stringWithFormat:@"\a\a%c%p%@",atype,self,[astr stringByReplacingOccurrencesOfString:@"\a" withString:@"a"]];
    if (anote.length) [self addNote:@"%@",anote];
    self.type=atype;
    self.bracketCount=bc;
    self.linei=linei;
    return(self);
}

- (NSString *)str {
    if (self.tokenizer.tokenDelegate) return([self.tokenizer.tokenDelegate processedStringForString:self._str inToken:self]);
    else return(self._str);
}
-(NSString*)notes {return(self._notes);}

- (void)setStr:(NSString *)v {self._str=v;}
- (void)setNotes:(NSString *)v {self._notes=v;}


-(void)addNote:(NSString*)format,... {
    va_list args;va_start(args,format);
    self.notes=[self.notes stringByAppendingFormat:@"\a%@",[[[[NSString alloc] initWithFormat:format arguments:args] autorelease] stringByReplacingOccurrencesOfString:@"\a" withString:@"a"]];
    va_end(args);
}

@end


@implementation WReaderTokenizer : NSObject
@synthesize tokens,_str,tokenDelegate,reader;
- (void)dealloc {
    self.tokens=nil;
    self._str=nil;
    [super dealloc];
}

- (id)initWithReader:(WReader*)areader {
    if (!(self=[super init])) return(nil);
    self.reader=areader;
    self._str=@"";
    self.tokens=[NSMutableArray array];
    return(self);
}

- (NSString *)str {return(self._str);}
- (void)setStr:(NSString *)str {
    self._str=(str?[str.copy autorelease]:@"");
    char *mat[]={
        "     r  w  n  .  +  -  *  /  \\  Q  q  _  ? ",
        "z zz rr ww nn .o +o -o zo co zo qs ss ww zo",
        "r rr rr ww nn .o +o -o zo co zo qs ss ww zo",
        "w zz rr ww ww .o +o -o zo co zo qs ss ww zo",
        "n zz rr ww nn Nn zo zo zo co zo qs ss ww zo",
        "N zz rr ww Nn zo zo zo zo co zo qs ss ww zo",
        ". zz rr ww n< .o +o -o zo co zo qs ss ww zo",
        "+ zz rr ww n< .o +o -o zo co zo qs ss ww zo",
        "- zz rr ww n< .o +o -o zo co zo qs ss ww zo",
        "s ss ss ss ss ss ss ss ss ss Ss ss zs ss ss",
        "S ss ss ss ss ss ss ss ss ss ss ss ss ss ss",
        "q qs qs qs qs qs qs qs qs qs Qs zs qs qs qs",
        "Q qs qs qs qs qs qs qs qs qs qs qs qs qs qs",
        "c zz rr ww nn .o +o -o C< l< zo qs ss ww zo",
        "C bc bc bc bc bc bc bc bc Gc bc bc bc bc bc",
        "G bc bc bc bc bc bc bc gc bc bc bc bc bc bc",
        "g bc bc bc bc Ac bc bc Bc bc bc bc bc bc bc",
        "b bc bc bc bc bc bc bc Bc bc bc bc bc bc bc",
        "B bc bc bc bc bc bc bc Bc zc bc bc bc bc bc",
        "A bc bc bc bc ac bc bc Bc bc bc bc bc bc bc",
        "a bc bc bc bc Dc bc bc Bc bc bc bc bc bc bc",
        "D Dc Dc Dc Dc dc Dc Dc Dc Dc Dc Dc Dc Dc Dc",
        "d Dc Dc Dc Dc Ec Dc Dc Dc Dc Dc Dc Dc Dc Dc",
        "E Dc Dc Dc Dc ec Dc Dc Dc Dc Dc Dc Dc Dc Dc",
        "e Dc Dc Dc Dc ec Dc Dc Fc Dc Dc Dc Dc Dc Dc",
        "F Dc Dc Dc Dc Dc Dc Dc Dc zc Dc Dc Dc Dc Dc",
        "l lc rr lc lc lc lc lc lc lc lc lc lc lc lc"
    };
    int cols=14;
    int rows=26;

    int colForC[256];
    for (int _c=0;_c<256;_c++) {
        int c=(((_c>='a')&&(_c<='z'))||((_c>='A')&&(_c<='Z'))?'w':
               ((_c>='0')&&(_c<='9')?'n':
                (_c=='\"'?'Q':
                    (_c=='\''?'q':
                        (_c=='\n'?'r':_c)))));
        for (colForC[_c]=0;(colForC[_c]<cols-1)&&(mat[0][2+3*colForC[_c]]!=c);colForC[_c]++);
    }
    
    int rowForC[256];
    for (int _c=0;_c<256;_c++) {
        for (rowForC[_c]=0;(rowForC[_c]<rows-1)&&(mat[rowForC[_c]+1][0]!=_c);rowForC[_c]++);
        if (rowForC[_c]==rows) rowForC[_c]=-1;
    }

    char state='z';
    NSData *csd=[str dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    const char *cs=csd.bytes;
    
    NSMutableData *d=[NSMutableData dataWithLength:str.length];
    char *types=[d mutableBytes];
    
    //printf("%s\n",self.reader.fileName.UTF8String);
    int ci=0;
    while (ci<csd.length) {
        int col=colForC[cs[ci]];
        int row=rowForC[state];
        if (row<0) {NSLog(@"Unknown state %c",state);break;}
        types[ci]=mat[row+1][3+3*col];
        state=mat[row+1][2+3*col];
        //printf("%c%c%c:%d:%d:%d ",cs[ci],types[ci],state,ci,col,row);
        if (types[ci]=='<') ci--;
        else if (types[ci]!='.') ci++;
        
    }
    

    int typeWas=0,bc=0,linei=0,slinei=0,indent=0,_indent=0;
    [self.tokens removeAllObjects];
    NSMutableString *s=[NSMutableString string];
    for (ci=0;ci<str.length;ci++) {
        if (cs[ci]=='\n') _indent=0;
        else if ((_indent>=0)&&(cs[ci]==' ')) _indent++;
        else if (_indent>=0) {indent=_indent;_indent=-1;}
        if ((!ci)||((typeWas!='o')&&(types[ci]==typeWas))) {
            typeWas=types[ci];
            [s appendFormat:@"%c",[str characterAtIndex:ci]];
        }
        else {
            if ([s isEqualToString:@"}"]) bc--;
            if ((typeWas=='c')&&[s hasPrefix:@"/*"]&&((s.length<4)||![s hasSuffix:@"*/"])) [s appendString:@"*/"];
            [self.tokens addObject:[[[WReaderToken alloc] initWithTokenizer:self string:s bracketCount:bc+indent linei:slinei type:typeWas] autorelease]];
            if ([s isEqualToString:@"{"]) bc++;
            [s setString:@""];
            slinei=linei;
            [s appendFormat:@"%c",[str characterAtIndex:ci]];
            typeWas=types[ci];
        }
        if (cs[ci]=='\n') linei++;
    }
    if (s.length) {
        if ([s isEqualToString:@"}"]) bc--;
        [self.tokens addObject:[[[WReaderToken alloc] initWithTokenizer:self string:s bracketCount:bc linei:linei type:typeWas] autorelease]];
        if ((typeWas=='c')&&[s hasPrefix:@"//"]) {
            [self.tokens addObject:[[[WReaderToken alloc] initWithTokenizer:self string:@"\n" bracketCount:bc linei:linei type:'r'] autorelease]];
        }
    }
}

- (NSString*)tokenStr {
    NSMutableString *s=[NSMutableString string];
    for (WReaderToken *t in self.tokens) {
        [s appendString:t.notes];
    }
    [s appendString:@"\a\a"];
    return([s.copy autorelease]);
}

- (NSIndexSet*)tokenIndexSet {
    NSMutableIndexSet *ret=[NSMutableIndexSet indexSet];
    NSUInteger ind=0;
    for (WReaderToken *t in self.tokens) {
        [ret addIndex:ind];
        ind+=t.notes.length;
    }
    return([ret.copy autorelease]);
}


-(void)applyRegex:(NSString*)regex {
    NSString *str=self.tokenStr;
    NSIndexSet *inds=self.tokenIndexSet;
    
    RKRegex *re=[[[RKRegex alloc] initWithRegexString:regex options:0] autorelease];
    NSArray *refs=re.captureNameArray;
    RKEnumerator *en=[str matchEnumeratorWithRegex:re];

    NSRange *ranges;
    int seq=1;
    while ((ranges=[en nextRanges])) {
        int ind=-1;
        for (NSObject *_name in refs) {ind++;
            if (![_name isKindOfClass:[NSString class]]) continue;
            NSString *name=(NSString*)_name;
            
            NSRange r=ranges[ind];
            if (r.location+r.length<=str.length) {
                NSUInteger sti=[inds countOfIndexesInRange:NSMakeRange(0, r.location)]-1;
                NSUInteger endi=[inds countOfIndexesInRange:NSMakeRange(0, r.location+(r.length?r.length-1:0))]-1;
                if (sti==endi) {
                    [(WReaderToken*)[self.tokens objectAtIndex:sti] addNote:@"%@",name];
                }
                else {
                    [(WReaderToken*)[self.tokens objectAtIndex:sti] addNote:@"%d:%@",seq,name];
                    [(WReaderToken*)[self.tokens objectAtIndex:endi] addNote:@"%d",seq];
                    seq++;
                }
            }
        }
    }
}



-(void)addBracketTokens {
    [self applyRegex:@"(?'paran'\a\ao\\((?:(?>[^\(]*)|(?-2))*\a\ao\\))"];
    [self applyRegex:@"(?'squ'\a\ao\\[(?:(?>[^\(]*)|(?-2))*\a\ao\\])"];
    [self applyRegex:@"(?'curl'\a\ao\\{(?:(?>[^\(]*)|(?-2))*\a\ao\\})"];
}




-(void)addSelectorTokens {
/*
    if (addedSelectorTokens) return(NO);
    addedSelectorTokens=YES;
    [self addBracketTokens];
    
    NSString *bs=@"";
    NSMutableArray *newTokens=[NSMutableArray array];
    
    bool changed=NO;
    
    NSMutableArray *bsts=[NSMutableArray array];
    
    NSError *err=nil;
    NSRegularExpression *re=[NSRegularExpression regularExpressionWithPattern:
        @"^\\(*(\\(|\\[|w\\(?)((\\.|->)w)*w(:|$)"
        options:0 error:&err];

    if (err) NSLog(@"%@",err.description);
    
    for (int pos=0;pos<tokens.count;pos++) {
        WReaderToken *t=[tokens objectAtIndex:pos];
        
        char newc=0;
        NSMutableString *bs0=[bsts.lastObject isKindOfClass:[NSString class]]?bsts.lastObject:nil;
        
        switch (t.type) {
            case '(':
                bs=t.notes;
                WReaderToken *t2=[tokens objectAtIndex:pos+1];
                switch ([t2.str characterAtIndex:0]) {
                    case '[':[bsts addObject:[NSMutableString string]];newc='[';break;
                    case '{':case '(':[bsts addObject:[NSNull null]];newc='(';break;
                    case ']':
                        if ([bsts.lastObject isKindOfClass:[NSString class]]) {
                            NSString *p=bsts.lastObject;
                            //NSLog(@"%@ vs %@",p,re);
                            if ([re firstMatchInString:p options:0 range:NSMakeRange(0, p.length)]) {
                                NSUInteger ind;
                                for (ind=newTokens.count-1;;ind--) {
                                    WReaderToken *ts=[newTokens objectAtIndex:ind];
                                    if ((ts.type=='(')&&[ts.notes isEqualToString:[bs stringByAppendingString:@"["]]) {
                                        WReaderToken *ts2=[newTokens objectAtIndex:ind+1];
                                        if ([ts2.str isEqualToString:@"["]) {
                                            break;
                                        }
                                    }
                                }
                                //NSLog(@"y %ld",(long)ind);
                                changed=YES;
                                [newTokens insertObject:[[[WReaderToken alloc] initWithTokenizer:self string:@"" bracketCount:t.bracketCount linei:t.linei type:'[' note:@""] autorelease] atIndex:ind];
                            }
                        }
                    case ')':case '}':// note pass through
                        [bsts removeLastObject];
                        break;
                }
                break;
            case 'w':newc='w';break;
            case 'o':
                switch ([t.str characterAtIndex:0]) {
                    case '.':newc='.';break;
                    case '-':newc='-';break;
                    case '>':newc='>';break;
                    case ':':newc=':';break;
                }
                break;
            case 'n':case 's':newc='n';break;
        }
        if (newc&&bs0) {
            [bs0 appendFormat:@"%c",newc];
        }
        [newTokens addObject:t];
    }
    if (changed) [tokens setArray:newTokens];
    return(changed);
    */
}

@end
