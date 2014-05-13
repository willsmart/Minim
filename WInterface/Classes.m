//
//  Classes.m
//  WInterface
//
//  Created by Will Smart on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WReaderTokenizer.h"
#import "Classes.h"
#import "WReader.h"
#import <objc/runtime.h>

#define iNSNotFound ((int)NSNotFound)
#define SPACER @"\n\n\n\n\n\n\n\n\n"




@implementation InFiles
-(void)dealloc {
    }

@synthesize inFilesLocations,inFilesMessages,useLocationsFrom;

-(id)init {
    if (!(self=[super init])) return(nil);
    self.useLocationsFrom=[WClasses getDefault].logContext;
    inFilesLocations=[[NSMutableDictionary alloc] init];
    inFilesMessages=[[NSMutableArray alloc] init];
    [(NSMutableArray*)[InFiles allInFiles] addObject:self];
    return(self);
}


-(void)addInFilename:(NSString*)fn line:(int)line column:(int)column {
    if (!fn) {
        return;
    }
    NSMutableSet *s=[inFilesLocations objectForKey:fn];
    if (!s) [inFilesLocations setObject:s=[NSMutableSet set] forKey:fn];
    [s addObject:[NSValue valueWithRange:NSMakeRange(line,column)]];
}

-(void)addInFilesMessageUsingFormat:(NSString*)format,... {
      va_list args;va_start(args,format);
      NSString *s=[[NSString alloc] initWithFormat:format arguments:args];
      if (![inFilesMessages containsObject:s]) [inFilesMessages addObject:s];
}

static NSMutableDictionary *InFiles_staticInFilesMessages=nil;

+(NSMutableDictionary*)staticInFilesMessages {
    if (!InFiles_staticInFilesMessages) InFiles_staticInFilesMessages=[[NSMutableDictionary alloc] init];
    return(InFiles_staticInFilesMessages);
}

+(void)addInFilename:(NSString*)fn line:(int)line column:(int)column format:(NSString*)format,... {
    va_list args;va_start(args,format);
    NSString *s=[[NSString alloc] initWithFormat:format arguments:args];
    if (!fn) return;
    NSMutableDictionary *m=[[InFiles staticInFilesMessages] objectForKey:fn];
    if (!m) [[InFiles staticInFilesMessages] setObject:m=[NSMutableDictionary dictionary] forKey:fn];
    NSValue *v=[NSValue valueWithRange:NSMakeRange(line,column)];
    NSMutableArray *a=[m objectForKey:v];
    if (!a) [m setObject:a=[NSMutableArray array] forKey:v];
    [a addObject:s];
}

static NSMutableArray *InFiles_allInFiles=nil;

+(NSArray*)allInFiles {
    if (!InFiles_allInFiles) InFiles_allInFiles=[[NSMutableArray alloc] init];
    return(InFiles_allInFiles);
}
+(NSString*)excessMsg {
    return(@"This file stores excess wi errors, warnings, and notes");
}
+(NSDictionary*)unionFiles:(NSArray*)inFiles {
    NSMutableDictionary *locations=[[NSMutableDictionary alloc] init];
    NSMutableSet *excessfns=[NSMutableSet set];
    for (NSString *fn in [InFiles staticInFilesMessages]) {
        NSDictionary *msgd=[[InFiles staticInFilesMessages] objectForKey:fn];
        NSMutableDictionary *d=[locations objectForKey:fn];
        if (!d) [locations setObject:d=[NSMutableDictionary dictionary] forKey:fn];
        for (NSValue *vv in msgd) {
            NSArray *msgs=[msgd objectForKey:vv];
            if (!msgs.count) continue;
            NSMutableArray *a=[d objectForKey:vv];
            if (!a) [d setObject:a=[NSMutableArray array] forKey:vv];
            for (NSString *msg in msgs) {
                if (![a containsObject:msg]) {
                    [a addObject:msg];
                }
                if ([msg isEqualToString:[InFiles excessMsg]]) {
                    [excessfns addObject:fn];
                }
            }
        }
    }
    NSMutableArray *excessMsgs=[NSMutableArray array];
    for (InFiles *v in inFiles) {
        if (!v.inFilesMessages.count) continue;
        for (NSString *fn in v.inFilesLocations) {
            NSSet *s=[v.inFilesLocations objectForKey:fn];
            NSMutableDictionary *d=[locations objectForKey:fn];
            if (!d) [locations setObject:d=[NSMutableDictionary dictionary] forKey:fn];
            for (NSValue *vv in s) {
                NSMutableArray *a=[d objectForKey:vv];
                if (!a) [d setObject:a=[NSMutableArray array] forKey:vv];
                for (NSString *msg in v.inFilesMessages) {
                    if (![a containsObject:msg]) {
                        [a addObject:msg];
                    }
                }
            }
        }
        if (!v.inFilesLocations.count) {
            for (NSString *msg in v.inFilesMessages) {
                if (![excessMsgs containsObject:msg]) {
                    [excessMsgs addObject:msg];
                }
            }
        }
    }
    
    for (NSString *fn in excessfns) {
        NSMutableDictionary *d=[locations objectForKey:fn];
        if (!d) [locations setObject:d=[NSMutableDictionary dictionary] forKey:fn];
        NSValue *vv=[NSValue valueWithRange:NSMakeRange(0,0)];
        NSMutableArray *a=[d objectForKey:vv];
        if (!a) [d setObject:a=[NSMutableArray array] forKey:vv];
        for (NSString *msg in excessMsgs) {
            if (![a containsObject:msg]) {
                [a addObject:msg];
            }
        }
    }
            
    NSDictionary *d=locations.copy;
    return(d);
}

+(void)clearMarksFromFiles:(NSArray*)fns {
    NSError *err=nil;
    NSRegularExpression *re=[NSRegularExpression regularExpressionWithPattern:@"/\\*\\*\\!.*?\\!\\*\\*/\\s*\n" options:NSRegularExpressionDotMatchesLineSeparators error:&err];
    if (err||!re) {
        NSLog(@"Bad re : /\\*\\*\\!.*?\\!\\*\\*/\\s*");
        return;
    }
    for (NSString *fn in fns) {
        NSMutableString *s=[((NSString*)[NSString stringWithContentsOfFile:fn encoding:NSASCIIStringEncoding error:&err]).mutableCopy autorelease];
        if (s&&!err) {
            [re replaceMatchesInString:s options:0 range:NSMakeRange(0,s.length) withTemplate:@""];
            [s writeToFile:fn atomically:YES encoding:NSASCIIStringEncoding error:&err];
            if (err) {
                NSLog(@"Could not write %@ to clear marks",fn);
            }
        }
        else NSLog(@"Could not open %@ to clear marks",fn);
    }
}

+(void)markFiles:(NSArray*)inFiles {
    NSDictionary *locations=[InFiles unionFiles:inFiles];
    for (NSString *fn in locations) {
        FILE *fil=fopen(fn.UTF8String,"r+b");
        if (!fil) {
            printf("!!!Failed to find file \"%s\" to insert messages\n",fn.UTF8String);
            continue;
        }
        NSMutableArray *lns=[[NSMutableArray alloc] init];
        [lns addObject:[NSNumber numberWithInt:0]];
        char buf[10000];
        int offs=0;
        while (YES) {
            int N=(int)fread(buf, 1, 10000, fil);
            for (int offs2=0;offs2<N;offs++,offs2++) {
                if (buf[offs2]=='\n') [lns addObject:[NSNumber numberWithInt:offs+1]];
            }
            if (feof(fil)||!N) break;
        }
        int sz=(int)ftell(fil);
        
        NSDictionary *msgd=[locations objectForKey:fn];
        NSArray *a=[msgd.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSRange r1=((NSValue*)obj1).rangeValue;
                NSRange r2=((NSValue*)obj2).rangeValue;
                return((r1.location<r2.location)||((r1.location==r2.location)&&(r1.length<r2.length))?NSOrderedAscending:
                ((r1.location>r2.location)||((r1.location==r2.location)&&(r1.length>r2.length))?NSOrderedDescending:NSOrderedSame));
            }
        ];

        for (int i=(int)a.count-1;i>=0;i--) {
            NSRange r=((NSValue*)[a objectAtIndex:i]).rangeValue;
            NSArray *msgs=[msgd objectForKey:[a objectAtIndex:i]];
            if (!msgs.count) continue;
            
            int ln=(int)r.location;
            //int col=(int)r.length;
            NSMutableString *msg=[[NSMutableString alloc] initWithFormat:@"/**!"];
            bool fst=YES;
            for (NSString *msg2 in msgs) {
                [msg appendFormat:(fst?@" -- %@":@"\n     -- %@"),[[[msg2 stringByReplacingOccurrencesOfString:@"/*" withString:@" / *"] stringByReplacingOccurrencesOfString:@"*/" withString:@"* / "] stringByReplacingOccurrencesOfString:@"//" withString:@" / /"]];
                fst=NO;
            }
            [msg appendString:@" !**/\n"];
            if (ln>=lns.count) offs=sz;
            else offs=((NSNumber*)[lns objectAtIndex:ln]).intValue;
            NSData *d=[msg dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            [InFiles insertData:d intoFile:fil at:offs];
        }
        
        fclose(fil);
    }
        
}


+(void)markFiles {
    [InFiles markFiles:[InFiles allInFiles]];
}

+(NSArray*)subsetOfInFiles:(NSArray*)inFiles inFile:(NSString*)fn atLine:(int)ln column:(int)col {
    NSMutableArray *ret=[NSMutableArray array];
    for (InFiles *v in inFiles) {
        if ([(NSSet*)[v.inFilesLocations objectForKey:fn] containsObject:[NSValue valueWithRange:NSMakeRange(ln,col)]]) [ret addObject:v];
    }
    return(ret);
}

+(void)insertData:(NSData*)d intoFile:(FILE*)fil at:(int)offs {
    fseek(fil, 0, SEEK_END);
    int sz=(int)ftell(fil),i;
    char buf[10000];
    for (i=sz-10000;i>=offs;i-=10000) {
        fseek(fil, i, SEEK_SET);
        fread(buf,1,10000,fil);
        fseek(fil, i+d.length, SEEK_SET);
        fwrite(buf,1,10000,fil);
    }
    if (i<offs) {
        int len=10000+i-offs;
        fseek(fil, offs, SEEK_SET);
        fread(buf,1,len,fil);
        fseek(fil, offs+d.length, SEEK_SET);
        fwrite(buf,1,len,fil);
    }
    fseek(fil, offs, SEEK_SET);
    fwrite(d.bytes,1,d.length,fil);
}
    



@end




















@implementation WClasses
@synthesize classes,protocols,skipNewLines;
@synthesize classContext,logContext,classContextBracket,propertyContexts,propertyContextBrackets,props,propFiles,taskList,readFNStack,includes,taskFn;
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
    self.propertyContextBrackets=nil;
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
    self.propertyContextBrackets=[NSMutableIndexSet indexSet];
    self.taskList=[NSMutableArray array];
    self.classContext=nil;
    self.includes=[NSMutableArray array];
    self.readFNStack=[NSMutableSet set];
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
        NSArray *a=[NSArray arrayWithObjects:@"Base",
            @"11",@"S1",@"A1",@"D1",@"1S",@"1A",@"1D",@"SS",nil];
        NSMutableDictionary *d=[NSMutableDictionary dictionary];
        for (NSString *s in a) {
            WReader *r=[[WReader alloc] init];
            NSString *fn=[NSString stringWithFormat:@"/Users/Will/Documents/WInterface/WInterface/Wis/Prop%@.wi",s];
            [InFiles clearMarksFromFiles:@[fn]];
            r.fileName=fn;
            [d setObject:r.fileString forKey:s];
        }
        a=[NSArray arrayWithObjects:@"T1",
            @"NSM",@"NS1M,NS1",@"NS1",@"NSA",@"NS1A,NS1",@"NSS",nil];
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
                [d setObject:agg forKey:[ss objectAtIndex:0]];
            }
            else {
                NSString *fn=[NSString stringWithFormat:@"/Users/Will/Documents/WInterface/WInterface/Wis/Model%@.wi",s];
                [InFiles clearMarksFromFiles:@[fn]];
                r.fileName=fn;
                [d setObject:r.fileString forKey:s];
            }
        }
        _default=[[WClasses alloc] init];
        _default.propFiles=d;
    }
    return(_default);
}

