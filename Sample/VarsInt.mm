//WInterface autogenerated this file. HaND

//Tasks:
//    Embedded 5 notes (look for "notenote" in the code)


#include "sample.wi.h"











#pragma mark -
#pragma mark Implementations:










// !!!: Implementations: v



















#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_VarsInt

#ifdef _PrivateAccessMask_
#undef _PrivateAccessMask_
#endif
#define _PrivateAccessMask_ __private_access_thread_mask_in_VarsInt
#define _ClassName_ VarsInt
#define _WIClass_ VarsInt__
#define _className_ varsInt
#define _Class_ VarsInt__
@implementation VarsInt

@synthesize ___arc=___arc;
@synthesize ___rc=___rc;
@synthesize __owner_context=__owner_context;
@synthesize debugAutorelease=debugAutorelease;
@synthesize isZombie=isZombie;
@synthesize objectIDInClass=objectIDInClass;
@synthesize objectIDInTotal=objectIDInTotal;
@synthesize pr_iv_def_nm_publicreadonly=pr_iv_def_nm_publicreadonly;
@synthesize rw_iv_def_nm_atomici=rw_iv_def_nm_atomici;
@synthesize rw_iv_nm_settergetteri=rw_iv_nm_settergetteri;
@synthesize rw_iv_nodef_short_zero=rw_iv_nodef_short_zero;
@synthesize rw_na_iv_def1_short_one=rw_na_iv_def1_short_one;
@synthesize rw_na_iv_nodef_short_declInVarsBase=rw_na_iv_nodef_short_declInVarsBase;
@synthesize rw_na_iv_nodef_short_nill=rw_na_iv_nodef_short_nill;
-(VarsInt*)_startObjectOfClassVarsInt {MSGSTART("VarsInt:-(VarsInt*)_startObjectOfClassVarsInt")
  
  /*i-996*/debugAutorelease=YES;
  /*i-995*/objInitFn(self,___rc,___arc,objectIDInTotal,objectIDInClass);
      
  /*i-500*//*ivar*/rw_iv_nm_settergetteri=(123);
   /*ivar*/rw_iv_def_nm_atomici=(123);
   /*ivar*/rw_na_iv_def1_short_one=(1);
   /*ivar*/rw_iv_nm_settergetter2=(123);
   /*ivar*/pr_iv_def_nm_publicreadonly=(123);
   /*ivar*/rw_iv_nm_settergetter=(123);
  
  /*i0*///@-999 NSDictionary *d __attribute__((unused)) =([self respondsToSelector:@selector(__initializeUsingDictionary)]?[self performSelector:@selector(__initializeUsingDictionary)]:nil);
          
  /*i999*/return(self);
    }
-(constchar*)cdescription {MSGSTART("VarsInt:-(constchar*)cdescription")
  return([self.description cStringUsingEncoding:NSASCIIStringEncoding]);}
-(constchar*)cobjectName {MSGSTART("VarsInt:-(constchar*)cobjectName")
  return([self.objectName cStringUsingEncoding:NSASCIIStringEncoding]);}
-(void)dealloc {MSGSTART("VarsInt:-(void)dealloc")
  
  /*i-151*/[self die];
/*i998*/deallocFn(self,___rc,___arc,objectIDInTotal,objectIDInClass);
        isZombie=YES;
#if defined(LONGLIVEZOMBIES) || defined(LONGLIVEZOMBIES___WI_CLASS__)
        if (YES) return;
#endif
    
/*i999*/}
-(NSString*)description {MSGSTART("VarsInt:-(NSString*)description")
  
  /*i-999*/NSMutableString *ret=self.objectName;
          
  /*i999*/return(ret);
    }
-(void)die {MSGSTART("VarsInt:-(void)die")
  
  /*i900*/}
-(NSMutableString*)objectName {MSGSTART("VarsInt:-(NSMutableString*)objectName")
  
  /*i-999*/NSMutableString *ret=nil;
          
  /*i-100*/ret=[NSMutableString stringWithFormat:@"[%qu:%p]%s#%qu",objectIDInTotal,self,__Derived_CClass__,objectIDInClass];
          
  /*i999*/return(ret);
    }
-(Int)pr_iv_nm_getteri {MSGSTART("VarsInt:-(Int)pr_iv_nm_getteri")
  return(pr_iv_nm_getteri);}
-(Int)pr_iv_nm_ivar {MSGSTART("VarsInt:-(Int)pr_iv_nm_ivar")
  return(123);}
-(Int)pr_iv_nm_ivar_named {MSGSTART("VarsInt:-(Int)pr_iv_nm_ivar_named")
  return(123);}
-(Int)pr_iv_nm_setter {MSGSTART("VarsInt:-(Int)pr_iv_nm_setter")
  
  /*i-999*/Int ret=pr_iv_nm_setter;
  /*i999*/return(ret);}
-(Int)r_noiv_nm_getteri {MSGSTART("VarsInt:-(Int)r_noiv_nm_getteri")
  return(123);}
