//
//  WReader.m
//  WInterface
//
//  Created by Will Smart on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WReader.h"
#define MAINCPPFILE
#define CPPFILE
#import "WReaderTokenizer.h"


@implementation WReader

@synthesize _fileName,_fileString,_filePath,lines,pos,tokenizer,replaces;

- (void)dealloc {
    self._fileName=self._fileString=self._filePath=nil;
    self.lines=nil;
    self.replaces=nil;
    self.tokenizer=nil;
    }

- (id)init {
    if (!(self=[super init])) return(nil);
    self._fileName=self._fileString=@"";
    self._filePath=nil;
    self.lines=[NSArray array];
    self.replaces=[NSMutableDictionary dictionary];
    self.tokenizer=[[WReaderTokenizer alloc] initWithReader:self];
    pos=-1;
    return(self);
}

- (WReaderToken*)nextToken {
    if (pos>=self.tokenizer.tokens.count) return(nil);
    pos++;
    return(self.currentToken);
}
- (WReaderToken*)currentToken {
    if (pos<0) pos=0;
    if (pos>=self.tokenizer.tokens.count) return(nil);
    return([self.tokenizer.tokens objectAtIndex:pos]);
}
- (NSString*)stringWithTokensInRange:(NSRange)r {
    NSMutableString *s=[NSMutableString string];
    for (int i=MAX(0,(int)r.location);i<MIN(self.tokenizer.tokens.count,r.location+r.length);i++) {
        [s appendString:((WReaderToken*)[self.tokenizer.tokens objectAtIndex:i]).str];
    }
    return(s);
}
    
- (NSString*)fileString {return(self._fileString);}
- (NSString*)fileName {return(self._fileName);}
- (NSString*)filePath {return(self._filePath);}

- (void)setFileName:(NSString *)fileName {
    NSError *err=nil;
    self._fileName=fileName;
    if (fileName.isAbsolutePath) self._filePath=fileName;
    else {
        NSFileManager *fm=[NSFileManager defaultManager];
        self._filePath=[fm.currentDirectoryPath stringByAppendingPathComponent:fileName];
    }

    NSString *s=[NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:&err];
    
    self.fileString=s;
    if (!s) self._filePath=nil;
    
//    [self.tokenizer.tokenStr writeToFile:[fileName stringByAppendingFormat:@".deb.txt"] atomically:YES encoding:NSASCIIStringEncoding error:&err];
}

- (void)setFileString:(NSString *)fileString {
    self._fileString=[(fileString?fileString.copy:@"") stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    for (NSString *from in self.replaces.allKeys) {
        NSString *to=[self.replaces objectForKey:from];
        self._fileString=[self._fileString stringByReplacingOccurrencesOfString:from withString:to];
    }
    self.lines=[fileString componentsSeparatedByString:@"\n"];
    self.tokenizer.str=fileString;
    
    pos=-1;
}

- (NSString*)localString {
    NSMutableString *s=[NSMutableString string];
    int range=30;
    for (int i=MAX(0,pos-range/2);i<=MIN(self.tokenizer.tokens.count-1,pos+(range+1)/2);i++) {
        if (i==pos) [s appendString:@">here>"];
//        [s appendFormat:@"(%c)%@",((WReaderToken*)[self.tokenizer.tokens objectAtIndex:i]).type,((WReaderToken*)[self.tokenizer.tokens objectAtIndex:i]).str];
        [s appendString:((WReaderToken*)[self.tokenizer.tokens objectAtIndex:i]).str];
        if (i==pos) [s appendString:@"<here<"];
    }
    return(s);
}

@end
