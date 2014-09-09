
@implementation NSString(WI)

-(NSString*)to_underscored_case {
    NSError *err=nil;
    // change things like "DirectMessage" to "direct_message"
    return([[[NSRegularExpression regularExpressionWithPattern:@"(?!^)([A-Z])" options:0 error:&err] stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:@"_$1"] lowercaseString]);
}


-(NSString*)ToUpperCamelCase {
    // change things like "direct_message" to "DirectMessage"
    return([self toUpperOrLowerCamelCase:YES]);
}

-(NSString*)toLowerCamelCase {
    // change things like "direct_message" to "directMessage"
    return([self toUpperOrLowerCamelCase:NO]);
}

-(NSString*)toUpperOrLowerCamelCase:(BOOL)UpperCamelCase {
    if (!self.length) return(@"");
    NSMutableString *ret=(UpperCamelCase?[[self substringToIndex:1] uppercaseString]:[[self substringToIndex:1] lowercaseString]).mutableCopy;
    NSUInteger start=1;
    do {
        NSRange r=[self rangeOfString:@"_" options:0 range:NSMakeRange(start, self.length-start)];
        if ((r.location!=NSNotFound)&&(self.length>r.location+r.length)) {
            [ret appendString:[self substringWithRange:NSMakeRange(start, r.location-start)]];
            [ret appendString:[[self substringWithRange:NSMakeRange(r.location+r.length,1)] uppercaseString]];
            start=r.location+r.length+1;
        }
        else break;
    }
    while (YES);
    [ret appendString:[self substringFromIndex:start]];
    return(ret.copy);
}



//-(NSString*)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
//    return((__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)self,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%[]% ",CFStringConvertNSStringEncodingToEncoding(encoding)));
//}


-(NSString*)stringByReplacingPairs:(NSObject*)firstNeedle,... {
    NSMutableString *s=self.mutableCopy;
    va_list args;va_start(args,firstNeedle);
    for (NSObject *k=firstNeedle;k!=nil;k=va_arg(args,NSObject*)) {
        NSObject *o=va_arg(args,NSObject*);
        if (!o) break;
        if ([k isKindOfClass:[NSString class]]&&[o isKindOfClass:[NSString class]]) {
            [s replaceOccurrencesOfString:(NSString*)k withString:(NSString*)o options:0 range:NSMakeRange(0, s.length)];
        }
    }
    return(s.copy);
}

-(NSString*)stringByEncodingHTMLEntities {
    return([self stringByReplacingPairs:@"&",@"&amp;",@"<",@"&lt;",@">",@"&gt;",@"\"",@"&quot;",@"\n",@"<br/>\n",nil]);
}

-(NSString*)stringByEncodingCEscapes {
    return([self stringByReplacingPairs:@"\\",@"\\\\",@"\"",@"\\\"",@"\n",@"\\n",@"\r",@"\\r",@"\t",@"\\t",nil]);
}

-(NSString*)stringByDecodingCEscapes {
    return([self stringByReplacingPairs:@"\\\\",@"\\\\ ",@"\\t",@"\t",@"\\r",@"\r",@"\\n",@"\n",@"\\\"",@"\"",@"\\'",@"'",@"\\\\ ",@"\\",nil]);
}








#pragma mark These allow you to track the changes in the positions/lengths of ranges on a string as the string changes

-(NSString*)stringByAppendingString:(NSString *)aString adjustingRanges:(NSMutableArray*)ranges {
    [self adjustRanges:ranges afterReplacingCharactersInRange:NSMakeRange(self.length,0) withStringOfLength:aString.length];
    return([self stringByAppendingString:aString]);
}

-(NSString*)stringByPaddingToLength:(NSUInteger)newLength withString:(NSString *)padString startingAtIndex:(NSUInteger)padIndex adjustingRanges:(NSMutableArray*)ranges {
    NSString *ret=[self stringByPaddingToLength:newLength withString:padString startingAtIndex:padIndex];
    [self adjustRanges:ranges afterReplacingCharactersInRange:NSMakeRange(MIN(self.length,ret.length),MAX(0,self.length-ret.length)) withStringOfLength:MAX(0,ret.length-self.length)];
    return(ret);
}

-(NSString*)stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement adjustingRanges:(NSMutableArray*)ranges {
    [self adjustRanges:ranges afterReplacingCharactersInRange:range withStringOfLength:replacement.length];
    return([self stringByReplacingCharactersInRange:range withString:replacement]);
}

-(NSString*)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange adjustingRanges:(NSMutableArray*)ranges {
    NSInteger offsetDueToPreviouslyAdjustedChars=0;
    for (NSRange r=[self rangeOfString:target options:options range:searchRange];r.location!=NSNotFound;r=[self rangeOfString:target options:options range:NSMakeRange(r.location+r.length, (searchRange.location+searchRange.length)-(r.location+r.length))]) {
        // adjust after replacing string
        [self adjustRanges:ranges afterReplacingCharactersInRange:NSMakeRange(r.location+offsetDueToPreviouslyAdjustedChars, r.length) withStringOfLength:replacement.length];
        // since we are iterating from left to right, we are adjusting chars that may have shifted with a previous adjustment. Basically the string is out of sync with the ranges for a bit. This fixes that
        offsetDueToPreviouslyAdjustedChars+=replacement.length-r.length;
    }
    return([self stringByReplacingOccurrencesOfString:target withString:replacement options:options range:searchRange]);
}

