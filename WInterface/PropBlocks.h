//
//  PropBlocks.h
//  WInterface
//
//  Created by Will Smart on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class hisclass11,hisclass1S,hisclassS1,hisclass1A,hisclassA1;
@class myclass,myclass11,myclass1S,myclassS1,myclass1A,myclassA1;

@interface PropBlockType : NSObject {
    bool inIFace,inImpl,inIVar,inDealloc,inDie,inInit;
}
- (id)initWithMyType:(char)amytype hisType:(char)ahistype;
@property char mytype,histype;
@property (retain,nonatomic) NSMutableString *ivarStr,*ifaceStr,*deallocStr,*dieStr,*initStr,*implStr;
- (void)readLine:(NSString*)line;

+ (NSString*)string:(NSString*)s withMyClass:(NSString*)myclass myName:(NSString*)myname hisClass:(NSString*)hisclass hisName:(NSString*)hisname;

@end



@interface PropBlocks : NSObject

@property (retain,nonatomic) NSMutableArray *types;
- (PropBlockType*)typeForMyType:(char)myTtpe hisType:(char)histype;
+ (PropBlocks*)getDefault;
+ (void)clearStaticData;

@end















@interface myclass : NSObject

// Properties
@property (readonly) int propRefCnt;
- (void)die;
- (void)getPropertiesUsingContext:(NSMutableDictionary*)constructionContext;

@end


@interface myclass11 : NSObject

// One-to-one property myname
{
    hisclass11 *hisname;
    int propRefCnt;
}
@property (assign,nonatomic) hisclass11 *hisname; 
- (void)die; 
- (void)getPropertiesUsingContext:(NSMutableDictionary*)constructionContext; 
//+ (myclass11*)get_myname_given_context:(NSMutableDictionary*)constructionContext; 

@end


@interface myclass1S : NSObject 

// One-to-set property myname
{
    NSSet *hisnames;
    int propRefCnt;
}
@property (readonly) NSSet *hisnames; 
@property (retain,nonatomic) NSMutableSet *_hisnames; 
- (bool)containsHisname:(hisclassS1*)hisname; 
- (bool)removeHisname:(hisclassS1*)hisname; 
- (bool)addHisname:(hisclassS1*)hisname; 
- (void)removeAllHisnames; 
- (void)unionHisnames:(NSSet*)ahisnames; 
- (void)addHisnamesInArray:(NSArray*)ahisnames; 
- (void)die; 
- (void)getPropertiesUsingContext:(NSMutableDictionary*)constructionContext; 
//+ (myclass1S*)get_myname_given_context:(NSMutableDictionary*)constructionContext; 

@end


@interface myclassS1 : NSObject

// Set-to-one property myname
{
    hisclass1S *hisname;
    int propRefCnt;
}
@property (assign,nonatomic) hisclass1S *hisname; 
- (void)die; 
- (void)getPropertiesUsingContext:(NSMutableDictionary*)constructionContext; 
//+ (NSSet*)get_mynames_given_context:(NSMutableDictionary*)constructionContext; 

@end


@interface myclass1A : NSObject

// One-to-array property myname
{
    NSArray *hisnames;
    int propRefCnt;
}
@property (readonly) NSArray *hisnames; 
@property (retain,nonatomic) NSMutableArray *_hisnames; 
- (hisclassA1*)hisnameAtIndex:(int)__index; 
- (bool)insertHisname:(hisclassA1*)hisname atIndex:(int)__index; 
- (bool)moveHisnameAtIndex:(int)__fromIndex toIndex:(int)__toIndex; 
- (bool)removeHisnameAtIndex:(int)__index; 
- (bool)containsHisname:(hisclassA1*)hisname; 
- (bool)removeHisname:(hisclassA1*)hisname; 
- (bool)addHisname:(hisclassA1*)hisname; 
- (void)removeAllHisnames; 
- (void)addHisnamesInArray:(NSArray*)ahisnames; 
- (void)die; 
- (void)getPropertiesUsingContext:(NSMutableDictionary*)constructionContext; 
//+ (myclass1A*)get_myname_given_context:(NSMutableDictionary*)constructionContext; 

@end


@interface myclassA1 : NSObject

// Array-to-one property myname
{
    hisclass1A *hisname;
    int propRefCnt;
    int indexInHisname;
}
@property (assign,nonatomic) hisclass1A *hisname; 
@property int indexInHisname; 
- (void)___setHisnameIndex:(int)__v; 
- (void)die; 
- (void)getPropertiesUsingContext:(NSMutableDictionary*)constructionContext; 
//+ (NSArray*)get_mynames_given_context:(NSMutableDictionary*)constructionContext; 

@end










@interface hisclass11 : NSObject
@property (assign,nonatomic) myclass11 *myname; 
@end

@interface hisclass1S : NSObject
- (bool)removeMyname:(myclassS1*)myname; 
- (bool)addMyname:(myclassS1*)myname; 
@end

@interface hisclassS1 : NSObject
@property (assign,nonatomic) myclass1S *myname; 
@end

@interface hisclass1A : NSObject
- (bool)moveHisnameAtIndex:(int)__fromIndex toIndex:(int)__toIndex; 
- (bool)removeMynameAtIndex:(int)__index; 
- (bool)addMyname:(myclassA1*)myname; 
@end

@interface hisclassA1 : NSObject
@property (assign,nonatomic) myclass1A *myname; 
- (void)___setMynameIndex:(int)__v; 
@end


