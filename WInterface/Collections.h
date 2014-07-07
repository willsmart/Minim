#import <Foundation/Foundation.h>

@interface Collections : NSObject
    +(bool) getInsertsAndDeletesWhenChanging:(NSArray*)from to:(NSArray*)to inss:(NSArray*__strong*)pinss dels:(NSArray*__strong*)pdels;
    +(bool) getInsertsAndDeletesAsIndexSetWhenChanging:(NSArray*)from to:(NSArray*)to inss:(NSIndexSet*__strong*)pinss dels:(NSIndexSet*__strong*)pdels;
    +(bool) getInsertsAndDeletesForSetWhenChanging:(NSSet*)from to:(NSSet*)to inss:(NSSet*__strong*)pinss dels:(NSSet*__strong*)pdels;

@end
