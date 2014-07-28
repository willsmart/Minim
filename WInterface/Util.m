#import "Util.h"
#import <objc/runtime.h>

time_t _DEBLog_time;

NSString *replaceTokensInFilenameString(NSString *filename) {
    if ([filename rangeOfString:@"TIMESTAMP"].location!=NSNotFound) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd_HH-mm"];
        NSString *dateString=[dateFormat stringFromDate:NSDate.new];
        [dateFormat setDateFormat:@"yyyy-MM-dd_HH-mm-ss_SSS"];
        NSString *msDateString=[dateFormat stringFromDate:NSDate.new];
        filename=[[filename
            stringByReplacingOccurrencesOfString:@"MSTIMESTAMP" withString:msDateString]
            stringByReplacingOccurrencesOfString:@"TIMESTAMP" withString:dateString];
    }
    return(filename);
}

NSString *documentPathForFilename(NSString *filename) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? paths[0] : nil;
    return(is_nil(filename)?basePath:[basePath stringByAppendingPathComponent:replaceTokensInFilenameString(filename)]);
}

id<NSCopying> nullable_key(id<NSCopying> key) {
    return(key?key:[NSNull null]);
}
id nullable_object(id object) {
    return(object?object:[NSNull null]);
}

id<NSCopying> ObjectKey(id object) {
    return([object conformsToProtocol:@protocol(NSCopying)]?
        (id<NSCopying>)object:
        ObjectPointerKey(object)
    );
}
    

NSError *_IgnoreNSError,*__strong*IgnoreNSError=&_IgnoreNSError;


static long s_breakAt=0,s_breakpoint=0;
long breakpoint() {
    printf(".%ld.",++s_breakpoint);
    if (s_breakAt==s_breakpoint) {
        printf("\n\n!!BREAK!!\n");
    }
    return(s_breakpoint);
}
void breaknow() {s_breakAt=s_breakpoint+1;breakpoint();}
void breakat(long at) {s_breakAt=at;}
void ERROR(NSString *format,...) {
    va_list args;
    va_start(args, format);
    NSString *error=[[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    printf("\n\nERROR: %s\n",error.UTF8String);
    breaknow();
}


static NSString *s_basePath;
NSString *basePath() {
    if (!s_basePath) setBasePath(nil);
    return(s_basePath);
}
void setBasePath(NSString *basePath) {
    if (!basePath) basePath=nil;
    basePath=[basePath stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!basePath.isAbsolutePath) {
        NSFileManager *fm=NSFileManager.defaultManager;
        basePath=(basePath?[fm.currentDirectoryPath stringByAppendingPathComponent:basePath]:fm.currentDirectoryPath);
    }
    s_basePath=basePath;
}

NSString* pathForPath(NSString *path) {
    path=[basePath() stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!path.isAbsolutePath) path=[basePath() stringByAppendingPathComponent:path];
    return([[NSURL URLWithString:path relativeToURL:NSBundle.mainBundle.bundleURL] absoluteString]);
}


@implementation NSObject(winterface)

-(bool)isWeakSelf {
  return(NO);}
-(id)performUnknownSelector:(SEL)aSelector {

  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          return [self performSelector:aSelector];
  #pragma clang diagnostic pop
    }
-(void)performUnknownSelector:(SEL)aSelector onThread:(NSThread *)thread withObject:(id)arg waitUntilDone:(BOOL)wait {
  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          [self performSelector:aSelector onThread:thread withObject:arg waitUntilDone:wait];
  #pragma clang diagnostic pop
    }
-(void)performUnknownSelector:(SEL)aSelector onThread:(NSThread *)thread withObject:(id)arg waitUntilDone:(BOOL)wait modes:(NSArray *)array {
  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          [self performSelector:aSelector onThread:thread withObject:arg waitUntilDone:wait modes:array];
  #pragma clang diagnostic pop
    }
-(void)performUnknownSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay {
  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          [self performSelector:aSelector withObject:anArgument afterDelay:delay];
  #pragma clang diagnostic pop
    }
-(void)performUnknownSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay inModes:(NSArray *)modes {

  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          [self performSelector:aSelector withObject:anArgument afterDelay:delay inModes:modes];
  #pragma clang diagnostic pop
    }
-(id)performUnknownSelector:(SEL)aSelector withObject:(id)anObject {

  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          return [self performSelector:aSelector withObject:anObject];
  #pragma clang diagnostic pop
    }
-(id)performUnknownSelector:(SEL)aSelector withObject:(id)anObject withObject:(id)anotherObject {

  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          return [self performSelector:aSelector withObject:anObject withObject:anotherObject];
  #pragma clang diagnostic pop
    }
-(void)performUnknownSelectorInBackground:(SEL)aSelector withObject:(id)arg {

  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          [self performSelectorInBackground:aSelector withObject:arg];
  #pragma clang diagnostic pop
    }
-(void)performUnknownSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)wait {

  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          [self performSelectorOnMainThread:aSelector withObject:arg waitUntilDone:wait];
  #pragma clang diagnostic pop
    }
-(void)performUnknownSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)wait modes:(NSArray *)array {

  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          [self performSelectorOnMainThread:aSelector withObject:arg waitUntilDone:wait modes:array];
  #pragma clang diagnostic pop
    }
-(id)strongSelf {
  return(self);}
-(WeakSelf*)weakSelf {

          void *key=@selector(weakSelf);
          WeakSelf *weakSelf=objc_getAssociatedObject(self,key);
          if (!weakSelf) {
                objc_setAssociatedObject(self, key, weakSelf=[WeakSelf weakSelfFromObject:self], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
          return(weakSelf);
    }

@end



@implementation WeakSelf
@synthesize index=index;

-(bool)isWeakSelf {
  return(YES);}
-(id)strongSelf {
  
  /*i-999*/id ret=v_strongSelf;
  /*i999*/return(ret);}
-(WeakSelf*)weakSelf {
  return(self);}
+(WeakSelf*)weakSelfFromObject:(id)strongSelf {
    WeakSelf *ret=WeakSelf.new;
    ret->v_strongSelf=strongSelf;
    static NSUInteger s_index=0;
    ret->index=++s_index;
    ret->hash=ret.hash;
    return(ret);
}
-(instancetype)copyWithZone:(NSZone *)zone {
    WeakSelf *ret=[[WeakSelf allocWithZone:zone] init];
    ret->v_strongSelf=v_strongSelf;
    ret->index=index;
    ret->hash=hash;
    return(ret);
}
    
-(NSUInteger)hash {return(hash);}
-(BOOL)isEqual:(id)object {
    return(object&&((object==self)||(object==v_strongSelf)||([object isKindOfClass:WeakSelf.class]&&(((WeakSelf*)object))->index==index)));
}

@end

