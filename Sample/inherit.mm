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
#define _PrivateAccessMask_ __private_access_thread_mask_in_RClass

#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_RClass
#define _ClassName_ RClass
#define _WIClass_ RClass__
#define _className_ rClass
#define _Class_ RClass__
@implementation RClass

@synthesize ___arc=___arc;
@synthesize ___rc=___rc;
@synthesize __owner_context=__owner_context;
@synthesize debugAutorelease=debugAutorelease;
@synthesize isZombie=isZombie;
@synthesize objectIDInClass=objectIDInClass;
@synthesize objectIDInTotal=objectIDInTotal;
@synthesize RClass=RClass;
@synthesize RProtocol=RProtocol;
-(RClass*)_startObjectOfClassRClass {MSGSTART("RClass:-(RClass*)_startObjectOfClassRClass")
  
  /*i-996*/debugAutorelease=YES;
  /*i-995*/objInitFn(self,___rc,___arc,objectIDInTotal,objectIDInClass);
      
  /*i0*///@-999 NSDictionary *d __attribute__((unused)) =([self respondsToSelector:@selector(__initializeUsingDictionary)]?[self performSelector:@selector(__initializeUsingDictionary)]:nil);
          
  /*i999*/return(self);
    }
-(constchar*)cdescription {MSGSTART("RClass:-(constchar*)cdescription")
  return([self.description cStringUsingEncoding:NSASCIIStringEncoding]);}
-(constchar*)cobjectName {MSGSTART("RClass:-(constchar*)cobjectName")
  return([self.objectName cStringUsingEncoding:NSASCIIStringEncoding]);}
-(void)dealloc {MSGSTART("RClass:-(void)dealloc")
  
  /*i-151*/[self die];
/*i998*/deallocFn(self,___rc,___arc,objectIDInTotal,objectIDInClass);
        isZombie=YES;
#if defined(LONGLIVEZOMBIES) || defined(LONGLIVEZOMBIES___WI_CLASS__)
        if (YES) return;
#endif
    
/*i999*/}
-(NSString*)description {MSGSTART("RClass:-(NSString*)description")
  
  /*i-999*/NSMutableString *ret=self.objectName;
          
  /*i999*/return(ret);
    }
-(void)die {MSGSTART("RClass:-(void)die")
  
  /*i900*/}
-(void)fn {MSGSTART("RClass:-(void)fn")
  /*RClass*//*RProtocol*/}
-(NSMutableString*)objectName {MSGSTART("RClass:-(NSMutableString*)objectName")
  
  /*i-999*/NSMutableString *ret=nil;
          
  /*i-100*/ret=[NSMutableString stringWithFormat:@"[%qu:%p]%s#%qu",objectIDInTotal,self,__Derived_CClass__,objectIDInClass];
          
  /*i999*/return(ret);
    }
-(void)RClassfn {MSGSTART("RClass:-(void)RClassfn")
  /*RClass*/}
-(void)RProtocolfn {MSGSTART("RClass:-(void)RProtocolfn")
  /*RProtocol*/}
-(id)w_autorelease {MSGSTART("RClass:-(id)w_autorelease")
  
  /*i-900*/autoreleaseFn(self,___rc,___arc,debugAutorelease); 
  /*i990*/return(nil/*super*/);}
-(void)w_release {MSGSTART("RClass:-(void)w_release")
  
  /*i-900*/releaseFn(self,___rc,___arc,debugAutorelease); }
