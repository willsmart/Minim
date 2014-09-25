@interface InFiles : NSObject {
    NSMutableDictionary *inFilesLocations;
    NSMutableArray *inFilesMessages;
    InFiles *useLocationsFrom;
}

@property (readonly) NSMutableDictionary *inFilesLocations;
@property (readonly) NSMutableArray *inFilesMessages;
@property (retain,nonatomic) InFiles *useLocationsFrom;

+(NSMutableDictionary*)staticInFilesMessages;
+(void)addInFilename:(NSString*)fn line:(Int)line column:(Int)column format:(NSString*)format,...;
-(void)addInFilename:(NSString*)fn line:(Int)line column:(Int)column;
-(void)addInFilesMessageUsingFormat:(NSString*)format,...;
+(NSArray*)allInFiles;
+(void)markFiles:(NSArray*)inFiles;
+(void)markFiles;
+(NSDictionary*)unionFiles:(NSArray*)inFiles;
+(void)insertData:(NSData*)d intoFile:(FILE*)fil at:(Int)offs;
+(void)clearMarksFromFiles:(NSArray*)inFiles;
+(NSString*)excessMsg;


@end

