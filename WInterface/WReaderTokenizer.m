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
@synthesize type,bracketCount,tokenizer,_str;
- (void)dealloc {
    self.str=nil;
    [super dealloc];
}

- (id)initWithTokenizer:(WReaderTokenizer*)atokenizer string:(NSString*)astr bracketCount:(int)bc linei:(int)linei type:(char)atype {
    if (!(self=[super init])) return(nil);
    tokenizer=atokenizer;
    self.str=[astr.copy autorelease];
    self.type=atype;
    self.bracketCount=bc;
    self.linei=linei;
    return(self);
}

- (NSString *)str {
    if (self.tokenizer.tokenDelegate) return([self.tokenizer.tokenDelegate processedStringForString:self._str inToken:self]);
    else return(self._str);
}

- (void)setStr:(NSString *)v {self._str=v;}

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
        [s appendFormat:@"%c:%d:%d:\"%@\"\n",t.type,t.bracketCount,t.linei,t.str];
    }
    return(s);
}


@end
