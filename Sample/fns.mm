//WInterface autogenerated this file. HaND

//Tasks:
//    Embedded 5 notes (look for "notenote" in the code)


#include "sample.wi.h"











#pragma mark -
#pragma mark Implementations:










// !!!: Implementations: f



















#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_Fns

#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_Fns
#define _ClassName_ Fns
#define _WIClass_ Fns__
#define _className_ fns
#define _Class_ Fns__
@implementation Fns

@synthesize ___arc=___arc;
@synthesize ___rc=___rc;
@synthesize __owner_context=__owner_context;
@synthesize debugAutorelease=debugAutorelease;
@synthesize isZombie=isZombie;
@synthesize objectIDInClass=objectIDInClass;
@synthesize objectIDInTotal=objectIDInTotal;
-(Fns*)_startObjectOfClassFns {MSGSTART("Fns:-(Fns*)_startObjectOfClassFns")
  
  /*i-996*/debugAutorelease=YES;
  /*i-995*/objInitFn(self,___rc,___arc,objectIDInTotal,objectIDInClass);
      
  /*i0*///@-999 NSDictionary *d __attribute__((unused)) =([self respondsToSelector:@selector(__initializeUsingDictionary)]?[self performSelector:@selector(__initializeUsingDictionary)]:nil);
          
  /*i999*/return(self);
    }
-(constchar*)cdescription {MSGSTART("Fns:-(constchar*)cdescription")
  return([self.description cStringUsingEncoding:NSASCIIStringEncoding]);}
-(constchar*)cobjectName {MSGSTART("Fns:-(constchar*)cobjectName")
  return([self.objectName cStringUsingEncoding:NSASCIIStringEncoding]);}
-(void)dealloc {MSGSTART("Fns:-(void)dealloc")
  
  /*i-151*/[self die];
/*i998*/deallocFn(self,___rc,___arc,objectIDInTotal,objectIDInClass);
        isZombie=YES;
#if defined(LONGLIVEZOMBIES) || defined(LONGLIVEZOMBIES___WI_CLASS__)
        if (YES) return;
#endif
    
/*i999*/}
-(NSString*)description {MSGSTART("Fns:-(NSString*)description")
  
  /*i-999*/NSMutableString *ret=self.objectName;
          
  /*i999*/return(ret);
    }
-(void)die {MSGSTART("Fns:-(void)die")
  
  /*i900*/}
-(void)fn {MSGSTART("Fns:-(void)fn")

          
  /*i1*//*1*/ 
  /*i2*//*2*/ 
  /*i3*//*3*/ 
  /*i98*//*98*/
      
  /*i99*//*99*/ 
  /*i100*//*100*/ }
-(void)fn2 {MSGSTART("Fns:-(void)fn2")

        
          
  /*i1*//*1*/ 
  /*i2*//*2*/ 
  /*i3*//*3*/
      
  /*i98*//*98*/
      
  /*i99*//*99*/ 
  /*i100*//*100*/ }
-(void)fn:(Int)i {MSGSTART("Fns:-(void)fn:(Int)i")

          
  /*i1*//*1*/ 
  /*i2*//*2*/ 
  /*i3*//*3*/ 
  /*i98*//*98*/
      
  /*i99*//*99*/
  /*i100*//*100*/ }
-(NSMutableString*)objectName {MSGSTART("Fns:-(NSMutableString*)objectName")
  
  /*i-999*/NSMutableString *ret=nil;
          
  /*i-100*/ret=[NSMutableString stringWithFormat:@"[%qu:%p]%s#%qu",objectIDInTotal,self,__Derived_CClass__,objectIDInClass];
          
  /*i999*/return(ret);
    }
-(id)w_autorelease {MSGSTART("Fns:-(id)w_autorelease")
  
  /*i-900*/autoreleaseFn(self,___rc,___arc,debugAutorelease); 
  /*i990*/return(nil/*super*/);}
-(void)w_release {MSGSTART("Fns:-(void)w_release")
  
  /*i-900*/releaseFn(self,___rc,___arc,debugAutorelease); }
-(id)w_retain {MSGSTART("Fns:-(id)w_retain")
  
  /*i-900*/retainFn(self,___rc,___arc); 
  /*i999*/return(nil/*super*/);}

@end
#undef _ClassName_
#undef _WIClass_
#undef _className_
#undef _Class_


















// !!!: Implementations: n



















#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_NSObject

#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_NSObject
#define _ClassName_ NSObject
#define _WIClass_ NSObject__
#define _className_ nSObject
#define _Class_ NSObject__
@implementation NSObject(winterface)

-(bool)isWeakSelf {MSGSTART("NSObject:-(bool)isWeakSelf")
  return(NO);}
-(id)performUnknownSelector:(SEL)aSelector {MSGSTART("NSObject:-(id)performUnknownSelector:(SEL)aSelector")

  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          return [self performSelector:aSelector];
  #pragma clang diagnostic pop
    }
-(void)performUnknownSelector:(SEL)aSelector onThread:(NSThread *)thread withObject:(id)arg waitUntilDone:(BOOL)wait {MSGSTART("NSObject:-(void)performUnknownSelector:(SEL)aSelector onThread:(NSThread *)thread withObject:(id)arg waitUntilDone:(BOOL)wait")

  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          [self performSelector:aSelector onThread:thread withObject:arg waitUntilDone:wait];
  #pragma clang diagnostic pop
    }