-(NSString*)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement adjustingRanges:(NSMutableArray*)ranges {
    return([self stringByReplacingOccurrencesOfString:target withString:replacement options:0 range:NSMakeRange(0, self.length) adjustingRanges:ranges]);
}

-(NSString*)stringByDeletingCharactersInSet:(NSCharacterSet *)set adjustingRanges:(NSMutableArray*)ranges {
    NSMutableString *mself=self.mutableCopy;
    for (NSRange r=[mself rangeOfCharacterFromSet:set];r.location!=NSNotFound;r=[mself rangeOfCharacterFromSet:set options:0 range:NSMakeRange(r.location+r.length, mself.length-(r.location+r.length))]) {
        // adjust after removing char
        [self adjustRanges:ranges afterReplacingCharactersInRange:r withStringOfLength:0];
        [mself deleteCharactersInRange:r];
        r.length=0;
    }
    return(mself.copy);
}



-(NSRange)potentialRangeOfAdjustedIndex:(NSInteger)index afterReplacingCharactersInRange:(NSRange)removeRange withStringOfLength:(NSUInteger)insertLength {
    // if all that changed is the chars, then we couldn't make a better new position than just using the old one
    if (removeRange.length==insertLength) return(NSMakeRange(index, 0));
    
    if (index<removeRange.location) {
        //      rrrrr
        //   ^
        // no change
        return(NSMakeRange(index,0));
    }
    else if (index==removeRange.location) {
        //      rrrrr
        //      ^
        // prob no change, but if just inserting a string we might want to insert it to the left (and in that case we would move)
        return(NSMakeRange(index, removeRange.length?0:insertLength));
    }
    else if (index<removeRange.location+removeRange.length) {
        //      rrrrr
        //        ^
        // Could be anywhere in the range now
        return(NSMakeRange(removeRange.location, insertLength));
    }
    else if (index==removeRange.location+removeRange.length) {
        //      rrrrr
        //           ^
        // prob still at end of range, but if just inserting a string we might want to insert it to the right (and in that case we would move back)
        return(NSMakeRange(removeRange.location+(removeRange.length?insertLength:0), removeRange.length?0:insertLength));
    }
    else {
        //      rrrrr
        //             ^
        // just move index as normal
        return(NSMakeRange(index+insertLength-removeRange.length, 0));
    }
}


-(void)adjustRanges:(NSMutableArray*)ranges afterReplacingCharactersInRange:(NSRange)removeRange withStringOfLength:(NSUInteger)insertLength  {
    if (!ranges) return;
    
    bool expandLower=NO,expandHigher=YES;// if a string is inserted right on the boundary, should I expand?

    NSInteger index=0;
    for (NSValue *v in ranges.copy) if ([v respondsToSelector:@selector(rangeValue)]) {
        NSRange range=v.rangeValue;
        
        NSRange potentialStartRange=[self potentialRangeOfAdjustedIndex:range.location afterReplacingCharactersInRange:removeRange withStringOfLength:insertLength];
        NSRange potentialEndRange=[self potentialRangeOfAdjustedIndex:range.location+range.length afterReplacingCharactersInRange:removeRange withStringOfLength:insertLength];
        
        NSInteger newStart=potentialStartRange.location+(expandLower?0:potentialStartRange.length);
        NSInteger newEnd=potentialEndRange.location+(expandHigher?potentialEndRange.length:0);
        
        // if not expanding either end, default to right side of inserted string
        if (newEnd<newStart) newEnd=newStart;
        
        NSRange newRange=NSMakeRange(newStart,newEnd-newStart);
        [ranges replaceObjectAtIndex:index++ withObject:[NSValue valueWithRange:newRange]];
    }
    else if ([v isKindOfClass:NSNumber.class]) {
        switch ([(NSNumber*)v integerValue]) {
            case StringHelper_rangeWontExpandToContainString:expandHigher=expandLower=NO;break;
            case StringHelper_rangeStartExpandsToContainString:expandLower=YES;expandHigher=NO;break;
            case StringHelper_rangeEndExpandsToContainString:expandLower=NO;expandHigher=YES;break;
            case StringHelper_rangeExpandsToContainString:expandHigher=expandLower=YES;break;
        }
    }
}



-(BOOL)writeToFileCreatingIntermediateDirectories:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError *__autoreleasing *)error {
    NSFileManager *fileManager=NSFileManager.defaultManager;
    NSString *dir=path.stringByDeletingLastPathComponent;
    BOOL isDir=YES;
    if (!([fileManager fileExistsAtPath:dir isDirectory:&isDir]&&isDir)) {
        if (!isDir) {
            if (![fileManager removeItemAtPath:dir error:error]) {
                return(NO);
            }
        }
        if (![fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:error]) {
            return(NO);
        }
    }
    return([self writeToFile:path atomically:useAuxiliaryFile encoding:enc error:error]);
}

@end
