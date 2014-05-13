//
//  main.m
//  WInterface
//
//  Created by Will Smart on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WReaderTokenizer.h"
#import "Classes.h"
#import "WReader.h"

int main(int argc, const char * argv[])
{
    printf("Winterface 1.1001 (C)2013 Will smart HaND:)\n");

    int ret=0;
    
    @autoreleasepool {

        NSFileManager *fm=[NSFileManager defaultManager];

        NSString *baseDir=fm.currentDirectoryPath;
        
        for (int i=(argc==1?0:1);i<argc;i++) {
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
                    
                    NSError *err=nil;
                    NSString *html=cs.html,*htmlfn=[r.fileName stringByAppendingString:@".html"];
                    [html writeToFile:htmlfn atomically:YES encoding:NSUTF8StringEncoding error:&err];
                    printf("Wrote to file %s\n",[htmlfn cStringUsingEncoding:NSASCIIStringEncoding]);
                    
                    NSMutableString *s=[NSMutableString string];
                    [cs appendObjCToString:s iface:NO impl:NO classFilename:nil headerFilename:nil];
                    err=nil;
                    [fm changeCurrentDirectoryPath:baseDir];
                    NSString *dfn=[r.fileName stringByAppendingString:@".decl.h"];
                    [s writeToFile:dfn atomically:YES encoding:NSUTF8StringEncoding error:&err];
                    printf("Wrote to file %s\n",[dfn cStringUsingEncoding:NSASCIIStringEncoding]);
                    

                    NSString *hfn=[r.fileName stringByAppendingString:@".h"];
                    s=[NSMutableString string];
                    [cs appendObjCToString:s iface:YES impl:NO classFilename:nil headerFilename:dfn];
                    err=nil;
                    [fm changeCurrentDirectoryPath:baseDir];
                    [s writeToFile:hfn atomically:YES encoding:NSUTF8StringEncoding error:&err];
                    printf("Wrote to file %s\n",[hfn cStringUsingEncoding:NSASCIIStringEncoding]);

                    NSString *errs=nil;
                    for (NSString *fn in fns) {
                        s=[NSMutableString string];
                        NSString *errs2=[cs appendObjCToString:s iface:NO impl:YES classFilename:fn headerFilename:hfn];
                        if (!errs) errs=errs2;
                        else errs=[errs stringByAppendingString:errs2];
                        
                        err=nil;
                        [fm changeCurrentDirectoryPath:baseDir];
                        NSString *ofn=[([fn isEqualToString:@"default"]?r.fileName:fn) stringByAppendingString:@".mm"];
                        NSString *swas=[NSString stringWithContentsOfFile:ofn encoding:NSUTF8StringEncoding error:&err];
                        if (swas&&[swas isEqualToString:s]) {
                            printf("No change to file %s\n",[ofn cStringUsingEncoding:NSASCIIStringEncoding]);
                        }
                        else {
                            int prefLen=(int)[s commonPrefixWithString:swas options:0].length;
                            NSString *prefix=(swas?[NSString stringWithFormat:@"Changed from\n    [%d]\"%@\"\nis now\n    [%d]\"%@\"",prefLen,[[swas substringFromIndex:prefLen] substringToIndex:(swas.length-prefLen<50?swas.length-prefLen:50)],prefLen,[[s substringFromIndex:prefLen] substringToIndex:(s.length-prefLen<50?s.length-prefLen:50)]]:@"New");
                            err=nil;
                            [s writeToFile:ofn atomically:YES encoding:NSUTF8StringEncoding error:&err];
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
    return(ret);
}

