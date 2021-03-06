//Minim autogenerated this file. HaND

//Tasks:
//    Embedded 2 notes (look for "MARK:WI:" in the code)




#pragma mark -
#pragma mark Interfaces:
#ifdef INCLUDE_IFACE

#ifdef INCLUDE_IFACE_D1









@interface PointerKey : NSObject<NSCopying> {
    Unsigned hash;
    id o;
}

@property (nonatomic,readonly) NSString* debugDescription;
@property (nonatomic,readonly) NSString* description;
@property (nonatomic,readonly) Unsigned hash;
@property (strong,nonatomic,readonly) id o;
-(void)_startObjectOfClassPointerKey;
-(id)copyWithZone:(NSZone*)zone;
-(void)dealloc;
-(NSString*)debugDescription;
-(NSString*)description;
-(void)die;
-(id)initWithObject:(id)ao;
-(BOOL)isEqual:(id)object;
+(PointerKey*)keyWithObject:(id)ao;
+(NSObject<NSCopying>*)nscopyingWithObject:(NSObject*)o;
-(id)o;

@end









@interface WeakObject : NSObject<NSCopying> {
    Unsigned hash;
    id o;
}

@property (nonatomic,readonly) NSString* debugDescription;
@property (nonatomic,readonly) NSString* description;
@property (nonatomic,readonly) Unsigned hash;
@property (strong,nonatomic,readonly) id o;
-(void)_startObjectOfClassWeakObject;
-(id)copyWithZone:(NSZone*)zone;
-(void)dealloc;
-(NSString*)debugDescription;
+(NSObject*)deref:(NSObject*)ao;
-(NSString*)description;
-(void)die;
-(id)initWithObject:(id)ao;
-(BOOL)isEqual:(id)object;
+(WeakObject*)keyWithObject:(id)ao;
-(id)o;

@end









#endif // INCLUDE_IFACE_D1

#else // INCLUDE_IFACE





















#pragma mark -
#pragma mark Implementations:










// !!!: Implementations: p


















        #ifdef _PrivateAccessMask_
        #undef _PrivateAccessMask_
        #endif
        #define _PrivateAccessMask_ __private_access_thread_mask_in_Globals

#define _ClassName_ PointerKey
#define _WIClass_ PointerKey__
#define _className_ pointerKey
#define _Class_ PointerKey__
@implementation PointerKey

@synthesize hash=hash;
-(void)_startObjectOfClassPointerKey {MSGSTART("PointerKey:-(void)_startObjectOfClassPointerKey")

    }
-(id)copyWithZone:(NSZone*)zone {MSGSTART("PointerKey:-(id)copyWithZone:(NSZone*)zone")

          return([[PointerKey allocWithZone:zone] initWithObject:o]);
    }
-(void)dealloc {MSGSTART("PointerKey:-(void)dealloc")
  
  /*i-151*/[self die];
/*i0*/o=nil;
/*i999*/}
-(NSString*)debugDescription {MSGSTART("PointerKey:-(NSString*)debugDescription")
  return([NSString stringWithFormat:@"Wrapped:%p",o]);}
-(NSString*)description {MSGSTART("PointerKey:-(NSString*)description")
  return([NSString stringWithFormat:@"Wrapped:%p",o]);}
-(void)die {MSGSTART("PointerKey:-(void)die")
  
  /*i900*/}
-(id)initWithObject:(id)ao {MSGSTART("PointerKey:-(id)initWithObject:(id)ao")

          if (!(self=[super init])) return(nil);
          if (ao) {
                o=ao;
                hash=[o hash];
            }
          else {
                o=ao=self;
                hash=(Unsigned)obfuscateULL((ULL)o);
            }
          return(self);
    }
