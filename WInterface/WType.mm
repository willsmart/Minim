@implementation WType
@synthesize clas,protocols,_potentialType;

- (void)dealloc {
    self.clas=nil;
    self.protocols=nil;
    }

-(WPotentialType*)potentialType {
    if (!self._potentialType) self._potentialType=[WPotentialType newWithType:self];
    return(self._potentialType);
}

-(WClass*)someWClass {
    if (self.clas) return(self.clas);
    if (self.protocols) for (WClass *c in self.protocols) return(c);
    return(nil);
}


+(WType*)newWithPotentialType:(WPotentialType*)pt {
    return([[self alloc] initWithPotentialType:pt]);
}
+(WType*)newWithClass:(WClass *)aclas protocols:(NSArray *)aprotocols addObject:(bool)addObject {
    return([[self alloc] initWithClass:aclas protocols:aprotocols addObject:addObject]);
}

-(WType*)initWithPotentialType:(WPotentialType*)pt {
    if (!(self=[super init])) return(nil);
    dprnt("Type : %s <",pt.clas.UTF8String);
    [pt.protocols enumerateObjectsUsingBlock:^(WClass *obj, BOOL *stop) {
         dprnt(" %s",([obj isKindOfClass:WClass.class]?obj.name:obj.description).UTF8String);
    }];
    dprnt("\n");
    self.clas=(pt.clas?[WClass getClassWithName:pt.clas]:nil);
    self.protocols=(pt.protocols?[NSMutableSet set]:nil);
    if (pt.protocols) for (NSString *s in pt.protocols) [self.protocols addObject:[WClass getProtocolWithName:s]];
    return(self);
}
-(WType*)initWithClass:(WClass*)aclas protocols:(NSArray*)aprotocols addObject:(bool)addObject {
    if (!(self=[super init])) return(nil);
    dprnt("Type : %s <",aclas.name.UTF8String);
    [aprotocols enumerateObjectsUsingBlock:^(WClass *obj, NSUInteger idx, BOOL *stop) {
         dprnt(" %s",([obj isKindOfClass:WClass.class]?obj.name:obj.description).UTF8String);
    }];
    dprnt("\n");
    self.clas=nil;
    self.protocols=(addObject?[NSMutableSet setWithObject:[WClass getProtocolWithName:@"Object"]]:nil);
    [self addClass:aclas protocols:aprotocols];
    return(self);
}
-(void)addClass:(WClass*)aclas protocols:(NSArray*)aprotocols {
    if (aclas) {
        if ((!self.clas)||[self.clas.name isEqualToString:@"NSObject"]) {
            self.clas=aclas;
        }
    }
    if (aprotocols&&aprotocols.count) {
        if (!(self.protocols&&[aprotocols[0] isKindOfClass:[NSString class]])) {
            self.protocols=[NSMutableSet set];
        }
        bool adding=YES;
        for (NSObject *o in aprotocols) {
            if ([o isKindOfClass:[NSString class]]) {
                if ([(NSString*)o isEqualToString:@"+"]) adding=YES;
                else if ([(NSString*)o isEqualToString:@"-"]) adding=NO;
            }
            else if ([o isKindOfClass:[WClass class]]) {
                if (adding) [self.protocols addObject:o];
                else [self.protocols removeObject:o];
            }
        }
    }
}


-(NSString*)wiType {
    WClass *c=self.clas;
    if (self.protocols.count) {
        if ([c.name isEqualToString:@"NSObject"]) c=nil;
    }
    else if (!c) c=[WClass getClassWithName:@"NSObject"];
    NSMutableString *s=[NSMutableString string];
    if (c) [s appendString:c.name];
    if (self.protocols.count) {
        bool fst=YES;
        for (WClass *p in self.protocols) {
            [s appendFormat:(fst?@"<%@":@",%@"),p.name];
            fst=NO;
        }
        [s appendString:@">"];
    }
    return(s);
}

-(NSString*)objCTypeWithStars:(Int)stars {
    return([WType objCTypeWithClass:self.clas protocols:self.protocols stars:stars]);
}

+(NSString*)objCTypeWithClass:(WClass*)clas protocols:(NSSet*)protocols stars:(Int)stars {
    NSMutableString *s=[NSMutableString stringWithString:(clas?clas.name:@"NSObject")];
    if (protocols.count) {
        bool fst=YES;
        for (WClass *p in protocols) {
            [s appendFormat:(fst?@"<%@":@",%@"),p.name];
            fst=NO;
        }
        [s appendString:@">"];
    }
    if (!(stars||clas.isType)) stars=1;
    for (Int i=0;i<stars;i++) [s appendString:@"*"];
    return(s);
}

@end




