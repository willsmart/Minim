//
//  PropBlocks.m
//  WInterface
//
//  Created by Will Smart on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PropBlocks.h"
#import "Classes.h"
#import "WReader.h"

@implementation PropBlockType
@synthesize mytype,histype,ivarStr,ifaceStr,deallocStr,dieStr,initStr,implStr;

- (void)dealloc {
    self.ivarStr=self.ifaceStr=self.deallocStr=self.dieStr=self.initStr=self.implStr=nil;
    }

- (id)initWithMyType:(char)amytype hisType:(char)ahistype {
    if (!(self=[super init])) return(nil);
    mytype=amytype;
    histype=ahistype;
    self.ivarStr=[NSMutableString string];
    self.ifaceStr=[NSMutableString string];
    self.deallocStr=[NSMutableString string];
    self.dieStr=[NSMutableString string];
    self.initStr=[NSMutableString string];
    self.implStr=[NSMutableString string];
    return(self);
}

- (void)readLine:(NSString*)line {
    if (inIFace) {
        if ([line hasPrefix:@"@end"]) inIFace=NO;
        else if (inDealloc) {
            if ([line hasPrefix:@"}"]) inDealloc=NO;
            else {
                [self.deallocStr appendFormat:@"%@\n",line];
            }
        }
        else if (inDie) {
            if ([line hasPrefix:@"}"]) inDie=NO;
            else [self.dieStr appendFormat:@"%@\n",line];
        }
        else if (inInit) {
            if ([line hasPrefix:@"}"]) inInit=NO;
            else [self.initStr appendFormat:@"%@\n",line];
        }
        else if ([line hasPrefix:@"- (void)dealloc"]) inDealloc=YES;
        else if ([line hasPrefix:@"- (void)die"]) inDie=YES;
        else if ([line hasPrefix:@"- (void)getPropertiesUsingContext:(NSMutableDictionary*)"]) inInit=YES;
        else [self.ifaceStr appendFormat:@"%@\n",line];
    }
    else if (inImpl) {
        if ([line hasPrefix:@"@end"]) inImpl=NO;
        else if (inIVar) {
            if ([line hasPrefix:@"}"]) inIVar=NO;
            else [self.deallocStr appendFormat:@"%@\n",line];
        }
        else if ([line hasPrefix:@"{"]) inIVar=YES;
        else [self.implStr appendFormat:@"%@\n",line];
    }
    else if ([line hasPrefix:[NSString stringWithFormat:(mytype&&histype?@"@interface myclass@c%c":@"@interface myclass"),mytype,histype]]) {
        inIFace=YES;
    }
    else if ([line hasPrefix:[NSString stringWithFormat:(mytype&&histype?@"@implementation myclass@c%c":@"@implementation myclass"),mytype,histype]]) {
        inImpl=YES;
    }
}

+ (NSString*)lowerName:(NSString*)s {
    if (s.length) {
        unichar c=[s characterAtIndex:0];
        if ((c>='A')&&(c<='Z')) s=[NSString stringWithFormat:@"%c%@",c+('a'-'A'),[s substringFromIndex:1]];
    }
    return(s);
}

+ (NSString*)upperName:(NSString*)s {
    if (s.length) {
        unichar c=[s characterAtIndex:0];
        if ((c>='a')&&(c<='z')) s=[NSString stringWithFormat:@"%c%@",c-('a'-'A'),[s substringFromIndex:1]];
    }
    return(s);
}

+ (NSString*)string:(NSString*)s withMyClass:(NSString*)myclass myName:(NSString*)myname hisClass:(NSString*)hisclass hisName:(NSString*)hisname {
    return([[[[[[s stringByReplacingOccurrencesOfString:@"myclass" withString:myclass]
                stringByReplacingOccurrencesOfString:@"myname" withString:[PropBlockType lowerName:myname]]
               stringByReplacingOccurrencesOfString:@"Myname" withString:[PropBlockType upperName:myname]]
              stringByReplacingOccurrencesOfString:@"hisclass" withString:hisclass]
             stringByReplacingOccurrencesOfString:@"hisname" withString:[PropBlockType lowerName:hisname]]
            stringByReplacingOccurrencesOfString:@"Hisname" withString:[PropBlockType upperName:hisname]]);
}


@end



@implementation PropBlocks
@synthesize types;

- (void)dealloc {
    self.types=nil;
    }

- (id)init {
    if (!(self=[super init])) return(nil);
    self.types=[NSMutableDictionary dictionary];

    WReader *r=[[WReader alloc] init];
    r.fileName=@"Prop.wi";
    [[WClasses getDefault] read:r];

    [self.types addObject:[[PropBlockType alloc] initWithMyType:0 hisType:0]];
    [self.types addObject:[[PropBlockType alloc] initWithMyType:'-' hisType:'-']];
    [self.types addObject:[[PropBlockType alloc] initWithMyType:'-' hisType:'S']];
    [self.types addObject:[[PropBlockType alloc] initWithMyType:'S' hisType:'-']];
    [self.types addObject:[[PropBlockType alloc] initWithMyType:'-' hisType:'A']];
    [self.types addObject:[[PropBlockType alloc] initWithMyType:'A' hisType:'-']];

    NSError *err=nil;
    NSString *s=[NSString stringWithFormat:@"%@\n%@\n",
                 [NSString stringWithContentsOfFile:@"PropBlocks.h" encoding:NSUTF8StringEncoding error:&err],
                 [NSString stringWithContentsOfFile:@"PropBlocks.m" encoding:NSUTF8StringEncoding error:&err]
                 ];
    NSArray *a=[s componentsSeparatedByString:@"\n"];
    for (NSString *ss in a) {
        for (PropBlockType *t in self.types) [t readLine:ss];
    }
    return(self);
}

- (PropBlockType*)typeForMyType:(char)mytype hisType:(char)histype {
    for (PropBlockType *t in self.types) {
        if ((t.mytype==mytype)&&(t.histype==histype)) return(t);
    }
    return(nil);
}

static PropBlocks *_default=nil;

+ (PropBlocks*)getDefault {
    if (!_default) _default=[[PropBlocks alloc] init];
    return(_default);
}
+ (void)clearStaticData {
    if (_default) {
        _default=nil;
    }
}
@end










