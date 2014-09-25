@interface WPotentialType : NSObject

@property (strong,nonatomic) NSString *clas;
@property (retain,nonatomic) NSMutableSet *protocols;

+(WPotentialType*)newWithType:(WType*)t;
+(WPotentialType*)newWithClass:(NSString*)aclas protocols:(NSArray*)aprotocols addObject:(bool)addObject;
-(void)addClass:(NSString*)aclas protocols:(NSArray*)aprotocols;

@end