-(id)w_retain {MSGSTART("RClass:-(id)w_retain")
  
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
#define _PrivateAccessMask_ __private_access_thread_mask_in_RClass2

#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_RClass2
#define _ClassName_ RClass2
#define _WIClass_ RClass2__
#define _className_ rClass2
#define _Class_ RClass2__
@implementation RClass2

@synthesize ___arc=___arc;
@synthesize ___rc=___rc;
@synthesize __owner_context=__owner_context;
@synthesize debugAutorelease=debugAutorelease;
@synthesize isZombie=isZombie;
@synthesize objectIDInClass=objectIDInClass;
@synthesize objectIDInTotal=objectIDInTotal;
@synthesize RClass2=RClass2;
@synthesize RProtocol=RProtocol;
@synthesize RSubProtocol=RSubProtocol;
-(RClass2*)_startObjectOfClassRClass2 {MSGSTART("RClass2:-(RClass2*)_startObjectOfClassRClass2")
  
  /*i-996*/debugAutorelease=YES;
  /*i-995*/objInitFn(self,___rc,___arc,objectIDInTotal,objectIDInClass);
      
  /*i0*///@-999 NSDictionary *d __attribute__((unused)) =([self respondsToSelector:@selector(__initializeUsingDictionary)]?[self performSelector:@selector(__initializeUsingDictionary)]:nil);
          
  /*i999*/return(self);
    }
-(constchar*)cdescription {MSGSTART("RClass2:-(constchar*)cdescription")
  return([self.description cStringUsingEncoding:NSASCIIStringEncoding]);}
-(constchar*)cobjectName {MSGSTART("RClass2:-(constchar*)cobjectName")
  return([self.objectName cStringUsingEncoding:NSASCIIStringEncoding]);}
-(void)dealloc {MSGSTART("RClass2:-(void)dealloc")
  
  /*i-151*/[self die];
/*i998*/deallocFn(self,___rc,___arc,objectIDInTotal,objectIDInClass);
        isZombie=YES;
#if defined(LONGLIVEZOMBIES) || defined(LONGLIVEZOMBIES___WI_CLASS__)
        if (YES) return;
#endif
    
/*i999*/}
-(NSString*)description {MSGSTART("RClass2:-(NSString*)description")
  
  /*i-999*/NSMutableString *ret=self.objectName;
          
  /*i999*/return(ret);
    }
-(void)die {MSGSTART("RClass2:-(void)die")
  
  /*i900*/}
-(void)fn {MSGSTART("RClass2:-(void)fn")
  /*RClass2*//*RProtocol*//*RSubProtocol*/}
-(NSMutableString*)objectName {MSGSTART("RClass2:-(NSMutableString*)objectName")
  
  /*i-999*/NSMutableString *ret=nil;
          
  /*i-100*/ret=[NSMutableString stringWithFormat:@"[%qu:%p]%s#%qu",objectIDInTotal,self,__Derived_CClass__,objectIDInClass];
          
  /*i999*/return(ret);
    }
-(void)RClass2fn {MSGSTART("RClass2:-(void)RClass2fn")
  /*RClass2*/}
-(void)RProtocolfn {MSGSTART("RClass2:-(void)RProtocolfn")
  /*RProtocol*/}
-(void)RSubProtocolfn {MSGSTART("RClass2:-(void)RSubProtocolfn")
  /*RSubProtocol*/}
-(id)w_autorelease {MSGSTART("RClass2:-(id)w_autorelease")
  
  /*i-900*/autoreleaseFn(self,___rc,___arc,debugAutorelease); 
  /*i990*/return(nil/*super*/);}
-(void)w_release {MSGSTART("RClass2:-(void)w_release")
  
  /*i-900*/releaseFn(self,___rc,___arc,debugAutorelease); }
-(id)w_retain {MSGSTART("RClass2:-(id)w_retain")
  
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
#define _PrivateAccessMask_ __private_access_thread_mask_in_RClassab

#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_RClassab
#define _ClassName_ RClassab
#define _WIClass_ RClassab__
#define _className_ rClassab
#define _Class_ RClassab__
@implementation RClassab

@synthesize ___arc=___arc;
@synthesize ___rc=___rc;
@synthesize __owner_context=__owner_context;
@synthesize debugAutorelease=debugAutorelease;
@synthesize isZombie=isZombie;
@synthesize objectIDInClass=objectIDInClass;
@synthesize objectIDInTotal=objectIDInTotal;
@synthesize RClassab=RClassab;
@synthesize RProtocol=RProtocol;
@synthesize RProtocolb=RProtocolb;
-(RClassab*)_startObjectOfClassRClassab {MSGSTART("RClassab:-(RClassab*)_startObjectOfClassRClassab")
  
  /*i-996*/debugAutorelease=YES;
  /*i-995*/objInitFn(self,___rc,___arc,objectIDInTotal,objectIDInClass);
      
  /*i0*///@-999 NSDictionary *d __attribute__((unused)) =([self respondsToSelector:@selector(__initializeUsingDictionary)]?[self performSelector:@selector(__initializeUsingDictionary)]:nil);
          
  /*i999*/return(self);
    }
-(constchar*)cdescription {MSGSTART("RClassab:-(constchar*)cdescription")
  return([self.description cStringUsingEncoding:NSASCIIStringEncoding]);}
-(constchar*)cobjectName {MSGSTART("RClassab:-(constchar*)cobjectName")
  return([self.objectName cStringUsingEncoding:NSASCIIStringEncoding]);}
-(void)dealloc {MSGSTART("RClassab:-(void)dealloc")
  
  /*i-151*/[self die];
/*i998*/deallocFn(self,___rc,___arc,objectIDInTotal,objectIDInClass);
        isZombie=YES;
#if defined(LONGLIVEZOMBIES) || defined(LONGLIVEZOMBIES___WI_CLASS__)
        if (YES) return;
#endif
    
/*i999*/}
-(NSString*)description {MSGSTART("RClassab:-(NSString*)description")
  
  /*i-999*/NSMutableString *ret=self.objectName;
          
  /*i999*/return(ret);
    }
-(void)die {MSGSTART("RClassab:-(void)die")
  
  /*i900*/}
-(void)fn {MSGSTART("RClassab:-(void)fn")
  /*RClassab*//*RProtocol*//*RProtocolb*/}
-(NSMutableString*)objectName {MSGSTART("RClassab:-(NSMutableString*)objectName")
  
  /*i-999*/NSMutableString *ret=nil;
          
  /*i-100*/ret=[NSMutableString stringWithFormat:@"[%qu:%p]%s#%qu",objectIDInTotal,self,__Derived_CClass__,objectIDInClass];
          
  /*i999*/return(ret);
    }
-(void)RClassabfn {MSGSTART("RClassab:-(void)RClassabfn")
  /*RClassab*/}
-(void)RProtocolbfn {MSGSTART("RClassab:-(void)RProtocolbfn")
  /*RProtocolb*/}
-(void)RProtocolfn {MSGSTART("RClassab:-(void)RProtocolfn")
  /*RProtocol*/}
-(id)w_autorelease {MSGSTART("RClassab:-(id)w_autorelease")
  
  /*i-900*/autoreleaseFn(self,___rc,___arc,debugAutorelease); 
  /*i990*/return(nil/*super*/);}
-(void)w_release {MSGSTART("RClassab:-(void)w_release")
  
  /*i-900*/releaseFn(self,___rc,___arc,debugAutorelease); }
-(id)w_retain {MSGSTART("RClassab:-(id)w_retain")
  
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
#define _PrivateAccessMask_ __private_access_thread_mask_in_RClassabnap

#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_RClassabnap
#define _ClassName_ RClassabnap
#define _WIClass_ RClassabnap__
#define _className_ rClassabnap
#define _Class_ RClassabnap__
@implementation RClassabnap

@synthesize ___arc=___arc;
@synthesize ___rc=___rc;
@synthesize __owner_context=__owner_context;
@synthesize debugAutorelease=debugAutorelease;
@synthesize isZombie=isZombie;
@synthesize objectIDInClass=objectIDInClass;
@synthesize objectIDInTotal=objectIDInTotal;
@synthesize RClassabnap=RClassabnap;
@synthesize RProtocol=RProtocol;
@synthesize RProtocolb=RProtocolb;
@synthesize RProtocolnap=RProtocolnap;
-(RClassabnap*)_startObjectOfClassRClassabnap {MSGSTART("RClassabnap:-(RClassabnap*)_startObjectOfClassRClassabnap")
  
  /*i-996*/debugAutorelease=YES;
  /*i-995*/objInitFn(self,___rc,___arc,objectIDInTotal,objectIDInClass);
      
  /*i0*///@-999 NSDictionary *d __attribute__((unused)) =([self respondsToSelector:@selector(__initializeUsingDictionary)]?[self performSelector:@selector(__initializeUsingDictionary)]:nil);
          
  /*i999*/return(self);
    }
-(constchar*)cdescription {MSGSTART("RClassabnap:-(constchar*)cdescription")
  return([self.description cStringUsingEncoding:NSASCIIStringEncoding]);}
-(constchar*)cobjectName {MSGSTART("RClassabnap:-(constchar*)cobjectName")
  return([self.objectName cStringUsingEncoding:NSASCIIStringEncoding]);}
-(void)dealloc {MSGSTART("RClassabnap:-(void)dealloc")
  
  /*i-151*/[self die];
/*i998*/deallocFn(self,___rc,___arc,objectIDInTotal,objectIDInClass);
        isZombie=YES;
#if defined(LONGLIVEZOMBIES) || defined(LONGLIVEZOMBIES___WI_CLASS__)
        if (YES) return;
#endif
    
/*i999*/}
-(NSString*)description {MSGSTART("RClassabnap:-(NSString*)description")
  
  /*i-999*/NSMutableString *ret=self.objectName;
          
  /*i999*/return(ret);
    }
-(void)die {MSGSTART("RClassabnap:-(void)die")
  
  /*i900*/}
-(void)fn {MSGSTART("RClassabnap:-(void)fn")
  /*RClassabnap*//*RProtocol*//*RProtocolb*//*RProtocolnap*/}
-(NSMutableString*)objectName {MSGSTART("RClassabnap:-(NSMutableString*)objectName")
  
  /*i-999*/NSMutableString *ret=nil;
          
  /*i-100*/ret=[NSMutableString stringWithFormat:@"[%qu:%p]%s#%qu",objectIDInTotal,self,__Derived_CClass__,objectIDInClass];
          
  /*i999*/return(ret);
    }
-(void)RClassabnapfn {MSGSTART("RClassabnap:-(void)RClassabnapfn")
  /*RClassabnap*/}
-(void)RProtocolbfn {MSGSTART("RClassabnap:-(void)RProtocolbfn")
  /*RProtocolb*/}
-(void)RProtocolfn {MSGSTART("RClassabnap:-(void)RProtocolfn")
  /*RProtocol*/}
-(void)RProtocolnapfn {MSGSTART("RClassabnap:-(void)RProtocolnapfn")
  /*RProtocolnap*/}
-(id)w_autorelease {MSGSTART("RClassabnap:-(id)w_autorelease")
  
  /*i-900*/autoreleaseFn(self,___rc,___arc,debugAutorelease); 
  /*i990*/return(nil/*super*/);}
-(void)w_release {MSGSTART("RClassabnap:-(void)w_release")
  
  /*i-900*/releaseFn(self,___rc,___arc,debugAutorelease); }
-(id)w_retain {MSGSTART("RClassabnap:-(id)w_retain")
  
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
#define _PrivateAccessMask_ __private_access_thread_mask_in_RSubClass

#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_RSubClass
#define _ClassName_ RSubClass
#define _WIClass_ RSubClass__
#define _className_ rSubClass
#define _Class_ RSubClass__
@implementation RSubClass

@synthesize RSubClass=RSubClass;
-(RSubClass*)_startObjectOfClassRSubClass {MSGSTART("RSubClass:-(RSubClass*)_startObjectOfClassRSubClass")

          //@-999 NSDictionary *d __attribute__((unused)) =([self respondsToSelector:@selector(__initializeUsingDictionary)]?[self performSelector:@selector(__initializeUsingDictionary)]:nil);
          
  /*i999*/return(self);
    }
-(void)dealloc {MSGSTART("RSubClass:-(void)dealloc")
  
  /*i-151*/[self die];
/*i999*/}
-(void)die {MSGSTART("RSubClass:-(void)die")
  
  /*i900*/[super die];}
-(void)fn {MSGSTART("RSubClass:-(void)fn")
  /*RSubClass*/}
-(void)RSubClassfn {MSGSTART("RSubClass:-(void)RSubClassfn")
  /*RSubClass*/}
-(id)w_autorelease {MSGSTART("RSubClass:-(id)w_autorelease")
  
  /*i999*/return(nil/*super*/);}
-(void)w_release {MSGSTART("RSubClass:-(void)w_release")
}
-(id)w_retain {MSGSTART("RSubClass:-(id)w_retain")
  
  /*i999*/return(nil/*super*/);}

@end
#undef _ClassName_
#undef _WIClass_
#undef _className_
#undef _Class_










#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_RSubClass2

#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_RSubClass2
#define _ClassName_ RSubClass2
#define _WIClass_ RSubClass2__
#define _className_ rSubClass2
#define _Class_ RSubClass2__
@implementation RSubClass2

@synthesize RSubClass2=RSubClass2;
-(RSubClass2*)_startObjectOfClassRSubClass2 {MSGSTART("RSubClass2:-(RSubClass2*)_startObjectOfClassRSubClass2")

          //@-999 NSDictionary *d __attribute__((unused)) =([self respondsToSelector:@selector(__initializeUsingDictionary)]?[self performSelector:@selector(__initializeUsingDictionary)]:nil);
          
  /*i999*/return(self);
    }
-(void)dealloc {MSGSTART("RSubClass2:-(void)dealloc")
  
  /*i-151*/[self die];
/*i999*/}
-(void)die {MSGSTART("RSubClass2:-(void)die")
  
  /*i900*/[super die];}
-(void)fn {MSGSTART("RSubClass2:-(void)fn")
  /*RSubClass2*/}
-(void)RSubClass2fn {MSGSTART("RSubClass2:-(void)RSubClass2fn")
  /*RSubClass2*/}
-(id)w_autorelease {MSGSTART("RSubClass2:-(id)w_autorelease")
  
  /*i999*/return(nil/*super*/);}
-(void)w_release {MSGSTART("RSubClass2:-(void)w_release")
}
-(id)w_retain {MSGSTART("RSubClass2:-(id)w_retain")
  
  /*i999*/return(nil/*super*/);}

@end
#undef _ClassName_
#undef _WIClass_
#undef _className_
#undef _Class_










#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_RSubClassabnapnac

#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_RSubClassabnapnac
#define _ClassName_ RSubClassabnapnac
#define _WIClass_ RSubClassabnapnac__
#define _className_ rSubClassabnapnac
#define _Class_ RSubClassabnapnac__
@implementation RSubClassabnapnac

@synthesize RSubClassabnapnac=RSubClassabnapnac;
-(RSubClassabnapnac*)_startObjectOfClassRSubClassabnapnac {MSGSTART("RSubClassabnapnac:-(RSubClassabnapnac*)_startObjectOfClassRSubClassabnapnac")

          //@-999 NSDictionary *d __attribute__((unused)) =([self respondsToSelector:@selector(__initializeUsingDictionary)]?[self performSelector:@selector(__initializeUsingDictionary)]:nil);
          
  /*i999*/return(self);
    }
-(void)dealloc {MSGSTART("RSubClassabnapnac:-(void)dealloc")
  
  /*i-151*/[self die];
/*i999*/}
-(void)die {MSGSTART("RSubClassabnapnac:-(void)die")
  
  /*i900*/}
-(void)fn {MSGSTART("RSubClassabnapnac:-(void)fn")
  /*RSubClassabnapnac*/}
-(void)RSubClassabnapnacfn {MSGSTART("RSubClassabnapnac:-(void)RSubClassabnapnacfn")
  /*RSubClassabnapnac*/}
-(id)w_autorelease {MSGSTART("RSubClassabnapnac:-(id)w_autorelease")
  
  /*i999*/return(nil/*super*/);}
-(void)w_release {MSGSTART("RSubClassabnapnac:-(void)w_release")
}
-(id)w_retain {MSGSTART("RSubClassabnapnac:-(id)w_retain")
  
  /*i999*/return(nil/*super*/);}

@end
#undef _ClassName_
#undef _WIClass_
#undef _className_
#undef _Class_

















