//WInterface autogenerated this file. HaND

//Tasks:
//    Embedded 5 notes (look for "notenote" in the code)


#include "sample.wi.h"











#pragma mark -
#pragma mark Implementations:










// !!!: Implementations: r



















#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_RClassMT

#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_RClassMT
#define _ClassName_ RClassMT
#define _WIClass_ RClassMT__
#define _className_ rClassMT
#define _Class_ RClassMT__
@implementation RClassMT

@synthesize ___arc=___arc;
@synthesize ___rc=___rc;
@synthesize __owner_context=__owner_context;
@synthesize debugAutorelease=debugAutorelease;
@synthesize isZombie=isZombie;
@synthesize objectIDInClass=objectIDInClass;
@synthesize objectIDInTotal=objectIDInTotal;
-(RClassMT*)_startObjectOfClassRClassMT {MSGSTART("RClassMT:-(RClassMT*)_startObjectOfClassRClassMT")
  
  /*i-996*/debugAutorelease=YES;
  /*i-995*/objInitFn(self,___rc,___arc,objectIDInTotal,objectIDInClass);
      
  /*i0*///@-999 NSDictionary *d __attribute__((unused)) =([self respondsToSelector:@selector(__initializeUsingDictionary)]?[self performSelector:@selector(__initializeUsingDictionary)]:nil);
          
  /*i999*/return(self);
    }
-(constchar*)cdescription {MSGSTART("RClassMT:-(constchar*)cdescription")
  return([self.description cStringUsingEncoding:NSASCIIStringEncoding]);}
-(constchar*)cobjectName {MSGSTART("RClassMT:-(constchar*)cobjectName")
  return([self.objectName cStringUsingEncoding:NSASCIIStringEncoding]);}
-(void)dealloc {MSGSTART("RClassMT:-(void)dealloc")
  
  /*i-151*/[self die];
/*i998*/deallocFn(self,___rc,___arc,objectIDInTotal,objectIDInClass);
        isZombie=YES;
#if defined(LONGLIVEZOMBIES) || defined(LONGLIVEZOMBIES___WI_CLASS__)
        if (YES) return;
#endif
    
/*i999*/}
-(NSString*)description {MSGSTART("RClassMT:-(NSString*)description")
  
  /*i-999*/NSMutableString *ret=self.objectName;
          
  /*i999*/return(ret);
    }
-(void)die {MSGSTART("RClassMT:-(void)die")
  
  /*i900*/}
-(NSMutableString*)objectName {MSGSTART("RClassMT:-(NSMutableString*)objectName")
  
  /*i-999*/NSMutableString *ret=nil;
          
  /*i-100*/ret=[NSMutableString stringWithFormat:@"[%qu:%p]%s#%qu",objectIDInTotal,self,__Derived_CClass__,objectIDInClass];
          
  /*i999*/return(ret);
    }
-(id)w_autorelease {MSGSTART("RClassMT:-(id)w_autorelease")
  
  /*i-900*/autoreleaseFn(self,___rc,___arc,debugAutorelease); 
  /*i990*/return(nil/*super*/);}
-(void)w_release {MSGSTART("RClassMT:-(void)w_release")
  
  /*i-900*/releaseFn(self,___rc,___arc,debugAutorelease); }
-(id)w_retain {MSGSTART("RClassMT:-(id)w_retain")
  
  /*i-900*/retainFn(self,___rc,___arc); 
  /*i999*/return(nil/*super*/);}

@end
#undef _ClassName_
#undef _WIClass_
#undef _className_
#undef _Class_










#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_RSubClassMT

#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_RSubClassMT
#define _ClassName_ RSubClassMT
#define _WIClass_ RSubClassMT__
#define _className_ rSubClassMT
#define _Class_ RSubClassMT__
@implementation RSubClassMT

-(RSubClassMT*)_startObjectOfClassRSubClassMT {MSGSTART("RSubClassMT:-(RSubClassMT*)_startObjectOfClassRSubClassMT")

          //@-999 NSDictionary *d __attribute__((unused)) =([self respondsToSelector:@selector(__initializeUsingDictionary)]?[self performSelector:@selector(__initializeUsingDictionary)]:nil);
          
  /*i999*/return(self);
    }
-(void)dealloc {MSGSTART("RSubClassMT:-(void)dealloc")
  
  /*i-151*/[self die];
/*i999*/}
-(void)die {MSGSTART("RSubClassMT:-(void)die")
  
  /*i900*/[super die];}
-(id)w_autorelease {MSGSTART("RSubClassMT:-(id)w_autorelease")
  
  /*i999*/return(nil/*super*/);}
-(void)w_release {MSGSTART("RSubClassMT:-(void)w_release")
}
-(id)w_retain {MSGSTART("RSubClassMT:-(id)w_retain")
  
  /*i999*/return(nil/*super*/);}

@end
#undef _ClassName_
#undef _WIClass_
#undef _className_
#undef _Class_

















