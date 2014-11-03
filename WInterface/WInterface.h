//
//  WInterface.h
//  WInterface
//
//  Created by Will Smart on 25/08/14.
//
//

#ifndef WInterface_WInterface_h
#define WInterface_WInterface_h

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#define UIColor NSColor
#define UIImage NSImage
#define UIFont NSFont
#define UIBezierPath NSBezierPath
#import <objc/runtime.h>

//#import <RegexKit/RegexKit.h>


#include "Headers.h"

extern NSString *g_swiftStart;
extern NSString *g_swiftEnd;
#define COMPATSTART(__c) do{if (!(__c).swiftCompatible) [s appendString:g_swiftStart];}while(NO)
#define COMPATEND(__c) do{if (!(__c).swiftCompatible) [s appendString:g_swiftEnd];}while(NO)
#define COMPAT(__c,...) do{COMPATSTART(__c);__VA_ARGS__;COMPATEND(__c);}while(NO)

#define debug 0
typedef NSInteger Int;

#import "Protocols.h"
@class WFn,WType,WClass,WVar,WClasses,WPotentialType,InFiles,WReaderToken,WReader,WReaderTokenizer;

#import "NSString+WI.h"
#import "WReaderToken.h"
#import "WReaderTokenizer.h"
#import "Parse.h"
#import "InFiles.h"
#import "WVar.h"
#import "WProp.h"
#import "WFn.h"
#import "WClass.h"
#import "WClasses.h"
#import "WType.h"
#import "WPotentialType.h"
#import "WReader.h"
#import "util.h"
#import "WReader.h"
#import "WReaderTokenizer.h"
#import "Collections.h"
#import "Util.h"


#endif