-(Int)rw_iv_nm_settergetter {MSGSTART("VarsInt:-(Int)rw_iv_nm_settergetter")
  return(123);}
-(Int)rw_iv_nm_settergetter2 {MSGSTART("VarsInt:-(Int)rw_iv_nm_settergetter2")
  return(rw_iv_nm_settergetter2);}
-(Int)rw_iv_nm_setteri {MSGSTART("VarsInt:-(Int)rw_iv_nm_setteri")
  
  /*i-999*/Int ret=rw_iv_nm_setteri;
  /*i999*/return(ret);}
-(Int)rw_noiv_nm_settergetter {MSGSTART("VarsInt:-(Int)rw_noiv_nm_settergetter")
  return(123);}
-(Int)rw_noiv_nm_setteri {MSGSTART("VarsInt:-(Int)rw_noiv_nm_setteri")
  
  /*i-999*/Int ret;memset(&ret,0,sizeof(ret));
  /*i999*/return(ret);}
-(void)setPr_iv_nm_getteri:(Int)v {MSGSTART("VarsInt:-(void)setPr_iv_nm_getteri:(Int)v")
  
  /*i-905*/if(!memcmp(&pr_iv_nm_getteri,&v,sizeof(pr_iv_nm_getteri)))return;
  /*i-900*/memcpy(&pr_iv_nm_getteri,&v,sizeof(pr_iv_nm_getteri));}
-(void)setPr_iv_nm_ivar:(Int)v {MSGSTART("VarsInt:-(void)setPr_iv_nm_ivar:(Int)v")
  
  /*i-905*/if(!memcmp(&pr_iv_nm_ivar,&v,sizeof(pr_iv_nm_ivar)))return;
  /*i-900*/memcpy(&pr_iv_nm_ivar,&v,sizeof(pr_iv_nm_ivar));}
-(void)setPr_iv_nm_ivar_named:(Int)v {MSGSTART("VarsInt:-(void)setPr_iv_nm_ivar_named:(Int)v")
  
  /*i-905*/if(!memcmp(&the_ivar_named,&v,sizeof(the_ivar_named)))return;
  /*i-900*/memcpy(&the_ivar_named,&v,sizeof(the_ivar_named));}
-(void)setPr_iv_nm_setter:(Int)v {MSGSTART("VarsInt:-(void)setPr_iv_nm_setter:(Int)v")
  pr_iv_nm_setter=123;}
-(void)setRw_iv_nm_settergetter2:(Int)v {MSGSTART("VarsInt:-(void)setRw_iv_nm_settergetter2:(Int)v")
}
-(void)setRw_iv_nm_settergetter:(Int)v {MSGSTART("VarsInt:-(void)setRw_iv_nm_settergetter:(Int)v")
  rw_iv_nm_settergetter=123;}
-(void)setRw_iv_nm_setteri:(Int)v {MSGSTART("VarsInt:-(void)setRw_iv_nm_setteri:(Int)v")
  rw_iv_nm_setteri=123;}
-(void)setRw_noiv_nm_settergetter:(Int)v {MSGSTART("VarsInt:-(void)setRw_noiv_nm_settergetter:(Int)v")
}
-(void)setRw_noiv_nm_setteri:(Int)v {MSGSTART("VarsInt:-(void)setRw_noiv_nm_setteri:(Int)v")
}
-(void)testGetterSetter {MSGSTART("VarsInt:-(void)testGetterSetter")

          pr_iv_def_nm_publicreadonly=pr_iv_def_nm_publicreadonly;
          rw_iv_def_nm_atomici=rw_iv_def_nm_atomici;
          rw_iv_nm_settergetteri=rw_iv_nm_settergetteri;
          pr_iv_nm_getteri=r_noiv_nm_getteri;
          pr_iv_nm_getteri=pr_iv_nm_getteri;
          pr_iv_nm_setter=pr_iv_nm_setter;
          rw_iv_nm_setteri=rw_iv_nm_setteri;
          rw_noiv_nm_setteri=rw_noiv_nm_setteri;
          rw_iv_nm_settergetter=rw_iv_nm_settergetter;
          rw_iv_nm_settergetter2=rw_iv_nm_settergetter2;
          pr_iv_nm_ivar=pr_iv_nm_ivar;
          pr_iv_nm_ivar_named=pr_iv_nm_ivar_named;
    }
-(id)w_autorelease {MSGSTART("VarsInt:-(id)w_autorelease")
  
  /*i-900*/autoreleaseFn(self,___rc,___arc,debugAutorelease); 
  /*i990*/return(nil/*super*/);}
-(void)w_release {MSGSTART("VarsInt:-(void)w_release")
  
  /*i-900*/releaseFn(self,___rc,___arc,debugAutorelease); }
-(id)w_retain {MSGSTART("VarsInt:-(id)w_retain")
  
  /*i-900*/retainFn(self,___rc,___arc); 
  /*i999*/return(nil/*super*/);}

@end
#undef _ClassName_
#undef _WIClass_
#undef _className_
#undef _Class_


















