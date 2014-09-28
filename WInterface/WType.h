@interface WType : NSObject {
    bool ocppCompatible,swiftCompatible;
}

@property (readonly) WClass *someWClass;
@property (weak,nonatomic) WClass *clas;
@property (retain,nonatomic) NSMutableSet *protocols;

@property (readonly) WPotentialType *potentialType;
@property (retain,nonatomic) WPotentialType *_potentialType;

@property (nonatomic) bool ocppCompatible,swiftCompatible;

+(WType*)newWithPotentialType:(WPotentialType*)pt;
+(WType*)newWithClass:(WClass*)aclas protocols:(NSArray*)aprotocols addObject:(bool)addObject;
-(void)addClass:(WClass*)aclas protocols:(NSArray*)aprotocols;
@property (readonly) NSString *wiType;
-(NSString*)objCTypeWithStars:(Int)stars;
+(NSString*)objCTypeWithClass:(WClass*)clas protocols:(NSSet*)protocols stars:(Int)stars;

-(void)refreshCompatability;

@end
