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


-(void)addInFilename:(NSString*)fn line:(Int)line column:(Int)column {
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

+(void)addInFilename:(NSString*)fn line:(Int)line column:(Int)column format:(NSString*)format,... {
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
// NOTE: hjf


+(void)clearMarksFromFiles:(NSArray*)fns {
    NSError *err=nil;
    //NSRegularExpression *re=[NSRegularExpression regularExpressionWithPattern:@"/\\*\\*\\!.*?\\!\\*\\*/\\s*\n" options:NSRegularExpressionDotMatchesLineSeparators error:&err];
    //if (err||!re) {
    //    NSLog(@"Bad re : /\\*\\*\\!.*?\\!\\*\\*/\\s*");
    //    return;
    //}
    //NSString *reg=@"WI_(?:ERROR|note)\\((?:\\s*+\"(?:\\\\\\\\|\\\\\"|[^\"])*+\")*+\\s*+\\)\n";
    NSString *reg=@"(?<=^|\n)//(?: \\!\\!\\!| \\?\\?\\?| MARK)?:WI:[^\n]*+\n";
    NSRegularExpression *re=[NSRegularExpression regularExpressionWithPattern:reg options:0 error:&err];
    if (err||!re) {
        NSLog(@"%@",reg);
        return;
    }
    for (NSString *fn in fns) {
        NSMutableString *s=((NSString*)[NSString stringWithContentsOfFile:fn encoding:NSASCIIStringEncoding error:&err]).mutableCopy;
        if (s&&!err) {
            NSUInteger c=[re replaceMatchesInString:s options:0 range:NSMakeRange(0,s.length) withTemplate:@""];
            if ([fn isEqualToString:@"sample.wi"]) {
            }
            if (c) {
                //dprnt("Replaced %d matches in %s\n",(Int)c,fn.UTF8String);
                [s writeToFile:fn atomically:YES encoding:NSASCIIStringEncoding error:&err];
                if (err) {
                    NSLog(@"Could not write %@ to clear marks",fn);
                }
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
        [lns addObject:[NSNumber numberWithInteger:0]];
        char buf[10000];
        Int offs=0;
        while (YES) {
            Int N=(Int)fread(buf, 1, 10000, fil);
            for (Int offs2=0;offs2<N;offs++,offs2++) {
                if (buf[offs2]=='\n') [lns addObject:[NSNumber numberWithInteger:offs+1]];
            }
            if (feof(fil)||!N) break;
        }
        Int sz=(Int)ftell(fil);
        
        NSDictionary *msgd=[locations objectForKey:fn];
        NSArray *a=[msgd.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSRange r1=((NSValue*)obj1).rangeValue;
                NSRange r2=((NSValue*)obj2).rangeValue;
                return((r1.location<r2.location)||((r1.location==r2.location)&&(r1.length<r2.length))?NSOrderedAscending:
                ((r1.location>r2.location)||((r1.location==r2.location)&&(r1.length>r2.length))?NSOrderedDescending:NSOrderedSame));
            }
        ];

        for (Int i=(Int)a.count-1;i>=0;i--) {
            NSRange r=((NSValue*)[a objectAtIndex:i]).rangeValue;
            NSArray *msgs=[msgd objectForKey:[a objectAtIndex:i]];
            if (!msgs.count) continue;
            
            Int ln=(Int)r.location;
            //Int col=(Int)r.length;
            Int errCount=0,warnCount=0,noteCount=0;
            for (NSString *msg2 in msgs) {
                if ([msg2 hasPrefix:@"!"]) errCount++;
                else if ([msg2 hasPrefix:@"?"]) warnCount++;
                else noteCount++;
            }
            NSMutableString *msg=[NSMutableString new];
            if (errCount) {
                //[msg appendString:@"WI_ERROR(  "];
                for (NSString *msg2 in msgs) if ([msg2 hasPrefix:@"!"]) {
                    [msg appendFormat:@"// !!!:WI: %@\n",[[msg2 substringFromIndex:1] stringByReplacingOccurrencesOfString:@"\n" withString:@"     ---     "]];
                    //[msg appendFormat:@"\"%@\"%@",
                    //    [msg2 stringByReplacingPairs:
                    //        @"/*",@" / * ",
                    //        @"*/",@" * / ",
                    //        @"//",@" / / ",
                    //        @"\"",@"\\\"",
                    //        @"\\",@"\\\\",
                    //        nil],
                    //    (--errCount?@"\n          ":@"    )\n")
                    //];
                }
            }

            if (warnCount) {
                //[msg appendString:@"WI_ERROR(  "];
                for (NSString *msg2 in msgs) if ([msg2 hasPrefix:@"?"]) {
                    [msg appendFormat:@"// ???:WI: %@\n",[[msg2 substringFromIndex:1] stringByReplacingOccurrencesOfString:@"\n" withString:@"     ---     "]];
                    //[msg appendFormat:@"\"%@\"%@",
                    //    [msg2 stringByReplacingPairs:
                    //        @"/*",@" / * ",
                    //        @"*/",@" * / ",
                    //        @"//",@" / / ",
                    //        @"\"",@"\\\"",
                    //        @"\\",@"\\\\",
                    //        nil],
                    //    (--warnCount?@"\n          ":@"    )\n")
                    //];
                }
            }

            if (noteCount) {
//                [msg appendString:@"WI_note(  "];
                for (NSString *msg2 in msgs) if (!([msg2 hasPrefix:@"!"]||[msg2 hasPrefix:@"?"])) {
                    [msg appendFormat:@"// MARK:WI: %@\n",[msg2 stringByReplacingOccurrencesOfString:@"\n" withString:@"     ---     "]];
                    //[msg appendFormat:@"\"%@\"%@",
                    //    [msg2 stringByReplacingPairs:
                    //        @"/*",@" / * ",
                    //        @"*/",@" * / ",
                    //        @"//",@" / / ",
                    //        @"\\",@"\\\\",
                    //        @"\"",@"\\\"",
                    //        nil],
                    //    (--noteCount?@"\n          ":@"    )\n")
                    //];
                }
            }
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

+(NSArray*)subsetOfInFiles:(NSArray*)inFiles inFile:(NSString*)fn atLine:(Int)ln column:(Int)col {
    NSMutableArray *ret=[NSMutableArray array];
    for (InFiles *v in inFiles) {
        if ([(NSSet*)[v.inFilesLocations objectForKey:fn] containsObject:[NSValue valueWithRange:NSMakeRange(ln,col)]]) [ret addObject:v];
    }
    return(ret);
}

+(void)insertData:(NSData*)d intoFile:(FILE*)fil at:(Int)offs {
    fseek(fil, 0, SEEK_END);
    Int sz=(Int)ftell(fil),i;
    char buf[10000];
    for (i=sz-10000;i>=offs;i-=10000) {
        fseek(fil, i, SEEK_SET);
        fread(buf,1,10000,fil);
        fseek(fil, i+d.length, SEEK_SET);
        fwrite(buf,1,10000,fil);
    }
    if (i<offs) {
        Int len=10000+i-offs;
        fseek(fil, offs, SEEK_SET);
        fread(buf,1,len,fil);
        fseek(fil, offs+d.length, SEEK_SET);
        fwrite(buf,1,len,fil);
    }
    fseek(fil, offs, SEEK_SET);
    fwrite(d.bytes,1,d.length,fil);
}
    



@end