-(void)performUnknownSelector:(SEL)aSelector onThread:(NSThread *)thread withObject:(id)arg waitUntilDone:(BOOL)wait modes:(NSArray *)array {MSGSTART("NSObject:-(void)performUnknownSelector:(SEL)aSelector onThread:(NSThread *)thread withObject:(id)arg waitUntilDone:(BOOL)wait modes:(NSArray *)array")

  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          [self performSelector:aSelector onThread:thread withObject:arg waitUntilDone:wait modes:array];
  #pragma clang diagnostic pop
    }
-(void)performUnknownSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay {MSGSTART("NSObject:-(void)performUnknownSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay")

  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          [self performSelector:aSelector withObject:anArgument afterDelay:delay];
  #pragma clang diagnostic pop
    }
-(void)performUnknownSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay inModes:(NSArray *)modes {MSGSTART("NSObject:-(void)performUnknownSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay inModes:(NSArray *)modes")

  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          [self performSelector:aSelector withObject:anArgument afterDelay:delay inModes:modes];
  #pragma clang diagnostic pop
    }
-(id)performUnknownSelector:(SEL)aSelector withObject:(id)anObject {MSGSTART("NSObject:-(id)performUnknownSelector:(SEL)aSelector withObject:(id)anObject")

  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          return [self performSelector:aSelector withObject:anObject];
  #pragma clang diagnostic pop
    }
-(id)performUnknownSelector:(SEL)aSelector withObject:(id)anObject withObject:(id)anotherObject {MSGSTART("NSObject:-(id)performUnknownSelector:(SEL)aSelector withObject:(id)anObject withObject:(id)anotherObject")

  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          return [self performSelector:aSelector withObject:anObject withObject:anotherObject];
  #pragma clang diagnostic pop
    }
-(void)performUnknownSelectorInBackground:(SEL)aSelector withObject:(id)arg {MSGSTART("NSObject:-(void)performUnknownSelectorInBackground:(SEL)aSelector withObject:(id)arg")

  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          [self performSelectorInBackground:aSelector withObject:arg];
  #pragma clang diagnostic pop
    }
-(void)performUnknownSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)wait {MSGSTART("NSObject:-(void)performUnknownSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)wait")

  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          [self performSelectorOnMainThread:aSelector withObject:arg waitUntilDone:wait];
  #pragma clang diagnostic pop
    }
-(void)performUnknownSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)wait modes:(NSArray *)array {MSGSTART("NSObject:-(void)performUnknownSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)wait modes:(NSArray *)array")

  #pragma clang diagnostic push
  #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          [self performSelectorOnMainThread:aSelector withObject:arg waitUntilDone:wait modes:array];
  #pragma clang diagnostic pop
    }
-(void)setSys:(Int)v {MSGSTART("NSObject:-(void)setSys:(Int)v")
  /*set*/}
-(id)strongSelf {MSGSTART("NSObject:-(id)strongSelf")
  return(self);}
-(Int)sys {MSGSTART("NSObject:-(Int)sys")
  return(0);}
-(void)sysfn {MSGSTART("NSObject:-(void)sysfn")
  
  /*i1*//*1*/}
-(WeakSelf*)weakSelf {MSGSTART("NSObject:-(WeakSelf*)weakSelf")

          void *key=@selector(weakSelf);
          WeakSelf *weakSelf=objc_getAssociatedObject(self,key);
          if (!weakSelf) {
                objc_setAssociatedObject(self, key, weakSelf=[WeakSelf weakSelfFromObject:self], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
          return(weakSelf);
    }

@end
#undef _ClassName_
#undef _WIClass_
#undef _className_
#undef _Class_


















// !!!: Implementations: s



















#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_SubFns

#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_SubFns
#define _ClassName_ SubFns
#define _WIClass_ SubFns__
#define _className_ subFns
#define _Class_ SubFns__
@implementation SubFns

-(SubFns*)_startObjectOfClassSubFns {MSGSTART("SubFns:-(SubFns*)_startObjectOfClassSubFns")

          //@-999 NSDictionary *d __attribute__((unused)) =([self respondsToSelector:@selector(__initializeUsingDictionary)]?[self performSelector:@selector(__initializeUsingDictionary)]:nil);
          
  /*i999*/return(self);
    }
-(void)dealloc {MSGSTART("SubFns:-(void)dealloc")
  
  /*i-151*/[self die];
/*i999*/}
-(void)die {MSGSTART("SubFns:-(void)die")
  
  /*i900*/[super die];}
-(void)fn {MSGSTART("SubFns:-(void)fn")

          
  /*i1*//*1!*/ 
  /*i4*//*add4*/
    }
-(void)fn2 {MSGSTART("SubFns:-(void)fn2")

          
  /*i1*//*1!*/ 
  /*i4*//*add4*/
    }
-(id)w_autorelease {MSGSTART("SubFns:-(id)w_autorelease")
  
  /*i999*/return(nil/*super*/);}
-(void)w_release {MSGSTART("SubFns:-(void)w_release")
}
-(id)w_retain {MSGSTART("SubFns:-(id)w_retain")
  
  /*i999*/return(nil/*super*/);}

@end
#undef _ClassName_
#undef _WIClass_
#undef _className_
#undef _Class_

