+ (void)clearStaticData {
    if (_default) {_default;_default=nil;}
}

-(NSSet*)filenames {
    NSMutableSet *ret=[NSMutableSet setWithObjects:@"default",@"inserts", nil];
    for (NSString *name in self.classes) [ret addObject:((WClass*)[self.classes objectForKey:name]).filename];
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
        WClass *c=[self.classes objectForKey:cname];
        c.ownedNum=c.ownsNum=0;
    }
    for (NSString *pname in self.protocols) {
        WClass *p=[self.protocols objectForKey:pname];
        p.ownedNum=p.ownsNum=0;
    }
    for (NSString *cname in self.classes) {
        WClass *c=[self.classes objectForKey:cname];
        [c addOwnership];
    }
    for (NSString *pname in self.protocols) {
        WClass *p=[self.protocols objectForKey:pname];
        [p addOwnership];
    }
    NSMutableDictionary *varDict=[NSMutableDictionary dictionary];
    for (NSString *cname in self.classes) {
        WClass *c=[self.classes objectForKey:cname];
        [c addjsvars:varDict];
    }
    for (NSString *pname in self.protocols) {
        WClass *p=[self.protocols objectForKey:pname];
        [p addjsvars:varDict];
    }
    
    NSMutableString *ret=[NSMutableString stringWithFormat:@"<!DOCTYPE html><meta charset=\"utf-8\"><title>WI</title><script>var classVars={"];
    for (NSString *type in varDict) [ret appendFormat:@"\"%@\":\"%@\",\n",[WClasses jsStringForString:type],[WClasses jsStringForString:[varDict objectForKey:type]]];
    
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
        WClass *c=[self.classes objectForKey:n];
        if (!(c.isType||c.isSys)) {
            NSString *s=[varDict objectForKey:[c.tag stringByAppendingString:@"_."]];
            [ret appendFormat:@"<li>%@</li>\n",[s stringByReplacingOccurrencesOfString:@"PATH" withString:c.tag]];
        }
    }

    [ret appendFormat:@"</ul><h1>Protocols</h1><ul>\n"];
    //<h1>Protocols</h1>%@<h1>Types and sys</h1>%@</body></html>\n",retclass,retprotocol,rettype];
    
    for (NSString *n in pnames) {
        WClass *p=[self.protocols objectForKey:n];
        if (!(p.isType||p.isSys)) {
            NSString *s=[varDict objectForKey:[p.tag stringByAppendingString:@"_."]];
            [ret appendFormat:@"<li>%@</li>\n",[s stringByReplacingOccurrencesOfString:@"PATH" withString:p.tag]];
        }
    }
    

    [ret appendFormat:@"</ul><h1>Types and sys</h1><ul>\n"];
    //<h1>Protocols</h1>%@<h1>Types and sys</h1>%@</body></html>\n",retclass,retprotocol,rettype];
    
    for (NSString *n in cnames) {
        WClass *c=[self.classes objectForKey:n];
        if (c.isType||c.isSys) {
            NSString *s=[varDict objectForKey:[c.tag stringByAppendingString:@"_."]];
            [ret appendFormat:@"<li>%@</li>\n",[s stringByReplacingOccurrencesOfString:@"PATH" withString:c.tag]];
        }
    }
    [ret appendFormat:@"</ul>\n"];
    
    /*
    NSMutableString *retprotocol=[NSMutableString string];
    NSMutableString *retclass=[NSMutableString string];
    NSMutableString *rettype=[NSMutableString string];
    
    NSMutableDictionary *tags=[NSMutableDictionary dictionary];
    for (int oi=0;tags.count!=self.classes.count+self.protocols.count;oi++) {
        //printf("%ld %ld\n",tags.count,self.classes.count+self.protocols.count);
    
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
    [self.props removeAllObjects];
    [self.propertyContextBrackets removeAllIndexes];
    [self.taskList removeAllObjects];
    self.classContext=nil;
    [self.includes removeAllObjects];
    [self.readFNStack removeAllObjects];
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

- (int)read:(WReader*)r options:(SEL*)options numOptions:(int)N retObject:(NSObject**)po {
    int pos=r.pos;
    for (int i=0;i<N;i++) {
        NSObject *o=[self performSelector:options[i] withObject:r];
        if (o) {
            (*po)=o;
            return(i);
        }
        else r.pos=pos;
    }
    return(iNSNotFound);
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
    int pos=r.pos;
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
    int pi,bc;
    for (pi=(int)self.propertyContextBrackets.count-1,bc=(int)self.propertyContextBrackets.lastIndex;(bc!=iNSNotFound)&&(bc>=r.currentToken.bracketCount);bc=(int)[self.propertyContextBrackets indexLessThanIndex:bc],pi--);
    
    if (pi>=0) return((WProp*)[self.propertyContexts objectAtIndex:pi]);
    else return(nil);
}
- (WClass*)enclosingClassNoSkip:(WReader*)r {
    WClass *c=nil;
    WProp *p=[self enclosingPropNoSkip:r];
    if (p) c=p.hisclas;
    else if (self.classContext) {
        if (r.currentToken.bracketCount>self.classContextBracket) c=self.classContext;
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
- (NSString*)readBlock:(WReader*)r {
    int pos=r.pos;
    if (![self readc:r anyof:@"{"]) {r.pos=pos;return(nil);}
    int bc=1;
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
    int pos=r.pos;
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
    int pos=r.pos;
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
        int d=1;
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

-(bool)readType:(WReader*)r retclas:(WClass**)pclas retprotocolList:(NSArray**)pprotocolList needColon:(bool)needColon {
    int pos=r.pos;
    unichar ch=[self readOpcOnOneLine:r];
    WClass *clas=nil;
    
    WReaderToken *t0=r.currentToken;
    
    if (pclas) {
        NSString *name;
        if (ch=='<') {
            name=@"NSObject";
        }
        else {
            int pos2=pos;
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

-(bool)readPotentialType:(WReader*)r retclas:(NSString**)pclas retprotocolList:(NSArray**)pprotocolList needColon:(bool)needColon {
    int pos=r.pos;
    unichar ch=[self readOpcOnOneLine:r];
    NSString *clas=nil;
    
    WReaderToken *t0=r.currentToken;

    if (pclas) {
        NSString *name;
        if (ch=='<') {
            name=@"NSObject";
        }
        else {
            int pos2=pos;
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
    return([[WType alloc] initWithClass:clas protocols:protocolList addObject:NO]);
}
-(WPotentialType*)readPotentialType:(WReader*)r {
    NSString *clas;
    NSArray *protocolList;
    if (![self readPotentialType:r retclas:&clas retprotocolList:&protocolList needColon:NO]) return(nil);
    return([[WPotentialType alloc] initWithClass:clas protocols:protocolList addObject:NO]);
}


- (NSArray*)readVar:(WReader*)r {
    int pos1=r.pos;
    WReaderToken *t0=r.currentToken;

    do {
//        [WClasses warning:[NSString stringWithFormat:@"rv"] withReader:r];
        WClass *c=[self enclosingClass:r];
        if (!c) return(nil);

//        [WClasses warning:[NSString stringWithFormat:@"rv2"] withReader:r];

        [[WClasses getDefault] skipSpaces:r];
        int bc=r.currentToken.bracketCount;
        int linei=r.currentToken.linei;
        
        WPotentialType *ptype;
        if (!(ptype=[self readPotentialType:r])) return(nil);
        NSString *aname,*aqname=nil;

        NSMutableArray *names=[NSMutableArray array],*defaultValues=[NSMutableArray array],*defLevels=[NSMutableArray array],*getters=[NSMutableArray array],*setters=[NSMutableArray array],*setterVars=[NSMutableArray array],*tags=[NSMutableArray array],*qnames=[NSMutableArray array],*starss=[NSMutableArray array];
        NSMutableSet *attr=nil;
        
//        [WClasses warning:[NSString stringWithFormat:@"var"] withReader:r];

        unichar ch;
        int stars=0;
        while ((ch=[self readOpc:r])=='*') stars++;
        if (ch) {
            break;
        }
        if (!(aname=[self readWord:r])) break;
//        [WClasses warning:[NSString stringWithFormat:@"%@",aname] withReader:r];
        int posq=r.pos;
        if (!([self readc:r anyof:@">"]&&[self readc:r anyof:@">"]&&(aqname=[self readWord:r]))) {
            r.pos=posq;
        }
        
        [names addObject:aname];
        [starss addObject:[NSNumber numberWithInt:stars]];
        [qnames addObject:aqname?aqname:[NSNull null]];
        
        int pos2=r.pos;
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
                int defLevel=0;
                bool changed=YES;
                while (changed) {
                    //[WClasses note:r.localString withToken:t0 context:nil];
                    changed=NO;
                    int pos2=r.pos;
                    if (r.currentToken.type=='c') {
                        bool appendb;
                        int numTokens;
                        int n=[WFn tokenMergeNumber:r.tokenizer pos:r.pos append:&appendb retNumTokens:&numTokens];
                        if (n!=iNSNotFound) {
                            r.pos+=numTokens;
                            if ((!def)&&((def=[self readVarDefaultValue:r]))) {
                                changed=YES;
                                defLevel=n;
                            }
                        }
                    }
                    if (!changed) {
                        if ((!def)&&((def=[self readVarDefaultValue:r]))) changed=YES;
                        else if ((!getter)&&((getter=[self readBlock:r]))) changed=YES;
                        else if ((!setter)&&[self readc:r anyof:@"-"]&&((setterVar=[self readWord:r]))&&((setter=[self readBlock:r]))) changed=YES;
                    }
                    if (changed) {
                        int lni=r.currentToken.linei;
                        [self skipSpaces:r];
                        //[WClasses warning:[NSString stringWithFormat:@"linei=%d:%d bc=%d:%d",linei,r.currentToken.linei,bc,r.currentToken.bracketCount] withReader:r];
                        if ((!r.currentToken)||((r.currentToken.linei>lni)&&(r.currentToken.bracketCount<=bc))) break;
                    }
                    else r.pos=pos2;
                }
                [defLevels addObject:(def?[NSNumber numberWithInt:defLevel]:[NSNull null])];
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
            int posq=r.pos;
            if (!([self readc:r anyof:@">"]&&[self readc:r anyof:@">"]&&(aqname=[self readWord:r]))) {
                r.pos=posq;
            }
            [names addObject:aname];
            [qnames addObject:aqname?aqname:[NSNull null]];
            [starss addObject:[NSNumber numberWithInt:stars]];
            pos2=r.pos;
                    //[WClasses warning:[NSString stringWithFormat:@"here"] withReader:r];
            ch=[self readOpc:r];
        }
        //[WClasses warning:[NSString stringWithFormat:@"%c",ch] withReader:r];

        if (ch=='(') {
            attr=[NSMutableSet set];
            NSString *s;
            for (s=[self readVarAttribute:r];s;s=[self readVarAttribute:r]) {
                [attr addObject:s];
                while ([self readc:r anyof:@","]);
                if ([self readc:r anyof:@")"]) break;
            }
            if (!s) {
                [WClasses error:@"Bad attribute array" withToken:t0 context:nil];
                r.pos=pos2;
                [attr removeAllObjects];
            }
            if ([attr containsObject:@"attribute"]) {
                [attr addObject:@"imaginary"];
                [attr addObject:@"nodef"];
                for (int i=0;i<names.count;i++) {
                    [WFn getFnWithSig:[NSString stringWithFormat:@"-(SHAttribute*)%@",[names objectAtIndex:i]] body:[NSString stringWithFormat:@"@999 return([self.program.attributes objectForKey:@\"%@\"]);",[names objectAtIndex:i]] clas:c];
                }
            }
            if ([attr containsObject:@"uniform"]) {
                [attr addObject:@"imaginary"];
                [attr addObject:@"nodef"];
                for (int i=0;i<names.count;i++) {
                    [WFn getFnWithSig:[NSString stringWithFormat:@"-(SHUniform*)%@",[names objectAtIndex:i]] body:[NSString stringWithFormat:@"@999 return([self.program.uniforms objectForKey:@\"%@\"]);",[names objectAtIndex:i]] clas:c];
                }
            }
            if ([attr containsObject:@"ivargetter"]) {
                [attr addObject:@"readonly"];
                [attr addObject:@"dealloc"];
                [attr addObject:@"ivar"];
            }
        }
        else r.pos=pos2;
        //printf("Var : %s\n",[[r stringWithTokensInRange:NSMakeRange(pos1, r.pos-pos1)] cStringUsingEncoding:NSASCIIStringEncoding]);
        [self skipSpacesAndSemicolons:r];
        NSMutableArray *rets=[NSMutableArray array];
        int i=0;
        WType *type;
        for (NSString *name in names) {
            NSMutableSet *attr2=attr;
            int stars=((NSNumber*)[starss objectAtIndex:i]).intValue;
            if ([[getters objectAtIndex:i] isKindOfClass:[NSString class]]&&![[setters objectAtIndex:i] isKindOfClass:[NSString class]]) {
                //attr2=(attr2?attr2.mutableCopy:[NSMutableSet set]);
                //[attr2 addObject:@"readonly"];
            }
            if (!i) {
                type=[[WType alloc] initWithPotentialType:ptype];
            }
            WVar *v=[WVar getVarWithType:type stars:stars name:name qname:[[qnames objectAtIndex:i] isKindOfClass:[NSString class]]?[qnames objectAtIndex:i]:nil defVal:[[defaultValues objectAtIndex:i] isKindOfClass:[NSNull class]]?nil:[defaultValues objectAtIndex:i] defValLevel:[[defLevels objectAtIndex:i] isKindOfClass:[NSNull class]]?0:((NSNumber*)[defLevels objectAtIndex:i]).intValue attributes:attr2 clas:c];
            [v addInFilename:r.filePath line:linei column:0];
            [rets addObject:v];
//            if ([attr containsObject:@"modelretain"]) {
//                [getters replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"return(%@);",v.varName]];
//                if (![attr2 containsObject:@"readonly"]) {
//                    [setters replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"[%@ modelrelease];\n%@=[v modelretain];",v.varName,v.varName]];
//                    [setterVars replaceObjectAtIndex:i withObject:@"v"];
//                }
//            }
            if ([[getters objectAtIndex:i] isKindOfClass:[NSString class]]) {
                WFn *fn=[WFn getFnWithSig:[NSString stringWithFormat:@"-(%@)%@",v.objCType,name] body:(NSString*)[getters objectAtIndex:i] clas:c];
                [fn addInFilename:r.filePath line:linei column:0];
            }
            if ([[setters objectAtIndex:i] isKindOfClass:[NSString class]]) {
                WFn *fn=[WFn getFnWithSig:[NSString stringWithFormat:@"-(void)set%@:(%@)%@",[WProp upperName:name],v.objCType,[setterVars objectAtIndex:i]] body:(NSString*)[setters objectAtIndex:i] clas:c];
                [fn addInFilename:r.filePath line:linei column:0];

            }
            i++;
        }
        for (WVar *ret in rets) {
            [ret add:r];
        }
        return(rets);
    } while (false);
    r.pos=pos1;
    return(nil);
}

- (WFn*)readFn:(WReader*)r {
    WClass *c=[self enclosingClass:r];
    if (!c) return(nil);

    int linei=r.currentToken.linei;
    int pos=r.pos;
    
    unichar ch;
    switch ((ch=[self readOpc:r])) {
        default:return(nil);
        case '-':case '+':break;
    }
    NSMutableString *sig=[NSMutableString stringWithFormat:@"%c",ch];
    NSString *body=nil;

    [self skipSpaces:r];
    WReaderToken *t;
    for (t=r.currentToken;t&&((t.type!='o')||(((ch=[t.str characterAtIndex:0])!='{')&&(ch!=';')));r.pos++,t=r.currentToken) {
        [sig appendString:(t.type=='z')||(t.type=='r')?@" ":t.str];
    }
    if (!t) {
        r.pos=pos;
        return(nil);
    }
    sig=[sig stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].mutableCopy;
    body=[self readBlock:r];
    //printf("Fn : %s\n",[[r stringWithTokensInRange:NSMakeRange(pos, r.pos-pos)] cStringUsingEncoding:NSASCIIStringEncoding]);
    [self skipSpacesAndSemicolons:r];
    WFn *fn=[WFn getFnWithSig:sig body:body clas:c];
    [fn addInFilename:r.filePath line:linei column:0];
    return(fn);
}

- (WProp*)readProp:(WReader*)r {
    [self skipSpaces:r];
    int bc=r.currentToken.bracketCount;
    int linei=r.currentToken.linei;
    
    WProp *p=[self enclosingProp:r];
    WClass *c=(p?p.hisclas:[self enclosingClass:r]);
    NSString *name,*tag=nil,*qname=nil,*hisName,*hisTag=nil,*hisqname=nil,*type,*s;
    
    WClass *hisClass=nil;
    int pos=r.pos;
    if (!(name=[self readWord:r])) {
        r.pos=pos;
        return(nil);
    }
    int posq=r.pos;
    if (!([self readc:r anyof:@">"]&&[self readc:r anyof:@">"]&&(qname=[self readWord:r]))) {
        r.pos=posq;
    }
    int post=r.pos;
    if (!([self readc:r anyof:@":"]&&(tag=[self readWord:r]))) r.pos=post;
    int tposWas=r.pos;
    if (!(type=[self readPropType:r])) {
        r.pos=pos;
        return(nil);
    }
    
    NSMutableString *origType=[NSMutableString string];
    for (int p=tposWas;p<r.pos;p++) [origType appendString:((WReaderToken*)[r.tokenizer.tokens objectAtIndex:p]).str];

    bool isProtocol=NO;
    if (!(s=[self readWord:r])) {
        if (!([self readc:r anyof:@"<"]&&(s=[self readWord:r])&&[self readc:r anyof:@">"])) {
            r.pos=pos;
            return(nil);
        }
        isProtocol=YES;
    }
    int pos2=r.pos;
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
    //printf("Prop : %s\n",[[r stringWithTokensInRange:NSMakeRange(pos, r.pos-pos)] cStringUsingEncoding:NSASCIIStringEncoding]);
    [self skipSpacesAndSemicolons:r];
    [self.propertyContexts addObject:ret];
    [self.propertyContextBrackets addIndex:bc];
    while (YES) {
        [self skipSpaces:r];
        if ((!r.currentToken)||(r.currentToken.bracketCount<=bc)) break;
        if (!(
              [self readVar:r]||
              [self readFn:r]||
              [self readProp:r]
              )) {
            [WClasses error:@"Expected var, fn, or prop" withToken:r.currentToken context:ret];
            break;
        }
    }
    [self.propertyContexts removeObject:ret];
    [self.propertyContextBrackets removeIndex:bc];
    //printf("Prop and children : %s\n",[[r stringWithTokensInRange:NSMakeRange(pos, r.pos-pos)] cStringUsingEncoding:NSASCIIStringEncoding]);
    [self skipSpacesAndSemicolons:r];
    return(ret);
}

- (WClass*)readClass:(WReader*)r {
    if (self.classContext) return(nil);
    [self skipSpaces:r];
    int bc=r.currentToken.bracketCount;
    int linei=r.currentToken.linei;
    
    NSString *name;
    NSMutableSet *varPatterns=nil;
    bool isSys=NO,isType=NO,isWIOnly=NO;
    
    int pos=r.pos;
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
        else break;
    }
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

    if (!finishedParse) c.hasDef=YES;
    
    //printf("Class : %s\n",[[r stringWithTokensInRange:NSMakeRange(pos, r.pos-pos)] cStringUsingEncoding:NSASCIIStringEncoding]);
    [self skipSpacesAndSemicolons:r];
    bool hasChild=NO;
    self.classContext=c;
    self.classContextBracket=bc;
    bool bch=[self readc:r anyof:@"{"];
    while (YES) {
        [self skipSpaces:r];
        if ((!r.currentToken)||(r.currentToken.bracketCount<=bc)) break;
        if (!(
              [self readVar:r]||
              [self readFn:r]||
              [self readProp:r]
              )) {
            [WClasses error:@"Expected var, fn, or prop in class" withToken:r.currentToken context:c];
            break;
        }
        hasChild=YES;
    }
    if (bch) [self readc:r anyof:@"}"];
    else if (!(hasChild||[self readVar:r]||[self readFn:r]||[self readProp:r])) {}
    self.classContext=nil;
    self.classContextBracket=-1;
    //printf("Class and children : %s\n",[[r stringWithTokensInRange:NSMakeRange(pos, r.pos-pos)] cStringUsingEncoding:NSASCIIStringEncoding]);
    [self skipSpacesAndSemicolons:r];
    return(c);
}


- (WClass*)readProtocol:(WReader*)r {
//return(nil);
    if (self.classContext) return(nil);
    [self skipSpaces:r];
    int bc=r.currentToken.bracketCount;
    int linei=r.currentToken.linei;
    WReaderToken *t0=r.currentToken;
    
    NSString *name;
    NSMutableSet *varPatterns=nil;
    NSMutableArray *superNames=nil;
    bool issys=NO;
    
    int pos=r.pos;
    NSString *w=[self readWord:r];
    if (w) {
        if (![w isEqualToString:@"sys"]) r.pos=pos;
        else issys=YES;
    }
    
    if (!(([self readOpc:r]=='<')&&(name=[self readWord:r]))) {
        r.pos=pos;
        return(nil);
    }
    int pos2=r.pos;
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
    //printf("Protocol : %s\n",[[r stringWithTokensInRange:NSMakeRange(pos, r.pos-pos)] cStringUsingEncoding:NSASCIIStringEncoding]);
    [self skipSpacesAndSemicolons:r];
    bool hasChild=NO;
    self.classContext=c;
    self.classContextBracket=bc;
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
    //printf("Protocol and children : %s\n",[[r stringWithTokensInRange:NSMakeRange(pos, r.pos-pos)] cStringUsingEncoding:NSASCIIStringEncoding]);
    [self skipSpacesAndSemicolons:r];
    return(c);
}

+ (void)changeToFileDir:(NSString*)fn {
    fn=[fn stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    int ind=(int)[fn rangeOfString:@"/" options:NSBackwardsSearch].location;
    if (ind==iNSNotFound) return;
    NSFileManager *fm=[NSFileManager defaultManager];
    [fm changeCurrentDirectoryPath:[fn substringToIndex:ind+1]];
}

- (bool)readInclude:(WReader*)r {
    if (self.classContext) return(NO);
    int pos=r.pos;
    WReaderToken *t0=r.currentToken;
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
        else {        
            NSString *s=name;
            printf("Include: %s\n",s.UTF8String);
            if ([self.readFNStack containsObject:s]) {
                [WClasses error:@"File already included" withToken:t0 context:nil];
            }
            else {
                WReader *r2=[[WReader alloc] init];
                r2.tokenizer.tokenDelegate=[WClasses getDefault];
                [InFiles clearMarksFromFiles:@[s]];
                r2.fileName=s;
                if (r2.fileString.length==0) [WClasses error:@"File is empty or doesn't exist" withToken:t0 context:nil];
                else {
                    NSFileManager *fm=[NSFileManager defaultManager];
                    NSString *wasDir=fm.currentDirectoryPath;
                    [[self class] changeToFileDir:s];
                    [self.readFNStack addObject:s];
                    if ([s hasSuffix:@"wierrors.wi"]) [InFiles addInFilename:r2.filePath line:0 column:0 format:@"%@",[InFiles excessMsg]];
                    [self read:r2 logContext:nil];
                    [self.readFNStack removeObject:s];
                    [fm changeCurrentDirectoryPath:wasDir];
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
    int pos2=r.pos;
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


-(NSMutableString*)importsDeclWithName:(NSString*)s nameUsed:(NSString**)pnameUsed {
    NSString *nn,**n=(pnameUsed?pnameUsed:&nn);
    if ([s hasPrefix:*n=@"top:decl:"]) return(ins_first_decl);
    else if ([s hasPrefix:*n=@"imports:decl:"]) return(ins_after_imports_decl);
    else if ([s hasPrefix:*n=@"decl:decl:"]) return(ins_after_decl_decl);
    else if ([s hasPrefix:*n=@"structs:decl:"]) return(ins_after_structs_decl);
    else if ([s hasPrefix:*n=@"protocols:decl:"]) return(ins_after_protocols_decl);
    else if ([s hasPrefix:*n=@"interfaces:decl:"]) return(ins_after_ifaces_decl);
    else if ([s hasPrefix:*n=@"bottom:decl:"]) return(ins_last_decl);

    else if ([s hasPrefix:*n=@"top:iface:"]) return(ins_first_iface);
    else if ([s hasPrefix:*n=@"imports:iface:"]) return(ins_after_imports_iface);
    else if ([s hasPrefix:*n=@"decl:iface:"]) return(ins_after_decl_iface);
    else if ([s hasPrefix:*n=@"structs:iface:"]) return(ins_after_structs_iface);
    else if ([s hasPrefix:*n=@"protocols:iface:"]) return(ins_after_protocols_iface);
    else if ([s hasPrefix:*n=@"interfaces:iface:"]) return(ins_after_ifaces_iface);
    else if ([s hasPrefix:*n=@"bottom:iface:"]) return(ins_last_iface);

    else if ([s hasPrefix:*n=@"top:impl:"]) return(ins_first_impl);
    else if ([s hasPrefix:*n=@"imports:impl:"]) return(ins_after_imports_impl);
    else if ([s hasPrefix:*n=@"decl:impl:"]) return(ins_after_decl_impl);
    else if ([s hasPrefix:*n=@"structs:impl:"]) return(ins_after_structs_impl);
    else if ([s hasPrefix:*n=@"protocols:impl:"]) return(ins_after_protocols_impl);
    else if ([s hasPrefix:*n=@"interfaces:impl:"]) return(ins_after_ifaces_impl);
    else if ([s hasPrefix:*n=@"bottom:impl:"]) return(ins_last_impl);

    else if ([s hasPrefix:*n=@"top:"]) return(ins_first_iface);
    else if ([s hasPrefix:*n=@"imports:"]) return(ins_after_imports_iface);
    else if ([s hasPrefix:*n=@"decl:"]) return(ins_after_decl_iface);
    else if ([s hasPrefix:*n=@"structs:"]) return(ins_after_structs_iface);
    else if ([s hasPrefix:*n=@"protocols:"]) return(ins_after_protocols_iface);
    else if ([s hasPrefix:*n=@"interfaces:"]) return(ins_after_ifaces_iface);
    else if ([s hasPrefix:*n=@"bottom:"]) return(ins_last_iface);

    else if ([s hasPrefix:*n=@"each:impl:"]) return(ins_each_impl);

    else {*n=@"";return(nil);}
}


-(NSMutableSet*)importsSetWithName:(NSString*)s nameUsed:(NSString**)pnameUsed {
    NSString *nn,**n=(pnameUsed?pnameUsed:&nn);
    if ([s hasPrefix:*n=@"top:decl:"]) return(ins_set_first_decl);
    else if ([s hasPrefix:*n=@"imports:decl:"]) return(ins_set_after_imports_decl);
    else if ([s hasPrefix:*n=@"decl:decl:"]) return(ins_set_after_decl_decl);
    else if ([s hasPrefix:*n=@"structs:decl:"]) return(ins_set_after_structs_decl);
    else if ([s hasPrefix:*n=@"protocols:decl:"]) return(ins_set_after_protocols_decl);
    else if ([s hasPrefix:*n=@"interfaces:decl:"]) return(ins_set_after_ifaces_decl);
    else if ([s hasPrefix:*n=@"bottom:decl:"]) return(ins_set_last_decl);

    else if ([s hasPrefix:*n=@"top:iface:"]) return(ins_set_first_iface);
    else if ([s hasPrefix:*n=@"imports:iface:"]) return(ins_set_after_imports_iface);
    else if ([s hasPrefix:*n=@"decl:iface:"]) return(ins_set_after_decl_iface);
    else if ([s hasPrefix:*n=@"structs:iface:"]) return(ins_set_after_structs_iface);
    else if ([s hasPrefix:*n=@"protocols:iface:"]) return(ins_set_after_protocols_iface);
    else if ([s hasPrefix:*n=@"interfaces:iface:"]) return(ins_set_after_ifaces_iface);
    else if ([s hasPrefix:*n=@"bottom:iface:"]) return(ins_set_last_iface);

    else if ([s hasPrefix:*n=@"top:impl:"]) return(ins_set_first_impl);
    else if ([s hasPrefix:*n=@"imports:impl:"]) return(ins_set_after_imports_impl);
    else if ([s hasPrefix:*n=@"decl:impl:"]) return(ins_set_after_decl_impl);
    else if ([s hasPrefix:*n=@"structs:impl:"]) return(ins_set_after_structs_impl);
    else if ([s hasPrefix:*n=@"protocols:impl:"]) return(ins_set_after_protocols_impl);
    else if ([s hasPrefix:*n=@"interfaces:impl:"]) return(ins_set_after_ifaces_impl);
    else if ([s hasPrefix:*n=@"bottom:impl:"]) return(ins_set_last_impl);

    else if ([s hasPrefix:*n=@"top:"]) return(ins_set_first_iface);
    else if ([s hasPrefix:*n=@"imports:"]) return(ins_set_after_imports_iface);
    else if ([s hasPrefix:*n=@"decl:"]) return(ins_set_after_decl_iface);
    else if ([s hasPrefix:*n=@"structs:"]) return(ins_set_after_structs_iface);
    else if ([s hasPrefix:*n=@"protocols:"]) return(ins_set_after_protocols_iface);
    else if ([s hasPrefix:*n=@"interfaces:"]) return(ins_set_after_ifaces_iface);
    else if ([s hasPrefix:*n=@"bottom:"]) return(ins_set_last_iface);

    else if ([s hasPrefix:*n=@"each:impl:"]) return(ins_set_each_impl);

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



- (int)readComments:(WReader*)r fromIndex:(int)from toBeforeIndex:(int)to {
    if ((from<0)||(from>=r.tokenizer.tokens.count)) return((int)r.tokenizer.tokens.count);
    if ((to<0)||(to>r.tokenizer.tokens.count)) to=(int)r.tokenizer.tokens.count;
    
    for (int pos=from;pos<to;pos++) {
        WReaderToken *t=[r.tokenizer.tokens objectAtIndex:pos];
        if (t&&(t.type=='c')&&([t.str hasPrefix:@"/*"]||[t.str hasPrefix:@"//"])) {
            NSString *s=[t.str substringWithRange:NSMakeRange(2, t.str.length-2-([t.str hasPrefix:@"/*"]&&[t.str hasSuffix:@"*/"]?2:0))];
            NSString *nameUsed=nil;
            NSMutableString *decl=[self importsDeclWithName:s nameUsed:&nameUsed];
            if (decl) {
                [decl appendString:[s substringFromIndex:nameUsed.length]];
            }
        }
    }
    return(to);
}

