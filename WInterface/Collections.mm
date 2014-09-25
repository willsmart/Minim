
@implementation Collections
    +(bool) getInsertsAndDeletesWhenChanging:(NSArray*)from to:(NSArray*)to inss:(NSArray*__strong*)pinss dels:(NSArray*__strong*)pdels  {
        NSMutableArray *dels=[[NSMutableArray alloc] init];
        NSMutableArray *inss=[[NSMutableArray alloc] init];

        *pinss=inss;
        *pdels=dels;
        
        bool ret=NO;
        if (from==nil) {
            if (to) {
                Int i=0;
                while (i<to.count) [inss addObject:@(i++)];
                ret=(i>0);
            }
        }
        else if (to==nil) {
            Int i=0;
            while (i<from.count) [dels addObject:@(i++)];
            ret=(i>0);
        }
        else {
            Int toi=0,fromi=0;
            while ((toi<[to count])||(fromi<[from count])) {
                char op=0;
                if (fromi>=[from count]) op='i';
                else if (toi>=[to count]) op='d';
                else if ([from[fromi] isEqual:to[toi]]) op=0;
                else for (Int j=1;;j++) {
                    if (toi+j>=[to count]) {op='d';break;}
                    else if (fromi+j>=[from count]) {op='i';break;}
                    else if ([from[fromi] isEqual:to[toi+j]]) {op='i';break;}
                    else if ([from[fromi+j] isEqual:to[toi]]) {op='d';break;}
                }
                if (op=='d') {
                    [dels insertObject:@(fromi) atIndex:0];
                    fromi++;
                }
                else if (op=='i') {
                    [inss addObject:@(toi)];
                    toi++;
                }
                else {fromi++;toi++;}
            }
            ret=(inss.count||dels.count);
        }
        if (!ret) {
            *pinss=nil;
            *pdels=nil;
        }
        return(ret);
    }

    +(bool) getInsertsAndDeletesAsIndexSetWhenChanging:(NSArray*)from to:(NSArray*)to inss:(NSIndexSet*__strong*)pinss dels:(NSIndexSet*__strong*)pdels  {
        NSMutableArray *inss,*dels;
        if (![Collections getInsertsAndDeletesWhenChanging:from to:to inss:&inss dels:&dels]) return(NO);
        NSMutableIndexSet *s=[[NSMutableIndexSet alloc] init];
        for (NSNumber *num in dels) [s addIndex:num.intValue];
        *pdels=s;
        s=[[NSMutableIndexSet alloc] init];
        for (NSNumber *num in inss) [s addIndex:num.intValue];
        *pinss=s;
        return(YES);
    }

    /*+(bool) getInsertsAndDeletesAsIndexPathsInSection:(Int)section whenChanging:(NSArray*)from to:(NSArray*)to inss:(NSArray*__strong*)pinss dels:(NSArray*__strong*)pdels {
        if (![Util getInsertsAndDeletesWhenChanging:from to:to inss:pinss dels:pdels]) return(NO);
        NSMutableArray *dels=[MutableArray array];
        NSMutableArray *inss=[MutableArray array];
        for (NSNumber *num in *pdels) [dels addObject:[NSIndexPath indexPathForRow:num.intValue inSection:section]];
        for (NSNumber *num in *pinss) [inss addObject:[NSIndexPath indexPathForRow:num.intValue inSection:section]];
        *pinss=inss;
        *pdels=dels;
        return(YES);
    }*/

    +(bool) getInsertsAndDeletesForSetWhenChanging:(NSSet*)from to:(NSSet*)to inss:(NSSet*__strong*)pinss dels:(NSSet*__strong*)pdels  {
        if ([from isEqualToSet:to]) return(NO);
        if (!(pinss||pdels)) return(YES);
        if (pinss) [(NSMutableSet*)((*pinss=to.mutableCopy)) minusSet:from];
        if (pdels) [(NSMutableSet*)((*pdels=from.mutableCopy)) minusSet:to];
        return(YES);
    }


    +(bool) getInsertsDeletesAndChangesForDictionaryWhenChanging:(NSDictionary*)from to:(NSDictionary*)to insKeys:(NSSet*__strong*)pinss delKeys:(NSSet*__strong*)pdels changeKeys:(NSSet*__strong*)pchanges  {
        NSSet *fromKeys=[[NSSet alloc] initWithArray:from.allKeys];
        NSSet *toKeys=[[NSSet alloc] initWithArray:to.allKeys];
        bool ret=[Collections getInsertsAndDeletesForSetWhenChanging:fromKeys to:toKeys inss:pinss dels:pdels];
        id obj;
        NSMutableSet *changes=nil;
        if (from.count<to.count) {
            for (id<NSCopying> key in from) if ((obj=to[key])&&![obj isEqual:from[key]]) {
                if (!changes) changes=[[NSMutableSet alloc] init];
                [changes addObject:key];
            }
        }
        else {
            for (id<NSCopying> key in to) if ((obj=from[key])&&![obj isEqual:to[key]]) {
                if (!changes) changes=[[NSMutableSet alloc] init];
                [changes addObject:key];
            }
        }
        NSSet *imchanges=changes;
        if (imchanges) ret=YES;
        else if (ret) imchanges=[[NSSet alloc] init];
        if (pchanges) *pchanges=imchanges;
        if (ret) {
            if (pinss&&!*pinss) *pinss=[[NSSet alloc] init];
            if (pdels&&!*pdels) *pdels=[[NSSet alloc] init];
        }
        return(ret);
    }

@end
