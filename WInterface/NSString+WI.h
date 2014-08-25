enum {
    StringHelper_rangeWontExpandToContainString=0,
    StringHelper_rangeExpandsToContainString=3,

    StringHelper_rangeStartExpandsToContainString=1,
    StringHelper_rangeStartWontExpandToContainString=0,

    StringHelper_rangeEndExpandsToContainString=2,
    StringHelper_rangeEndWontExpandToContainString=0
};

@interface NSString(WI)

@property (readonly) NSString *to_underscored_case, *ToUpperCamelCase, *toLowerCamelCase;


//-(NSString*)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
-(NSString*)stringByReplacingPairs:(NSObject*)firstNeedle,...;
-(NSString*)stringByEncodingHTMLEntities;
-(NSString*)stringByEncodingCEscapes;
-(NSString*)stringByDecodingCEscapes;

-(NSString*)stringByAppendingString:(NSString *)aString adjustingRanges:(NSMutableArray*)ranges;
-(NSString*)stringByPaddingToLength:(NSUInteger)newLength withString:(NSString *)padString startingAtIndex:(NSUInteger)padIndex adjustingRanges:(NSMutableArray*)ranges;
-(NSString*)stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement adjustingRanges:(NSMutableArray*)ranges;
-(NSString*)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange adjustingRanges:(NSMutableArray*)ranges;
-(NSString*)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement adjustingRanges:(NSMutableArray*)ranges;
-(NSString*)stringByDeletingCharactersInSet:(NSCharacterSet *)set adjustingRanges:(NSMutableArray*)ranges;

-(BOOL)writeToFileCreatingIntermediateDirectories:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError *__autoreleasing *)error;

@end