- (void)readKeepingContext:(WReader *)r {
    int posWas=0;
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
    NSMutableArray *pwas=self.propertyContexts;
    NSMutableIndexSet *piwas=self.propertyContextBrackets;
    int cbwas=self.classContextBracket;
    
    self.classContext=nil;
    self.classContextBracket=0;
    self.propertyContexts=[NSMutableArray array];
    self.propertyContextBrackets=[NSMutableIndexSet indexSet];
    
    InFiles *logContextWas=self.logContext;
    if (alogContext) {
        while (alogContext.useLocationsFrom) alogContext=alogContext.useLocationsFrom;
        self.logContext=alogContext;
    }
    
    [self readKeepingContext:r];
    
    self.logContext=logContextWas;

    self.classContext=cwas;
    self.propertyContexts=pwas;
    self.propertyContextBrackets=piwas;
    self.classContextBracket=cbwas;
}




-(void)makeImportSets {
    if (madeImportSets) return;
    madeImportSets=YES;
    WClass *p=[self.protocols objectForKey:@"perclassdefn"];
    if (p) {
        for (NSString *fnnm in p.fns) {
            WFn *fn=[p.fns objectForKey:fnnm];
            NSString *s=[[fn.sigWithArgs substringFromIndex:1] stringByAppendingString:fn.body];
            for (NSString *cnm in self.classes) {
                WClass *c=[self.classes objectForKey:cnm];
                [ins_set_after_decl_decl addObject:[c localizeString:s]];
            }
        }
    }
    p=[self.protocols objectForKey:@"perprotocoldefn"];
    if (p) {
        for (NSString *fnnm in p.fns) {
            WFn *fn=[p.fns objectForKey:fnnm];
            NSString *s=[[fn.sigWithArgs substringFromIndex:1] stringByAppendingString:fn.body];
            for (NSString *cnm in self.protocols) {
                WClass *c=[self.protocols objectForKey:cnm];
                [ins_set_after_decl_decl addObject:[c localizeString:s]];
            }
        }
    }
    for (NSString *cnm in self.classes) {
        WClass *c=[self.classes objectForKey:cnm];
        for (NSString *fnnm in c.fns) {
            WFn *fn=[c.fns objectForKey:fnnm];
            if ([fn.sigWithArgs hasPrefix:@"-"]) {
                NSString *nameUsed=nil;
                NSMutableSet *ss=([fn.sigWithArgs isEqualToString:@"-"]?ins_set_after_decl_decl:[self importsSetWithName:[fn.sigWithArgs substringFromIndex:1] nameUsed:&nameUsed]);
                if (ss) {
                    [ss addObject:[c localizeString:fn.body]];
                }
            }
        }
    }
    for (NSString *cnm in self.protocols) {
        WClass *c=[self.protocols objectForKey:cnm];
        for (NSString *fnnm in c.fns) {
            WFn *fn=[c.fns objectForKey:fnnm];
            if ([fn.sigWithArgs hasPrefix:@"+"]) {
                NSString *nameUsed=nil;
                NSMutableSet *ss=([fn.sigWithArgs isEqualToString:@"+"]?ins_set_after_decl_decl:[self importsSetWithName:[fn.sigWithArgs substringFromIndex:1] nameUsed:&nameUsed]);
                if (ss) {
                    [ss addObject:[c localizeString:fn.body]];
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
    
    if (impl&&(hasErrors||hasWarnings)) {
        [s appendString:@"static void __wi__warner() {\n"];
        if (hasErrors) [s appendString:@"  wi_reported_errors=1;\n"];
        if (hasWarnings) [s appendString:@"  int wi_reported_warnings=1;\n"];
        [s appendString:@"}\n\n"];
    }
    
    if (iface) {
        for (NSString *incl in self.incls) {
            if ([incl hasPrefix:@"\"include:"]) [s appendFormat:@"#include \"%@",[incl substringFromIndex:@"\"include:".length]];
            else if ([incl hasPrefix:@"<include:"]) [s appendFormat:@"#include <%@",[incl substringFromIndex:@"<include:".length]];
            else if ([incl hasPrefix:@"include:"]) [s appendFormat:@"#include %@",[incl substringFromIndex:@"include:".length]];
            else [s appendFormat:@"#import %@\n",incl];
        }
        if (self.incls.count) [s appendString:SPACER];
    }
    if (hfn) [s appendFormat:@"#include \"%@\"\n",hfn];
    
    if (ins_after_imports.length) {
        [s appendString:ins_after_imports];
        [s appendString:SPACER];
        [s appendString:SPACER];
    }

    NSArray *cs=[self.classes.allValues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        WClass *c1=(WClass*)obj1,*c2=(WClass*)obj2;
        int d1=c1.depth,d2=c2.depth;
//        int d1=0,d2=0;
        return(d1<d2?NSOrderedAscending:(d1>d2?NSOrderedDescending:[c1.name compare:c2.name options:NSCaseInsensitiveSearch]));
    }];
    NSArray *ps=[self.protocols.allValues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        WClass *c1=(WClass*)obj1,*c2=(WClass*)obj2;
        int d1=c1.depth,d2=c2.depth;
//        int d1=0,d2=0;
        return(d1<d2?NSOrderedAscending:(d1>d2?NSOrderedDescending:[c1.name compare:c2.name options:NSCaseInsensitiveSearch]));
    }];
    int classCount=0,typeCount=0;


    for (WClass *c in ps) if (iface&&c.exists&&!c.isSys) [s appendFormat:@"@protocol %@;\n",c.name];
    for (WClass *c in cs) if (iface&&c.exists&&!(c.isType||c.isSys)) [s appendFormat:@"@class %@;\n",c.name];
    

    for (WClass *c in cs) {
    //            if ([c.name isEqualToString:@"CommitStage"]) printf("CS %s %s %s\n",c.name.UTF8String,c.vars.description.UTF8String,c.varPatterns.description.UTF8String);
        if (c.isType&&(!c.vars.count)&&(c.varPatterns.count>=1)) {
            for (NSString *p in c.varPatterns) {
                if (iface) {
                    if ([p hasPrefix:@"typedef:"]) {
                        NSString *t=[p substringFromIndex:@"typedef:".length];
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
            [s appendFormat:@"\n\n#pragma mark -\n#pragma mark Interfaces\n\n"];
            for (WClass *c in cs) if (c.exists&&!(c.isType||c.empty)) {
                [c appendObjCToString_iface:s];
                [s appendString:SPACER];
            }
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
                    //int d1=c1.depth,d2=c2.depth;
                    int d1=0,d2=0;
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
        [s appendString:SPACER];
    }
        
    NSMutableString *ret=nil;
    //NSDate *date=[NSDate date];
    [_s appendFormat:@"//WInterface autogenerated this file. HaND\n\n"];
    if (self.taskList.count) {
        ret=[NSMutableString string];
        [_s appendString:@"//Tasks:\n"];
        for (NSString *task in self.taskList) {
            [_s appendFormat:@"//    %@\n",task];
            if ([task hasPrefix:@"(notenote)"]) [ret appendFormat:@"%@\n",task];
        }
        [_s appendString:@"\n\n"];
    }
    [_s appendString:s];
    return(ret);
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
    n=[NSString stringWithFormat:@"   %@",[n stringByReplacingOccurrencesOfString:@"\n" withString:@"   "]];


    
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
                [[WClasses getDefault].taskList replaceObjectAtIndex:match withObject:m];
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
     [WClasses _note:[NSString stringWithFormat:@"(wi!errerr) Fix error: %@",err] withToken:t context:ctxt aggregatePattern:@"Fix ## embedded errors (look for \"errerr\" in the code)"];
    [WClasses getDefault].hasErrors=YES;
}
+ (void)warning:(NSString *)err withToken:(WReaderToken *)t context:(InFiles*)ctxt {
     [WClasses _note:[NSString stringWithFormat:@"(wi!warnwarn) Address warning: %@",err] withToken:t context:ctxt aggregatePattern:@"Address ## embedded warnings (look for \"warnwarn\" in the code)"];
    [WClasses getDefault].hasWarnings=YES;
}
+ (void)note:(NSString *)n withToken:(WReaderToken *)t context:(InFiles*)ctxt {
     [WClasses _note:[NSString stringWithFormat:@"(notenote) Note: %@",n] withToken:t context:ctxt aggregatePattern:@"Embedded ## notes (look for \"notenote\" in the code)"];
}




+(WType*)processClassType:(WType*)t class:(WClass*)clas protocols:(NSArray*)protocols tostars:(int*)pstars {
    if (!t) return(nil);
    if (pstars) *pstars=0;
    WPotentialType *pt=[[WPotentialType alloc] initWithType:t];
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
    
    WType *nt=[[WType alloc] initWithPotentialType:pt];
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
        for (NSInteger i=protocols.count-1;i>=0;i--) {
            WClass *p=(WClass*)[protocols objectAtIndex:i];
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


























@implementation WClass
@synthesize name,superType,varNames,vars,fns,varPatterns,fnNames,isProtocol,isType,isSys,hasDef,isWIOnly;
@synthesize ownedNum,ownsNum;

- (void)dealloc {
    self.name=nil;
    self.superType=nil;
    self.varPatterns=nil;
    self.fns=self.vars=nil;
    self.varNames=self.fnNames=nil;
    }
- (id)initClassWithName:(NSString*)aname superClass:(WClass*)superClass protocolList:(NSArray*)protocolList varPatterns:(NSSet *)avarPatterns {
    if (!(self=[super init])) return(nil);
    self.name=aname;
    hasDef=NO;
    self.superType=[[WType alloc] initWithClass:superClass protocols:protocolList addObject:NO];
    self.varPatterns=avarPatterns.copy;
    if ([name rangeOfString:@"__WIClass__"].location!=NSNotFound) {
        self.varPatterns=[[[(self.varPatterns?self.varPatterns:[NSSet set]) setByAddingObject:@"nac"] setByAddingObject:@"multi"] setByAddingObject:@"undefined"];
    }
    self.vars=[NSMutableDictionary dictionary];
    self.fns=[NSMutableDictionary dictionary];
    [[WClasses getDefault].classes setObject:self forKey:aname];
    self.isProtocol=NO;
    self.isSys=self.isType=self.isWIOnly=NO;
    _depth=iNSNotFound;
    return(self);
}

- (id)initProtocolWithName:(NSString*)aname superList:(NSArray *)asuperList varPatterns:(NSSet*)avarPatterns {
    if (!(self=[super init])) return(nil);
    self.name=aname;
    hasDef=NO;
    self.superType=[[WType alloc] initWithClass:nil protocols:asuperList addObject:NO];
    self.varPatterns=avarPatterns.copy;
    //if ([name isEqualToString:@"Object"]||[name isEqualToString:@"Globals"]) {
    //    self.varPatterns=[[[(self.varPatterns?self.varPatterns:[NSSet set]) setByAddingObject:@"nac"] setByAddingObject:@"multi"] setByAddingObject:@"undefined"];
    //}
    self.vars=[NSMutableDictionary dictionary];
    self.fns=[NSMutableDictionary dictionary];
    [[WClasses getDefault].protocols setObject:self forKey:aname];
    self.isProtocol=YES;
    self.isSys=self.isType=self.isWIOnly=NO;
    _depth=iNSNotFound;
    return(self);
}

+ (WClass*)getClassWithName:(NSString *)aname {
    return([WClass getClassWithName:aname superClass:nil protocolList:nil varPatterns:nil]);
}
+ (WClass*)getProtocolWithName:(NSString *)aname {
    return([WClass getProtocolWithName:aname superList:nil varPatterns:nil]);
}

+ (WClass*)getClassWithName:(NSString *)aname superClass:(WClass*)superClass protocolList:(NSArray*)protocolList varPatterns:(NSSet *)avarPatterns {
    WClass *ret=[[WClasses getDefault].classes objectForKey:aname];
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
    WClass *ret=[[WClasses getDefault].protocols objectForKey:aname];
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
        if ([p hasPrefix:@"fn:"]) return([p substringFromIndex:@"fn:".length]);
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
    return([[[WType alloc] initWithClass:[WClass getClassWithName:altypec] protocols:altypeps.allObjects addObject:NO] autorelease]);
}


+(NSString*)objCTypeWithClass:(WClass*)type_class protocols:(NSSet*)type_protocols stars:(int)stars {
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

- (int)depthWithStack:(NSMutableSet *)stack {
    if (!stack) stack=[NSMutableSet set];
    if (_depth==iNSNotFound) {
        if ([stack containsObject:self]) {
            NSMutableString *s=[NSMutableString string];
            for (WClass *c in stack) [s appendFormat:@"%@ ",c.name];
            [WClasses error:[NSString stringWithFormat:@"Circular super structure involving : %@",s] withToken:nil context:nil];
            _depth=0;
        }
        else {
            [stack addObject:self];
            int maxch=-1;
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
- (int)depth {
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
        WVar *v=[self.vars objectForKey:n];
        if ([v respondsToSelector:sel]) {
            [v performSelector:sel withObject:s];
        }
    }    
    for (NSString *n in self.fnNames) {
        WFn *fn=[self.fns objectForKey:n];
        if ([fn respondsToSelector:sel]) {
            [fn performSelector:sel withObject:s];
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
        
            int stars=0;
            WVar *v2=[WVar getVarWithType:[WClasses processClassType:v.type class:forClas protocols:stack tostars:&stars]
                stars:v.stars+stars
                name:[WClasses processClassString:v.name class:forClas protocols:stack]
                qname:[WClasses processClassString:v.qname class:forClas protocols:stack]
                defVal:[WClasses processClassString:v.defaultValue class:forClas protocols:stack]
                defValLevel:v.defLevel attributes:attrs clas:forClas];
            v2.useLocationsFrom=v.useLocationsFrom;
            for (NSString *fn in v.inFilesLocations) {
                for (NSValue *vv in (NSSet*)[v.inFilesLocations objectForKey:fn]) {
                    [v2 addInFilename:fn line:(int)vv.rangeValue.location column:(int)vv.rangeValue.length];
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
            for (NSValue *vv in (NSSet*)[fn.inFilesLocations objectForKey:fname]) {
                [fn2 addInFilename:fname line:(int)vv.rangeValue.location column:(int)vv.rangeValue.length];
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
                    objectClass=[[WClasses getDefault].protocols objectForKey:@"Object"];
                    if (objectClass) {
                        [objectClass addProtocolToClass:self included:included stack:[NSMutableArray array]];
                        [self.superType.protocols addObject:objectClass];
                    }
                }
                else {
                    objectClass=[[WClasses getDefault].protocols objectForKey:@"DerivedObject"];
                    if (objectClass) {
                        [objectClass addProtocolToClass:self included:included stack:[NSMutableArray array]];
                        [self.superType.protocols addObject:objectClass];
                    }
                }
            }
            if (![varPatterns containsObject:@"-Object"]) {
                WClass *classClass=[[WClasses getDefault].protocols objectForKey:@"ClassObject"];
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
    return([[[WType alloc] initWithClass:(self.isProtocol?nil:self) protocols:(self.isProtocol?[NSArray arrayWithObject:self]:nil) addObject:NO] autorelease]);
}

//@synthesize name,superType,varNames,vars,fns,varPatterns,fnNames,isProtocol,isType,isSys,hasDef,isWIOnly;

-(NSString*)tag {return([NSString stringWithFormat:(isProtocol?@"protocol_%@":@"class_%@"),name]);}


-(void)addjsvars:(NSMutableDictionary*)dict {
    NSMutableString *val=[NSMutableString stringWithString:@"<ul>"];
    if (self.superType.clas) {
        NSString *n=[NSString stringWithFormat:@"super_%@",self.superType.clas.tag];
        [val appendFormat:@"<li><span style='color:blue' onclick=\"classclick('PATH_%@_own','%@','own')\">%@</span>",n,self.superType.clas.tag,[WClasses htmlStringForString:self.superType.clas.wType.wiType]];
        [val appendFormat:@"<span style='color:blue' onclick=\"classclick('PATH_%@_info','%@','info')\"> -- (info)</span><span id='PATH_%@_info'></span><span id='PATH_%@_own'></<span>",n,self.superType.clas.tag,n,n];
        [val appendFormat:@"</li>"];
    }
    for (WClass *p in self.superType.protocols) {
        NSString *n=[NSString stringWithFormat:@"prot_%@",p.tag];
        [val appendFormat:@"<li><span style='color:blue' onclick=\"classclick('PATH_%@_own','%@','own')\">%@</span>",n,p.tag,[WClasses htmlStringForString:p.wType.wiType]];
        [val appendFormat:@"<span style='color:blue' onclick=\"classclick('PATH_%@_info','%@','info')\"> -- (info)</span><span id='PATH_%@_info'></span><span id='PATH_%@_own'></<span>",n,p.tag,n,n];
        [val appendFormat:@"</li>"];
    }
    [val appendString:@"</ul>"];
//    [dict setObject:val forKey:[self.tag stringByAppendingString:@"_super"]];
    
//    val=[NSMutableString stringWithString:@"<ul>"];
    [val appendString:@"<ul>"];
    for (NSString *vn in varNames) {
        WVar *v=[vars objectForKey:vn];
        if (!(v.type.clas.isSys||!v.retains)) {
            NSString *n=[NSString stringWithFormat:@"own_var_%@",vn];
            [val appendFormat:@"<li><span style='color:blue' onclick=\"classclick('PATH_%@_own','%@','own')\">%@</span> %@",n,v.type.clas.tag,[WClasses htmlStringForString:v.type.clas.wType.wiType],[WClasses htmlStringForString:v.name]];
            if (v.defaultValue) [val appendFormat:@"=%@",[WClasses htmlStringForString:v.defaultValue]];
            if (v.attributes) {
                [val appendFormat:@" ("];
                for (NSString *a in v.attributes) [val appendFormat:@" %@",[WClasses htmlStringForString:a]];
                [val appendFormat:@" )"];
            }
            [val appendFormat:@"<span style='color:blue' onclick=\"classclick('PATH_%@_info','%@','info')\"> -- (info)</span><span id='PATH_%@_info'></span><span id='PATH_%@_own'></<span>",n,v.type.clas.tag,n,n];
            [val appendFormat:@"</li>"];
        }
    }
    for (WProp *p in [WClasses getDefault].props) {
        if (p.myclas==self) {
            NSString *n=[NSString stringWithFormat:@"myprop_%@",p.hisname];
            [val appendFormat:@"<li>as %@",p.myname];
            if (p.myqname) [val appendFormat:@">>%@",p.myqname];
            [val appendFormat:@" %@ <span style='color:blue' onclick=\"classclick('PATH_%@_own','%@','own')\">%@</span> %@",[WClasses htmlStringForString:p.origType],n,p.hisclas.tag,[WClasses htmlStringForString:p.hisclas.wType.wiType],p.hisname];
            if (p.hisqname) [val appendFormat:@">>%@",p.hisqname];
            [val appendFormat:@"<span onclick=\"classclick('PATH_%@_info','%@','info')\"> -- (info)</span><span id='PATH_%@_info'></span><span id='PATH_%@_own'></<span>",n,p.hisclas.tag,n,n];
            [val appendFormat:@"</li>"];
        }
        if (p.hisclas==self) {
            NSString *n=[NSString stringWithFormat:@"hisprop_%@",p.myname];
            [val appendFormat:@"<li>as %@",p.hisname];
            if (p.hisqname) [val appendFormat:@">>%@",p.hisqname];
            [val appendFormat:@" %@ <span style='color:blue' onclick=\"classclick('PATH_%@_own','%@','own')\">%@</span> %@",[WClasses htmlStringForString:p.origType],n,p.myclas.tag,[WClasses htmlStringForString:p.myclas.wType.wiType],p.myname];
            if (p.myqname) [val appendFormat:@">>%@",p.myqname];
            [val appendFormat:@"<span onclick=\"classclick('PATH_%@_info','%@','info')\"> -- (info)</span><span id='PATH_%@_info'></span><span id='PATH_%@_own'></<span>",n,p.myclas.tag,n,n];
            [val appendFormat:@"</li>"];
        }
    }
    [val appendFormat:@"</ul>\n"];
    [dict setObject:val forKey:[self.tag stringByAppendingString:@"_own"]];
    //[dict setObject:@"jj" forKey:[self.tag stringByAppendingString:@"_own"]];
    
    [dict setObject:self.infoStr forKey:[self.tag stringByAppendingString:@"_info"]];


    val=[NSMutableString stringWithFormat:@"<span style='color:blue' onclick=\"classclick('PATH_own','%@','own')\">%@</span><span onclick=\"classclick('PATH_info','%@','info')\">(info)</span><span id='PATH_info'></span><span id='PATH_own'></<span>",self.tag,[WClasses htmlStringForString:self.wType.wiType],self.tag];
    [dict setObject:val forKey:[self.tag stringByAppendingString:@"_."]];
}
    

-(NSString*)infoStr {
    NSMutableString *ret=[NSMutableString stringWithFormat:@"%@%@",isSys?@"sys ":@"",isType?@"type ":@""];
    for (NSString *p in varPatterns) [ret appendFormat:@"'%@' ",p];
    if (varNames.count) {
        [ret appendFormat:@"<ul>"];
        for (NSString *n in varNames) {
            WVar *v=[vars objectForKey:n];
            if (v.type.clas.isSys||!v.retains) {
                [ret appendFormat:@"<li>%@ %@",[WClasses htmlStringForString:v.type.wiType],v.localizedVarName];
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
            WFn *fn=[fns objectForKey:n];
            [ret appendFormat:@"<li>%@</li>\n",[WClasses htmlStringForString:fn.sig]];
        }
        [ret appendFormat:@"</ul>\n"];
    }
    return(ret);
}
-(void)addOwnership {
    [self getNames];
    ownsNum=0;
    for (NSString *n in varNames) {
        WVar *v=[vars objectForKey:n];
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
    if ([tags objectForKey:[self tag]]) return(andName?[tags objectForKey:[self tag]]:@"");
    [tags setObject:[NSString stringWithFormat:@"<b>%@</b>",name] forKey:[self tag]];

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
        WVar *v=[vars objectForKey:n];
        if (!(v.type.clas.isSys||!v.retains)) {
            [ret appendFormat:@"<li><b>%@</b> %@",[WClasses htmlStringForString:v.type.wiType],v.localizedVarName];
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
            WVar *v=[self.vars objectForKey:k];
            [s appendFormat:(s.length?@"|%@":@"%@"),[NSRegularExpression escapedPatternForString:v.localizedName]];
        }
        getterSetterRE=[[NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"(?<![\\w\\d_\\.\\s]|->)\\s*(?:%@)(?:$|[^\\w\\d_])",s] options:0 error:&err] retain];
        if (err) {
            NSLog(@"WInterface internal error %@",err.description);
            exit(1);
        }
    }
    return(getterSetterRE);
}

@end




































@implementation WProp
@synthesize myclas,myname,hisclas,hisname,type,myqname,hisqname,origType;
- (void)dealloc {
    self.myname=self.hisname=self.type=nil;
    self.myclas=self.hisclas=nil;
    }
- (id)initWithType:(NSString*)atype origType:(NSString*)aorigType myClass:(WClass*)amyclas myName:(NSString*)amyname myQName:(NSString *)amyqname hisClass:(WClass*)ahisclas hisName:(NSString*)ahisname hisQName:(NSString *)ahisqname {
    if (!(self=[super init])) return(nil);
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
    return([[[WType alloc] initWithClass:(myclas.isProtocol?nil:myclas) protocols:(myclas.isProtocol?[NSArray arrayWithObject:myclas]:nil) addObject:NO] autorelease]);
}
-(WType*)hisWType {
    return([[[WType alloc] initWithClass:(hisclas.isProtocol?nil:hisclas) protocols:(hisclas.isProtocol?[NSArray arrayWithObject:hisclas]:nil) addObject:NO] autorelease]);
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
        NSString *ctype=nil;
        for (NSString *s in histype.clas.varPatterns) {
            if ([s hasPrefix:@"ctype:"]) {
                ctype=[s substringFromIndex:@"ctype:".length];
            }
        }
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
        [WClasses error:@"Unknown class for property" withToken:nil context:self];
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
    asig=[asig stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.sigWithArgs=asig;
    self.sig=(self.imaginary?self.sigWithArgs:NSStringFromSelector(NSSelectorFromString(asig)));
    self.body=abody;
    [(self.clas=aclas).fns setObject:self forKey:self.sig];
    return(self);
}

- (bool) imaginary {
    NSString *asig=self.sigWithArgs;
    for (int i=1;i<asig.length;i++) {
        if (![[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[asig characterAtIndex:i]]) {
            if ([asig characterAtIndex:i]!='(') return(YES);
            break;
        }
    }
    return(NO);
}

#define NONUMBER 0x80000000
+ (int)tokenMergeNumber:(WReaderTokenizer*)tk pos:(NSUInteger)pos append:(bool*)pappend retNumTokens:(int*)pnumTokens {
    if ((tk.tokens.count>=pos+1)&&[((WReaderToken*)[tk.tokens objectAtIndex:pos]).str isEqualToString:@"@"]) {
        NSUInteger p=pos+1;
        WReaderToken *t=(WReaderToken*)[tk.tokens objectAtIndex:p];
        bool append=([t.str isEqualToString:@"!"]?NO:YES);
        if (!append) t=(WReaderToken*)[tk.tokens objectAtIndex:++p];
        int sgn=([t.str isEqualToString:@"-"]?-1:1);
        if (sgn==-1) t=(WReaderToken*)[tk.tokens objectAtIndex:++p];
        if (t.type=='n') {
            p++;
            int N=atoi(t.str.UTF8String);
            if (pappend) *pappend=append;
            if (pnumTokens) *pnumTokens=(int)(p-pos);
            return(N*sgn);
        }
    }
    return(NONUMBER);
}

+ (void)getFnBlocksFromString:(NSString*)str ret:(NSMutableArray*)ret pveIndexes:(NSMutableIndexSet*)pve nveIndexes:(NSMutableIndexSet*)nve forceIndexes:(NSMutableSet*)forceIndexes {
    WReaderTokenizer *tk=[[WReaderTokenizer alloc] initWithReader:nil];
    tk.str=str;
    int n=0,sn=NONUMBER;
    NSMutableString *s=nil;
    bool append=YES,ignore=NO;
    for (NSUInteger pos=0;pos<tk.tokens.count;pos++) {
        WReaderToken *t=[tk.tokens objectAtIndex:pos];
        int numTokens;
        int tki=[WFn tokenMergeNumber:tk pos:pos append:&append retNumTokens:&numTokens];
        if (tki!=NONUMBER) {
            pos+=numTokens-1;
            n=tki;
            continue;
        }
        else if (sn!=n) {
            if ([forceIndexes containsObject:[NSNumber numberWithInt:n]]) ignore=YES;
            else {
                ignore=NO;
                sn=n;
                if (n<0) {
                    int i=0,j;
                    for (j=(int)nve.lastIndex;(j!=iNSNotFound)&&(-j<n);j=(int)[nve indexLessThanIndex:j],i++);
                    if (-j==n) s=[ret objectAtIndex:i];
                    else {
                        [ret insertObject:s=[NSMutableString string] atIndex:i];
                        [nve addIndex:-n];
                    }
                }
                else {
                    int i=(int)nve.count,j;
                    for (j=(int)pve.firstIndex;(j!=iNSNotFound)&&(j<n);j=(int)[pve indexGreaterThanIndex:j],i++);
                    if (j==n) s=[ret objectAtIndex:i];
                    else {
                        [ret insertObject:s=[NSMutableString string] atIndex:i];
                        [pve addIndex:n];
                    }
                }
            }
        }
        if (!ignore) {
            if (!append) {
                [forceIndexes addObject:[NSNumber numberWithInt:sn]];
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
    int i=0;
    NSMutableString *ret=[NSMutableString string];
    for (int j=(int)nve.lastIndex;j!=iNSNotFound;j=(int)[nve indexLessThanIndex:j]) {
        NSString *s=[ss objectAtIndex:i++];
        if (s.length) [ret appendFormat:@"@%@%d %@",[force containsObject:[NSNumber numberWithInt:-j]]?@"!":@"",-j,s];
    }
    for (int j=(int)pve.firstIndex;j!=iNSNotFound;j=(int)[pve indexGreaterThanIndex:j]) {
        NSString *s=[ss objectAtIndex:i++];
        if (s.length) {
            if (ret.length||j) [ret appendFormat:@"@%@%d %@",[force containsObject:[NSNumber numberWithInt:j]]?@"!":@"",j,s];
            else [ret appendFormat:@"%@",s];
        }
    }
    return(ret);
}

+ (WFn*)getExistingFnWithSig:(NSString *)asig clas:(WClass *)aclas {
    NSString *sig=NSStringFromSelector(NSSelectorFromString(asig));
    return([aclas.fns objectForKey:sig]);
}

+ (WFn*)getFnWithSig:(NSString*)asig body:(NSString*)abody clas:(WClass*)aclas {
    NSString *sig=NSStringFromSelector(NSSelectorFromString(asig));
    WFn *ret=[aclas.fns objectForKey:sig];
    if (!ret) return([[WFn alloc] initWithSig:asig body:abody clas:aclas]);

    ret.sigWithArgs=asig;
    if (abody) {
        if (ret.body) ret.body=[WFn mergedBody:ret.body with:abody];
        else ret.body=abody;
    }
    return(ret);
}


- (NSString*)finalSigStr:(NSString*)asig {
    asig=[asig stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange r=NSMakeRange(NSNotFound,0);
    if ([asig isEqualToString:@"-(init)"]) {
        if (clas.isProtocol) return(nil);
        asig=@"-(__Class__*)_startObjectOfClass__WIClass__";
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
    int depth=1;
    WReaderTokenizer *tkn=[[WReaderTokenizer alloc] initWithReader:nil];
    tkn.str=s;
    bool wasnl=YES,wasmk=NO;
    int level;
    for (int i=0;i<tkn.tokens.count;i++) {
        WReaderToken *t=[tkn.tokens objectAtIndex:i];
        int numTokens;
        if (wasnl) {
            NSMutableString *s=[NSMutableString string];
            for (int d=0;d<MIN(40,depth);d++) [s appendString:@"  "];
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
                tkn.tokens insertObject:[[[WReaderToken alloc] initWithTokenizer:tkn string:[NSString stringWithFormat:@"/*i%d*/",level] bracketCount:t.bracketCount linei:t.linei type:'c'] atIndex:i];
            }
            else {
                wasmk=NO;
            }
        }
        else if (t.type=='r') {wasnl=YES;wasmk=NO;}
        else if ((level=[WFn tokenMergeNumber:tkn pos:i append:nil retNumTokens:&numTokens])!=NONUMBER) {
            [tkn.tokens removeObjectsInRange:NSMakeRange(i,numTokens)];
            NSMutableString *s=[NSMutableString string];
            for (int d=0;d<MIN(40,depth);d++) [s appendString:@"  "];
            [tkn.tokens insertObject:[[WReaderToken alloc] initWithTokenizer:tkn string:@"\n" bracketCount:t.bracketCount linei:t.linei type:'r'] atIndex:i++];
            [tkn.tokens insertObject:[[WReaderToken alloc] initWithTokenizer:tkn string:s bracketCount:t.bracketCount linei:t.linei type:'z'] atIndex:i++];
            tkn.tokens insertObject:[[[WReaderToken alloc] initWithTokenizer:tkn string:[NSString stringWithFormat:@"/*i%d*/",level] bracketCount:t.bracketCount linei:t.linei type:'c'] atIndex:i];
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
    if (self.body) [s appendFormat:@"%@ {MSGSTART(\"%@:%@\")\n%@}\n",[self finalSigStr:self.sigWithArgs],clas.wType.wiType,[self finalSigStr:self.sigWithArgs],[self finalBodyStr:self.body withSig:self.sigWithArgs]];
    else [[WClasses getDefault].taskList addObject:[NSString stringWithFormat:@"Need to implement %@ :: %@",self.clas.name,self.sig]];
}




-(NSString*)bodyByReplacingSettersAndGettersInBody:(NSString*)abody {
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
    int bad=0,pos=-1;
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
            if ([t.str hasSuffix:@"ivar*/"]) {
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
                    for (int pos2=pos+1;pos2<r.tokenizer.tokens.count;pos2++) {
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
                    bool isSetter=NO,isGetter=YES,got=NO;int setterEqPos=0;
                    for (int pos2=pos+1;(pos2<r.tokenizer.tokens.count)&&!got;pos2++) {
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
                                [NSString stringWithFormat:@"/*setter*/(*&%@)",v.localizedVarName]:
                                [NSString stringWithFormat:@" This is a Winterface issue, this property should be marked as having an ivar called %@ ",v.localizedVarName]):
                            (v.objc_readonly?
                                [NSString stringWithFormat:@"/*readonly*/(*&%@)",v.localizedVarName]:
                                (v.readonly?
                                    [NSString stringWithFormat:@"/*set*/privateaccess(self.%@",v.localizedName]:
                                    [NSString stringWithFormat:@"/*set*/self.%@",v.localizedName]
                                )
                            )
                        );
                        changed=YES;
                        if ((!isForSetterGetter)&&(!v.objc_readonly)&&v.readonly) {
                            NSMutableArray *bs=[NSMutableArray array];
                            bool malformed=NO;
                            bool found=NO;
                            for (int pos2=setterEqPos+1;(pos2<r.tokenizer.tokens.count);pos2++) {
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
                                [NSString stringWithFormat:@"/*getter*/(*&%@)",v.localizedVarName]:
                                [NSString stringWithFormat:@"/*get*/(*&%@)",v.localizedVarName]):
                            [NSString stringWithFormat:@"/*get*/self.%@",v.localizedName]);
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
}





@end





















@implementation WVar
@synthesize clas,type,name,qname,defaultValue,attributes,stars,defLevel,setterArg,localizedType,localizedName;
- (void)dealloc {
    self.type=nil;
    self.name=self.defaultValue=nil;
    self.attributes=nil;
    self.clas=nil;
    }



+(NSComparisonResult)compareName:(NSString*)n1 withName:(NSString*)n2 {
    NSComparisonResult res=[n1 compare:n2 options:NSCaseInsensitiveSearch];
    return(res);
}


- (id)initWithType:(WType*)atype stars:(int)astars name:(NSString*)aname qname:(NSString*)aqname defVal:(NSString*)adefaultValue defValLevel:(int)adefLevel attributes:(NSSet*)aattributes clas:(WClass*)aclas {
    if (!(self=[super init])) return(nil);
    self.type=[[WType alloc] initWithClass:atype.clas protocols:atype.protocols.allObjects addObject:NO];
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
    [(self.clas=aclas).vars setObject:self forKey:self.name];
    return(self);
}
+ (WVar*)getVarWithType:(WType*)atype stars:(int)astars name:(NSString *)aname qname:(NSString*)aqname defVal:(NSString *)adefaultValue defValLevel:(int)adefLevel attributes:(NSSet *)aattributes clas:(WClass *)aclas {
    WVar *ret=[aclas.vars objectForKey:aname];
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
    return([aclas.vars objectForKey:aname]);
}

+ (NSString*)escapeCString:(NSString*)s {
    return([WProp string:s replacePairs:@"\\",@"\\\\",@"\r",@"\\r",@"\t",@"\\t",@"\"",@"\\\"",@"\n",@"\\n\"\n            \"",nil]);
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

    int bad=0,pos=-1;
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
            if ((bad<=0)&&[t.str isEqualToString:self.localizedName]) {
                bad=0;
                bool isSetter=NO,isGetter=YES,got=NO;
                for (int pos2=pos+1;(pos2<r.tokenizer.tokens.count)&&!got;pos2++) {
                    WReaderToken *t2=[r.tokenizer.tokens objectAtIndex:pos2];
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
    return([localizedType.clas.varPatterns containsObject:@"retains"]||((!self.isType)&&(stars<=1)));
}



-(void)cacheAttributes {
    if (attributesCached) return;
    [self imaginary];
    [self retains];
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
        [WClasses note:((NSDictionary*)[NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:imaginary],@"imaginary",
            [NSNumber numberWithBool:retains],@"retains",
            [NSNumber numberWithBool:isType],@"isType",
            [NSNumber numberWithBool:modelretains],@"modelRetains",
            [NSNumber numberWithBool:readonly],@"readonly",
            [NSNumber numberWithBool:atomic],@"atomic",
            [NSNumber numberWithBool:synthesized],@"synthesized",
            [NSNumber numberWithBool:objc_readonly],@"objc_readonly",
            [NSNumber numberWithBool:needsGetter],@"needsGetter",
            [NSNumber numberWithBool:needsSetter],@"needsSetter",
            [NSNumber numberWithBool:hasIVar],@"hasIVar",
            [NSNumber numberWithBool:hasDefaultValue],@"hasDefaultValue",
            [NSNumber numberWithBool:justivar],@"justivar",
            [NSNumber numberWithBool:hasGetter],@"hasGetter",
            [NSNumber numberWithBool:hasSetter],@"hasSetter",
            setterName,@"setterName",
            getterName,@"getterName",
            setterSig,@"setterSig",
            getterSig,@"getterSig",
            localizedSetterName,@"localizedSetterName",
            localizedGetterName,@"localizedGetterName",
            localizedSetterSig,@"localizedSetterSig",
            localizedGetterSig,@"localizedGetterSig",
            localizedVarName,@"localizedVarName",
            [NSNumber numberWithBool:self.tracked],@"tracked",
        nil]).description withToken:nil context:self];
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
    return([(__name=ret) retain]); \
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
    ret=self.retainable&&(![attributes containsObject:@"assign"])&&(self.hasIVar||self.superHasIVar);
)
CACHEVARATTRFN(bool,imaginary,
    ret=[attributes containsObject:@"imaginary"];
)
CACHEVARATTRFN(bool,isType,
    ret=self.localizedType.clas.isType;
)
CACHEVARATTRFN(bool,modelretains,
    ret=[attributes containsObject:@"modelretain"];
)
CACHEVARATTRFN(bool,readonly,
    ret=((![clas.varPatterns containsObject:@"-Object"])&&[attributes containsObject:@"publicreadonly"])||self.objc_readonly;
)
CACHEVARATTRFN_retain(WFn*,hasGetter,
    ret=[clas.fns objectForKey:[self getterSig]];
)
CACHEVARATTRFN_retain(WFn*,hasSetter,
    ret=[clas.fns objectForKey:[self setterSig]];
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
                    WVar *v=[sup.vars objectForKey:k];
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
        if ([self hasSettersAndGettersInBody:((WFn*)[clas.fns objectForKey:[self getterSig]]).body hasSetter:nil hasGetter:nil]||[self hasSettersAndGettersInBody:((WFn*)[clas.fns objectForKey:[self setterSig]]).body hasSetter:nil hasGetter:nil]) {ret=YES;break;}
    } while (NO);
)


CACHEVARATTRFN(bool,superHasIVar,
    NSString *vv=self.localizedVarName;
    if (vv) {
        for (WClass *sup=self.clas.superType.clas;sup;sup=sup.superType.clas) {
            for (NSString *k in sup.vars) {
                WVar *v=[sup.vars objectForKey:k];
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
        NSMutableString *body=[((WFn*)[clas.fns objectForKey:[self getterSig]]).body.mutableCopy autorelease];
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
        ret=[WFn mergedBody:body with:@""].mutableCopy;
    }
)

CACHEVARATTRFN_retain(NSMutableString*,localizedSetterBody,
    if (self.synthesized) {
        NSMutableString *body=[((WFn*)[clas.fns objectForKey:[self setterSig]]).body.mutableCopy autorelease];
        if (!body) {
            NSString *vv=self.localizedVarName;
            body=(self.hasIVar?
                    (self.retains?
                        (!self.atomic?
                            [NSMutableString stringWithFormat:
                                @"@-905 if(!memcmp(&%@,&%@,sizeof(%@)))return;@-900 {[(id)%@ release];%@=[(id)%@ retain];}",vv,self.setterArg,self.setterArg,vv,vv,self.setterArg]:
                            [NSMutableString stringWithFormat:
                                @"@-905 @synchronized(self) {@-904 if(%@==%@)return;@-900 {[(id)%@ release];%@=[(id)%@ retain];}@-895}",vv,self.setterArg,vv,vv,self.setterArg]):
                        (!self.atomic?
                            [NSMutableString stringWithFormat:
                                @"@-905 if(!memcmp(&%@,&%@,sizeof(%@)))return;@-900 memcpy(&%@,&%@,sizeof(%@));",vv,self.setterArg,vv,vv,self.setterArg,vv]:
                            [NSMutableString stringWithFormat:
                                @"@-905 @synchronized(self) {@-904 if(!memcmp(&%@,&%@,sizeof(%@)))return;memcpy(&%@,&%@,sizeof(%@));@-895}",vv,self.setterArg,vv,vv,self.setterArg,vv])):
                    [NSMutableString stringWithFormat:@""]);
        }
        
        if (self.readonly) {
            [body appendFormat:@"@-1999 if (!authorized_thread(__private_access_thread_mask_in___ClassName__)) ERR(\"Attempt to set public-readonly property in unauthorized thread (please try something like privateaccess(%@=\\\"blah\\\") to set the property)\");\n",self.localizedName];
        }
        
        if (self.tracked) {
            [body appendFormat:@"@-850 REMOVEOWNER(%@,self);ADDOWNER(%@,self);",self.localizedVarName,self.setterArg];
        }
        ret=[WFn mergedBody:body with:@""].mutableCopy;
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
        r2.fileString=[WProp string:[[WClasses getDefault].propFiles objectForKey:[NSString stringWithFormat:(self.localizedType.clas.isType?@"T%c":@"NS%c"),[self varType]]] withMyType:self.clas.wType myName:@"self" iamOwner:NO myQName:@"" hisType:self.localizedType hisName:self.localizedName heIsOwner:YES hisQName:self.qname qprop:@"" noPlurals:YES];
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
                int rc=0;
                bool wasrelease=NO,wasretain=NO;
                bool wascopy=NO;
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
                    while(rc>1) {
                        rc--;
                        defaultValue=[NSString stringWithFormat:@"[(id)%@ release]",defaultValue];
                    }
                    while(rc>0) {
                        rc--;
                        defaultValue=[NSString stringWithFormat:@"[(id)%@ autorelease]",defaultValue];
                    }
                    [WClasses note:[NSString stringWithFormat:@"Suspected positive reference count in default value. The value has been changed to %@",defaultValue] withToken:nil context:self];
                }
            }
            [WFn getFnWithSig:@"-(init)" body:[NSString stringWithFormat:@"@-500 /*ivar*/%@=(%@);%@\n",self.localizedVarName,(self.retains?[NSString stringWithFormat:@"[(id)(%@) retain]",defaultValue]:defaultValue),(self.tracked?[NSString stringWithFormat:@"  ADDOWNER(%@,self);",self.localizedVarName]:@"")] clas:clas];
        }
    }
    else if (attributes) {
        NSMutableString *def=[NSMutableString string];
        if (!def.length) for (NSString *s in attributes) {
            if ([s hasPrefix:@"-"]||[s hasPrefix:@"+"]) {
                WFn *fn=[clas.fns objectForKey:s];
                if (!fn) [WClasses error:[NSString stringWithFormat:@"Expected function with signature %@ for var %@",s,localizedName] withToken:nil context:self];
                else {
                    [def appendFormat:@"[NSDictionary dictionaryWithObjectsAndKeys:@\"%@\",@\"signature\",@\"%@\",@\"body\",nil]",s,[WVar escapeCString:[WFn balance:fn.body]]];
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
            [WFn getFnWithSig:@"-(init)" body:[NSString stringWithFormat:@"@-500         /*ivar*/%@=[(id)%@ retain];\n",localizedVarName,def] clas:clas];
        }
    }
    if (self.hasIVar&&!(hasDef||self.imaginary)) {
        [WClasses warning:[NSString stringWithFormat:@"Non-imaginary variable %@ has an ivar, but no default value. This is less a strict error than unclean",self.localizedName] withToken:nil context:self];
    }

    if (self.retains&&self.hasIVar) {
        [WFn getFnWithSig:@"-(void)dealloc" body:(self.tracked?[NSString stringWithFormat:@"\n    REMOVEOWNER(%@,self);[(id)%@ release];%@=nil;",self.localizedVarName,self.localizedVarName,self.localizedVarName]:[NSString stringWithFormat:@"\n    [(id)%@ release];%@=nil;",self.localizedVarName,self.localizedVarName]) clas:clas];
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
        !self.retainable?@"":(self.retains?@"retain,":@"assign,"),
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


















@implementation WPotentialType
@synthesize clas,protocols;

- (void)dealloc {
    self.clas=nil;
    self.protocols=nil;
    }

-(WPotentialType*)initWithType:(WType*)t {
    if (!(self=[super init])) return(nil);
    self.clas=(t.clas?t.clas.name:nil);
    self.protocols=(t.protocols?[NSMutableSet set]:nil);
    if (t.protocols) for (WClass *c in t.protocols) [self.protocols addObject:c.name];
    return(self);
}

-(WPotentialType*)initWithClass:(NSString*)aclas protocols:(NSArray*)aprotocols addObject:(bool)addObject {
    if (!(self=[super init])) return(nil);
    self.clas=nil;
    self.protocols=(addObject?[NSMutableSet setWithObject:@"Object"]:nil);
    [self addClass:aclas protocols:aprotocols];
    return(self);
}
-(void)addClass:(NSString*)aclas protocols:(NSArray*)aprotocols {
    if (aclas) {
        if ((!self.clas)||[self.clas isEqualToString:@"NSObject"]) {
            self.clas=aclas;
        }
    }
    if (aprotocols&&aprotocols.count) {
        if (!(self.protocols&&[[aprotocols objectAtIndex:0] isKindOfClass:[NSString class]]&&
        ([[aprotocols objectAtIndex:0] isEqualToString:@"-"]||[[aprotocols objectAtIndex:0] isEqualToString:@"+"]))) {
            self.protocols=[NSMutableSet set];
        }
        bool adding=YES;
        for (NSObject *o in aprotocols) {
            if ([o isKindOfClass:[NSString class]]) {
                if ([(NSString*)o isEqualToString:@"+"]) adding=YES;
                else if ([(NSString*)o isEqualToString:@"-"]) adding=NO;
                else if (adding) [self.protocols addObject:o];
                else [self.protocols removeObject:o];
            }
        }
    }
}


@end






@implementation WType
@synthesize clas,protocols,_potentialType;

- (void)dealloc {
    self.clas=nil;
    self.protocols=nil;
    }

-(WPotentialType*)potentialType {
    if (!self._potentialType) self._potentialType=[[WPotentialType alloc] initWithType:self];
    return(self._potentialType);
}

-(WClass*)someWClass {
    if (self.clas) return(self.clas);
    if (self.protocols) for (WClass *c in self.protocols) return(c);
    return(nil);
}

-(WType*)initWithPotentialType:(WPotentialType*)pt {
    if (!(self=[super init])) return(nil);
    self.clas=(pt.clas?[WClass getClassWithName:pt.clas]:nil);
    self.protocols=(pt.protocols?[NSMutableSet set]:nil);
    if (pt.protocols) for (NSString *s in pt.protocols) [self.protocols addObject:[WClass getProtocolWithName:s]];
    return(self);
}
-(WType*)initWithClass:(WClass*)aclas protocols:(NSArray*)aprotocols addObject:(bool)addObject {
    if (!(self=[super init])) return(nil);
    self.clas=nil;
    self.protocols=(addObject?[NSMutableSet setWithObject:[WClass getProtocolWithName:@"Object"]]:nil);
    [self addClass:aclas protocols:aprotocols];
    return(self);
}
-(void)addClass:(WClass*)aclas protocols:(NSArray*)aprotocols {
    if (aclas) {
        if ((!self.clas)||[self.clas.name isEqualToString:@"NSObject"]) {
            self.clas=aclas;
        }
    }
    if (aprotocols&&aprotocols.count) {
        if (!(self.protocols&&[[aprotocols objectAtIndex:0] isKindOfClass:[NSString class]])) {
            self.protocols=[NSMutableSet set];
        }
        bool adding=YES;
        for (NSObject *o in aprotocols) {
            if ([o isKindOfClass:[NSString class]]) {
                if ([(NSString*)o isEqualToString:@"+"]) adding=YES;
                else if ([(NSString*)o isEqualToString:@"-"]) adding=NO;
            }
            else if ([o isKindOfClass:[WClass class]]) {
                if (adding) [self.protocols addObject:o];
                else [self.protocols removeObject:o];
            }
        }
    }
}


-(NSString*)wiType {
    WClass *c=self.clas;
    if (self.protocols.count) {
        if ([c.name isEqualToString:@"NSObject"]) c=nil;
    }
    else if (!c) c=[WClass getClassWithName:@"NSObject"];
    NSMutableString *s=[NSMutableString string];
    if (c) [s appendString:c.name];
    if (self.protocols.count) {
        bool fst=YES;
        for (WClass *p in self.protocols) {
            [s appendFormat:(fst?@"<%@":@",%@"),p.name];
            fst=NO;
        }
        [s appendString:@">"];
    }
    return(s);
}

-(NSString*)objCTypeWithStars:(int)stars {
    return([WType objCTypeWithClass:self.clas protocols:self.protocols stars:stars]);
}

+(NSString*)objCTypeWithClass:(WClass*)clas protocols:(NSSet*)protocols stars:(int)stars {
    NSMutableString *s=[NSMutableString stringWithString:(clas?clas.name:@"NSObject")];
    if (protocols.count) {
        bool fst=YES;
        for (WClass *p in protocols) {
            [s appendFormat:(fst?@"<%@":@",%@"),p.name];
            fst=NO;
        }
        [s appendString:@">"];
    }
    if (!(stars||clas.isType)) stars=1;
    for (int i=0;i<stars;i++) [s appendString:@"*"];
    return(s);
}

@end




