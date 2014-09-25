@class WReaderToken;

@protocol WReaderTokenDelegate
-(NSString*)processedStringForString:(NSString*)s inToken:(WReaderToken*)token;
@end
