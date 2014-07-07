extern NSString *replaceTokensInFilenameString(NSString *filename);
extern NSString *documentPathForFilename(NSString *filename);



#define is_nil(obj) (!obj || [[NSNull null] isEqual:obj])
extern id<NSCopying> nullable_key(id<NSCopying> key);
extern id nullable_object(id object);


long breakpoint();
void breaknow();
void breakat(long at);
void ERROR(NSString *error,...);


#define COMPILER_MESSAGE(msg) _Pragma(STR(message(msg)))
#define COMPILER_WARNING(msg) _Pragma(STR(GCC warning(msg)))
#define STR(X) #X

#define ObjectPointerKey(__object) (@((long long)(__object)))

extern id<NSCopying> ObjectKey(id object);


#define cached_id_return(...) cached_return(id,__VA_ARGS__)

#define cached_return(__type,...) do { \
    static __type __cached_return_value = nil; \
    static dispatch_once_t __cached_return_once_token; \
    dispatch_once(&__cached_return_once_token, ^{__cached_return_value=(__VA_ARGS__);}); \
    return(__cached_return_value); \
} while(NO)

#define cached_id_return_depending_on(__dependsOn,...) cached_return_depending_on(__dependsOn,id,__VA_ARGS__)

#define cached_return_depending_on(__depends_on__macro_arg,__type,...) do { \
    static __type __cached_return_value = nil; \
    static NSObject *__cached_depends_on=nil; \
    NSObject *__depends_on=(__depends_on__macro_arg); \
    static dispatch_once_t __cached_return_once_token; \
    if (__cached_depends_on? \
        ![__depends_on isEqual:__cached_depends_on]: \
        __depends_on!=nil \
    ) { \
        __cached_depends_on=__depends_on; \
        memset(&__cached_return_once_token,0,sizeof(__cached_return_once_token)); \
    } \
    dispatch_once(&__cached_return_once_token, ^{__cached_return_value=(__VA_ARGS__);}); \
    return(__cached_return_value); \
} while(NO)



extern NSString* pathForPath(NSString *path);

extern NSError *_IgnoreNSError,*__strong*IgnoreNSError;

@class WeakSelf;


@interface NSObject(winterface)


-(bool)isWeakSelf;
-(id)performUnknownSelector:(SEL)aSelector;
-(void)performUnknownSelector:(SEL)aSelector onThread:(NSThread *)thread withObject:(id)arg waitUntilDone:(BOOL)wait;
-(void)performUnknownSelector:(SEL)aSelector onThread:(NSThread *)thread withObject:(id)arg waitUntilDone:(BOOL)wait modes:(NSArray *)array;
-(void)performUnknownSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay;
-(void)performUnknownSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay inModes:(NSArray *)modes;
-(id)performUnknownSelector:(SEL)aSelector withObject:(id)anObject;
-(id)performUnknownSelector:(SEL)aSelector withObject:(id)anObject withObject:(id)anotherObject;
-(void)performUnknownSelectorInBackground:(SEL)aSelector withObject:(id)arg;
-(void)performUnknownSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)wait;
-(void)performUnknownSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)wait modes:(NSArray *)array;
-(id)strongSelf;
-(WeakSelf*)weakSelf;
@end




@interface WeakSelf : NSObject<NSCopying> {
    id v_strongSelf;
    NSUInteger index,hash;
}

@property (nonatomic,readonly) NSUInteger index;

-(bool)isWeakSelf;
-(id)strongSelf;
-(WeakSelf*)weakSelf;
+(WeakSelf*)weakSelfFromObject:(id)strongSelf;

@end