-(BOOL)isEqual:(id)object {MSGSTART("PointerKey:-(BOOL)isEqual:(id)object")

          bool ret=(([object isKindOfClass:[PointerKey class]]?(o==((PointerKey*)object).o):
                    ([object isKindOfClass:[WeakObject class]]?(o==((WeakObject*)object).o):(o==object)))
                  ||[super isEqual:object]);
          return(ret);
    }
+(PointerKey*)keyWithObject:(id)ao {MSGSTART("PointerKey:+(PointerKey*)keyWithObject:(id)ao")

          return([[PointerKey alloc] initWithObject:ao]);
    }
+(NSObject<NSCopying>*)nscopyingWithObject:(NSObject*)o {MSGSTART("PointerKey:+(NSObject<NSCopying>*)nscopyingWithObject:(NSObject*)o")

          return([o conformsToProtocol:@protocol(NSCopying)]?
                (NSObject<NSCopying>*)o:
                [[PointerKey alloc] initWithObject:o]
            );
    }
-(id)o {MSGSTART("PointerKey:-(id)o")
  
  /*i-999*/id ret=o;
  /*i999*/return(ret);}

@end
#undef _ClassName_
#undef _WIClass_
#undef _className_
#undef _Class_


















// !!!: Implementations: w


















        #ifdef _PrivateAccessMask_
        #undef _PrivateAccessMask_
        #endif
        #define _PrivateAccessMask_ __private_access_thread_mask_in_Globals

#define _ClassName_ WeakObject
#define _WIClass_ WeakObject__
#define _className_ weakObject
#define _Class_ WeakObject__
@implementation WeakObject

@synthesize hash=hash;
-(void)_startObjectOfClassWeakObject {MSGSTART("WeakObject:-(void)_startObjectOfClassWeakObject")

    }
-(id)copyWithZone:(NSZone*)zone {MSGSTART("WeakObject:-(id)copyWithZone:(NSZone*)zone")

          return([[WeakObject allocWithZone:zone] initWithObject:o]);
    }
-(void)dealloc {MSGSTART("WeakObject:-(void)dealloc")
  
  /*i-151*/[self die];
/*i0*/o=nil;
/*i999*/}
-(NSString*)debugDescription {MSGSTART("WeakObject:-(NSString*)debugDescription")
  return([NSString stringWithFormat:@"Weak:%p",o]);}
+(NSObject*)deref:(NSObject*)ao {MSGSTART("WeakObject:+(NSObject*)deref:(NSObject*)ao")

          return(ao?([ao isKindOfClass:[WeakObject class]]?((WeakObject*)ao).o:
                  ([ao isKindOfClass:[PointerKey class]]?((PointerKey*)ao).o:ao)):nil);
    }
-(NSString*)description {MSGSTART("WeakObject:-(NSString*)description")
  return([NSString stringWithFormat:@"Weak:%p",o]);}
-(void)die {MSGSTART("WeakObject:-(void)die")
  
  /*i900*/}
-(id)initWithObject:(id)ao {MSGSTART("WeakObject:-(id)initWithObject:(id)ao")

          if (!(self=[super init])) return(nil);
          o=ao;
          hash=[ao hash];
          return(self);
    }
-(BOOL)isEqual:(id)object {MSGSTART("WeakObject:-(BOOL)isEqual:(id)object")

          bool ret=(([object isKindOfClass:[PointerKey class]]?(o==((PointerKey*)object).o):
                    ([object isKindOfClass:[WeakObject class]]?(o==((WeakObject*)object).o):(o==object)))
                  ||[super isEqual:object]);
          return(ret);
    }
+(WeakObject*)keyWithObject:(id)ao {MSGSTART("WeakObject:+(WeakObject*)keyWithObject:(id)ao")

          return([[WeakObject alloc] initWithObject:ao]);
    }
-(id)o {MSGSTART("WeakObject:-(id)o")
  
  /*i-999*/id ret=o;
  /*i999*/return(ret);}

@end
#undef _ClassName_
#undef _WIClass_
#undef _className_
#undef _Class_


















#endif // INCLUDE_IFACE
