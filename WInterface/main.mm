//
//  main.m
//  WInterface
//
//  Created by Will Smart on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define MAINCPPFILE
#define CPPFILE
#include "Headers.h"


void testParse() {
    ((id<ParseClass>)Parse.class).rulesFilename=@"rules.txt";

    efil=FOpen("run.txt", "wb");
    NSError *err=nil;
    NSString *prog=[NSString stringWithContentsOfFile:@"graph.txt" encoding:NSUTF8StringEncoding error:&err];
    if (!prog) prog=@"File not found";
    NSString *json=[Parse jsonFromTokens:[Parse parse:prog] program:prog];
    [json writeToFile:@"graph.txt.json" atomically:YES encoding:NSUTF8StringEncoding error:&err];

    FClose(efil);
    efil=stderr;
    exit(0);
}

int main(int argc, const char * argv[])
{
    printf("Winterface 1.1001 (C)2013 Will smart HaND:)\n");

    Int ret=0;

    if ((argc>=2)&&!strcmp(argv[1],"parse")) testParse();

    @autoreleasepool {

        NSFileManager *fm=[NSFileManager defaultManager];

        NSString *baseDir=fm.currentDirectoryPath;
        
        for (Int i=(argc==1?0:1);i<argc;i++) {
            NSString *dir=(i?[NSString stringWithCString:argv[i] encoding:NSUTF8StringEncoding]:@".");
            [fm changeCurrentDirectoryPath:baseDir];
            [fm changeCurrentDirectoryPath:dir];

            NSDirectoryEnumerator *de=[fm enumeratorAtPath:@"."];
            NSString *fn;
            NSMutableArray *fns=[NSMutableArray array];
            if (argc>1) [fns addObject:[NSString stringWithCString:argv[1] encoding:NSASCIIStringEncoding]];
            else while ((fn=de.nextObject)) {
                BOOL isDir;
                if ([fn hasSuffix:@".wi"]&&[fm fileExistsAtPath:fn isDirectory:&isDir]&&!isDir) {
                    [fns addObject:fn];
                }
            }
            WClasses *cs=[WClasses getDefault];
            for (NSString *fn in fns) {
                fprintf(stderr,"\n>>%s -- ",fn.UTF8String);
                @autoreleasepool {

                    [cs clear];
                    WReader *r=[[WReader alloc] init];
                    r.tokenizer.tokenDelegate=cs;
                    [InFiles clearMarksFromFiles:@[fn]];
                    r.fileName=fn;
                    [cs read:r];
                    [cs addToFns];
                    NSSet *fns=cs.filenames;
                    
                    NSString *wiifieddir=@"wied/";
                    
                    NSError *err=nil;
                    NSString *html=cs.html,*htmlfn=[NSString stringWithFormat:@"%@.html",r.fileName];
                    [html writeToFile:[wiifieddir stringByAppendingString:htmlfn] atomically:YES encoding:NSUTF8StringEncoding error:&err];
                    printf("Wrote to file %s\n",[htmlfn cStringUsingEncoding:NSASCIIStringEncoding]);
                    
                    NSMutableString *s=[NSMutableString string];
                    [cs appendObjCToString:s iface:NO impl:NO classFilename:nil headerFilename:nil];
                    err=nil;
                    [fm changeCurrentDirectoryPath:baseDir];
                    NSString *dfn=[NSString stringWithFormat:@"%@.decl.h",r.fileName];
                    [s writeToFile:[wiifieddir stringByAppendingString:dfn] atomically:YES encoding:NSUTF8StringEncoding error:&err];
                    printf("Wrote to file %s\n",[dfn cStringUsingEncoding:NSASCIIStringEncoding]);
                    

                    NSString *hfn=[NSString stringWithFormat:@"%@.pch",r.fileName];
                    s=[NSMutableString string];
                    [cs appendObjCToString:s iface:YES impl:NO classFilename:nil headerFilename:dfn];
                    err=nil;
                    [fm changeCurrentDirectoryPath:baseDir];
                    [s writeToFile:[wiifieddir stringByAppendingString:hfn] atomically:YES encoding:NSUTF8StringEncoding error:&err];
                    printf("Wrote to file %s\n",[hfn cStringUsingEncoding:NSASCIIStringEncoding]);

                    NSString *errs=nil;
                    for (NSString *fn in fns) {
                        s=[NSMutableString string];
                        NSString *errs2=[cs appendObjCToString:s iface:NO impl:YES classFilename:fn headerFilename:nil];
                        if (!errs) errs=errs2;
                        else errs=[errs stringByAppendingString:errs2];
                        
                        err=nil;
                        [fm changeCurrentDirectoryPath:baseDir];
                        NSString *ofn=[NSString stringWithFormat:@"%@.mm",fn];
                        NSString *swas=[NSString stringWithContentsOfFile:ofn encoding:NSUTF8StringEncoding error:&err];
                        if (swas&&[swas isEqualToString:s]) {
                            printf("No change to file %s\n",[ofn cStringUsingEncoding:NSASCIIStringEncoding]);
                        }
                        else {
                            Int prefLen=(Int)[s commonPrefixWithString:swas options:0].length;
                            NSString *prefix=(swas?[NSString stringWithFormat:@"Changed from\n    [%d]\"%@\"\nis now\n    [%d]\"%@\"",(int)prefLen,[[swas substringFromIndex:prefLen] substringToIndex:(swas.length-prefLen<50?swas.length-prefLen:50)],(int)prefLen,[[s substringFromIndex:prefLen] substringToIndex:(s.length-prefLen<50?s.length-prefLen:50)]]:@"New");
                            err=nil;
                            [s writeToFile:[wiifieddir stringByAppendingString:ofn] atomically:YES encoding:NSUTF8StringEncoding error:&err];
                            printf("Wrote to file %s -- %s\n",[ofn cStringUsingEncoding:NSASCIIStringEncoding],prefix.UTF8String);
                        }
                    }
                    
                    if (errs) {
                        ret=1;
                        printf("\nFinished with errors:\n%s",errs.UTF8String);
                    }
                    else printf("\nFinished with no errors");
                }
            }
        }
        [InFiles markFiles];
        printf("\nDone!\n");
        
    }
    return((int)ret);
}

