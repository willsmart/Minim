@implementation WPotentialType
@synthesize clas,protocols;

- (void)dealloc {
    self.clas=nil;
    self.protocols=nil;
    }

+(WPotentialType*)newWithType:(WType *)t {
    return([[self alloc] initWithType:t]);
}
+(WPotentialType*)newWithClass:(NSString *)aclas protocols:(NSArray *)aprotocols addObject:(bool)addObject {
    return([[self alloc] initWithClass:aclas protocols:aprotocols addObject:addObject]);
}

-(WPotentialType*)initWithType:(WType*)t {
    if (!(self=[super init])) return(nil);
    dprnt("PType : %s\n",[t objCTypeWithStars:0].UTF8String);
    self.clas=(t.clas?t.clas.name:nil);
    self.protocols=(t.protocols?[NSMutableSet set]:nil);
    if (t.protocols) for (WClass *c in t.protocols) [self.protocols addObject:c.name];
    return(self);
}

-(WPotentialType*)initWithClass:(NSString*)aclas protocols:(NSArray*)aprotocols addObject:(bool)addObject {
    if (!(self=[super init])) return(nil);
    dprnt("Type : %s <",aclas.UTF8String);
    [aprotocols enumerateObjectsUsingBlock:^(WClass *obj, NSUInteger idx, BOOL *stop) {
         dprnt(" %s",([obj isKindOfClass:WClass.class]?obj.name:obj.description).UTF8String);
    }];
    dprnt("\n");
    self.clas=nil;
    self.protocols=(addObject?[NSMutableSet setWithObject:@"Object"]:nil);
    [self addClass:aclas protocols:aprotocols];
    return(self);
}
-(void)addClass:(NSString*)aclas protocols:(NSArray*)aprotocols {
    if (aclas) {
        if ((!self.clas)||[self.clas isEqualToString:@"NSObject"]) {
            self.clas=aclas;
        }
    }
    if (aprotocols&&aprotocols.count) {
        if (!(self.protocols&&[aprotocols[0] isKindOfClass:[NSString class]]&&
        ([aprotocols[0] isEqualToString:@"-"]||[aprotocols[0] isEqualToString:@"+"]))) {
            self.protocols=[NSMutableSet set];
        }
        bool adding=YES;
        for (NSObject *o in aprotocols) {
            if ([o isKindOfClass:[NSString class]]) {
                if ([(NSString*)o isEqualToString:@"+"]) adding=YES;
                else if ([(NSString*)o isEqualToString:@"-"]) adding=NO;
                else if (adding) [self.protocols addObject:o];
                else [self.protocols removeObject:o];
            }
        }
    }
}


@end
