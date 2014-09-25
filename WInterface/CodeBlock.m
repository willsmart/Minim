//
//  CodeBlock.m
//  WInterface
//
//  Created by Will Smart on 7/07/14.
//
//




@implementation CodeToken

+(NSRegularExpression*)numberRegex {
    cached_id_return(NSRegularExpression,[NSRegularExpression regularExpressionWithPattern:@"\d+|\d*\.\d+" options:0 error:IgnoreNSError]);
}

-(CodeTokenType)baseType {
    if (!_baseType) {
        if ([_text rangeOfCharacterFromSet:NSCharacterSet.alphanumericCharacterSet].location==NSNotFound) {
            if ([_text rangeOfCharacterFromSet:NSCharacterSet.whitespaceCharacterSet].location==NSNotFound) {
                if ([_text rangeOfCharacterFromSet:NSCharacterSet.newlineCharacterSet].location==NSNotFound) {
                    _baseType=Token_op;
                }
                else _baseType=Token_linebreak;
            }
            else if ([_text rangeOfCharacterFromSet:NSCharacterSet.whitespaceCharacterSet.invertedSet].location==NSNotFound) {
                _baseType=Token_whitespace;
            }
        }
        if (!_baseType) {
            else if (([_text hasPrefix:@"/*"]&&[_text hasPrefix:@"*/"])||[_text hasPrefix:@"//"]) {
                _baseType=Token_whitespace;
            }
            else if ((_text.length>=2)&&[_text hasPrefix:@"\""]&&[_text hasSuffix:@"\""]) {
                _baseType=Token_string;
            }
            else if ([self.class.numberRegex rangeOfFirstMatchInString:_text options:0 range:NSMakeRange(0, _text.length)].location!=NSNotFound) {
                _baseType=Token_number;
            }
            else _baseType=Token_word;
        }
    }
    return(_baseType);
}



static NSMutableDictionary *s_tokens=nil;

+(instancetype)_codeTokenWithText:(NSString*)text {
    if (!s_tokens) s_tokens=[NSMutableDictionary new];
    CodeToken *ret=[s_tokens objectForKey:text];
    if (!ret) {
        [s_tokens setObject:ret=[CodeToken new] forKey:text];
        ret->_text=text;
        [ret baseType];
    }
    return(ret);
}



static WReader *s_reader=nil;

+(NSArray*)codeTokensForText:(NSString*)text {
    if (!s_tokens) s_tokens=[NSMutableDictionary new];
    NSArray *ret=[s_tokens objectForKey:text];
    if (!ret) {
        if (!s_reader) s_reader=[WReader new];
        s_reader.fileString=text;
        if (s_reader.tokenizer.tokens.count==1) {
            ret=(id)[self codeTokenWithText:((WReaderToken*)s_reader.tokenizer.tokens.firstObject).str];
        }
        else {
            NSMutableArray *a=@[].mutableCopy;
            for (WReaderToken *t in s_reader.tokenizer.tokens) {
                [a addObject:[self codeTokenWithText:t.str]];
            }
            ret=a.copy;
            [s_tokens setObject:ret forKey:text];
        }
    }
    return([ret isKindOfClass:NSArray.class]?ret:@[ret]);
}


@end









@implementation CodeBlock

static NSUInteger s_tokenChangeTime=0,s_peerValidationTime=0,s_utilmark=1;


/**
 Body property
 @return The text of this code block
 */
-(NSString*)body {
    if (!_body) {
        if (_tokensInOrder) switch (_tokensInOrder.count) {
            case 0:_body=@"";break;
            case 1:_body=((CodeToken*)_tokensInOrder.firstObject).text;break;
            default:{
                NSMutableString *s=@"".mutableCopy;
                for (CodeToken *t in _tokensInOrder) [s appendString:t.text];
                _body=s.copy;
            }break;
        }
        else switch (_subBlocksInOrder.count) {
            case 0:_body=@"";break;
            case 1:_body=((CodeBlock*)_subBlocksInOrder.firstObject).body;break;
            default:{
                NSMutableString *s=@"".mutableCopy;
                for (CodeBlock *b in _subBlocksInOrder) [s appendString:b.body];
                _body=s.copy;
            }break;
        }
    }
    return(_body);
}
-(void)setBody:(NSString *)body {
    if (body&&![body isEqualToString:_body]) {
        self.tokensInOrder=[CodeToken codeTokensForText:(_body=body)];
    }
}



/**
 A histogram of subBlocksInOrder
 @return The (now assuredly non-nil) dictionary from the weakSelf of each member of subBlocksInOrder to the number of times it occurs in subBlocksInOrder
 */
-(NSDictionary*)subBlocksMembershipCounts {
    if (!_subBlocksMembershipCounts) {
        _subBlocksMembershipCounts=[NSMutableDictionary new];
        s_utilmark++;
        NSUInteger c=0;
        for (CodeBlock *b in _subBlocksInOrder) {
            if (s_utilmark!=b->_utilmark) {
                c++;
                b->_utilmark=s_utilmark;
                b->_utili=1;
            }
            else b->_utili++;
        }
        s_utilmark++;
        for (CodeBlock *b in _subBlocksInOrder) if (s_utilmark!=b->_utilmark) {
            b->_utilmark=s_utilmark;
            _subBlocksMembershipCounts[b.weakSelf]=@(b->_utili);
            if (!--c) break;
        }
    }
    return(_subBlocksMembershipCounts);
}
        
        


/**
 Marks all blocks with this block in their subBlocksInOrder as having changed
 @param dcount The change in token count for this block, or NSNotFound to set token count to NSNotFound
 */
-(void)invalidateSuperBlocks:(Int)dcount {
    for (CodeBlock *sup in _superBlocks) if (sup->_tokenChangedAt!=s_tokenChangeTime) {
        NSNumber *memberc;
        Int supdcount=(
            (dcount==NSNotFound)||!(dcount&&((memberc=sup.subBlocksMembershipCounts[self.weakSelf])))?
            dcount:
            (memberc.integerValue*dcount)
        );
        sup->_tokenCount=(supdcount==NSNotFound?NSNotFound:(sup->_tokenCount+supdcount));
        sup->_tokensInOrder=nil;
        sup->_body=nil;
        sup->_tokenChangedAt=s_tokenChangeTime;
        [sup invalidateSuperBlocks:supdcount];
    }
}



-(NSArray*)tokensInOrder {
    if (!_tokensInOrder) switch (_subBlocksInOrder.count) {
        case 0:ret=@[];break;
        case 1:_tokensInOrder=((CodeBlock*)_subBlocksInOrder.firstObject).tokensInOrder;break
        default:{
            NSMutableArray *mret=@[].mutableCopy;
            for (CodeBlock *b in _subBlocksInOrder) [b addTokensInOrder:ret];
            _tokensInOrder=mret.copy;
        }
    }
    _tokenCount=_tokensInOrder.count;
    return(_tokensInOrder);
}
-(void)addTokensInOrder:(NSMutableArray*)addTo {
    Int countWas=addTo.count;
    if (_tokensInOrder) [addTo addObjectsFromArray:_tokensInOrder];
    else for (CodeBlock *b in _subBlocksInOrder) [b addTokensInOrder:ret];
    _tokenCount=addTo.count-countWas;
}
-(void)setTokensInOrder:(NSArray*)tokensInOrder {
    s_tokenChangeTime++;
    if (tokensInOrder&&((!_tokensInOrder)||![_tokensInOrder isEqualToArray:tokensInOrder])) {
        Int dcount;
        if (_subBlocksInOrder.count) {
            NSArray *tokensWere=self.tokensInOrder;
            NSIndexSet *inss=nil,*dels=nil;
            if ([Collections getInsertsAndDeletesAsIndexSetWhenChanging:tokensWere to:tokensInOrder inss:&inss dels:&dels]) {
                [self removeTokensAtIndexes:dels offset:0 insertTokens:[tokensInOrder objectsAtIndexes:inss] atIndexes:inss withOffset:0];
            }
            dcount=_tokenCount-tokensWere.count;
        }
        else {
            dcount=tokensInOrder.count-_tokensInOrder.count;
            _tokensInOrder=tokensInOrder;
            _tokenCount=tokensInOrder.count;
            _tokenChangedAt=s_tokenChangeTime;
        }
        [self invalidateSuperBlocks:dcount];
    }
}


-(void)removeTokensAtIndexes:(NSIndexSet*)dels offset:(Int*)pdelsOffset insertTokens:(NSArray*)insTokens atIndexes:(NSIndexSet*)inss withOffset:(NSUInteger*)pinssOffset {
    
    BOOL deletedFirst=(_tokenCount&&[dels containsIndex:delsOffset]);
    BOOL deletedEnd=[dels containsIndex:delsOffset+_tokenCount];

    if (_tokensInOrder||(s_tokenChangeTime==_tokenChangedAt)) {
        Int inssOffset=*pinssOffset,newInssOffset=inssOffset+_tokenCount,delsOffset=*pdelsOffset,newDelsOffset=delsOffset+_tokenCount;

        Int countWas=_tokenCount;
        if ([dels containsIndexesInRange:NSMakeRange(delsOffset,_tokenCount)]) {
            NSMutableIndexSet *mdels=dels.mutableCopy;
            if (delsOffset) [mdels shiftIndexesStartingAtIndex:delsOffset by:-delsOffset];
            [mdels removeIndexesInRange:NSMakeRange(_tokenCount, NSNotFound-_tokenCount)];
            if (s_tokenChangeTime!=_tokenChangedAt) {
                _tokenCount-=mdels.count;
                [_tokensInOrder removeObjectsAtIndexes:mdels];
                _tokenChangedAt=s_tokenChangeTime;
            }
            newInssOffset-=mdels.count;
        }
        if ([inss containsIndexesInRange:NSMakeRange(inssOffset+1-deletedFirst,_tokenCount+(1-deletedEnd)-(1-deletedFirst))]) {
            NSMutableIndexSet *minss=inss.mutableCopy;
            Int prec=[mins countOfIndexesInRange:NSMakeRange(0, inssOffset)];
            if (inssOffset) [minss shiftIndexesStartingAtIndex:inssOffset by:-inssOffset];
            if (!deletedFirst) [minss removeIndex:0];
            Int ei=_tokenCount+(1-deletedEnd),insc;
            for (insc=[inss countOfIndexesInRange:NSMakeRange(0, ei)];insc;ei+=insc,insc=[inss countOfIndexesInRange:NSMakeRange(ei-insc, insc)]);
            [minss removeIndexesInRange:NSMakeRange(ei, NSNotFound-ei)];
            if (s_tokenChangeTime!=_tokenChangedAt) {
                _tokenCount+=insc;
                [_tokensInOrder insertObjects:[insTokens subarrayWithRange:NSMakeRange(prec,insc)] atIndexes:minss];
                _tokenChangedAt=s_tokenChangeTime;
            }
            newInssOffset+=insc;
        }
        *pdelsOffset=newDelsOffset;
        *pinssOffset=newInssOffset;
    }
    else {
        Int delc=[dels countOfIndexesInRange:NSMakeRange(delsOffset,_tokenCount)];
        if (delc||[inss containsIndexesInRange:NSMakeRange(inssOffset+1-deletedFirst,_tokenCount-delc+(1-deletedEnd)-(1-deletedFirst))]) {
            _tokenChangedAt=s_tokenChangeTime;
            Int count=0;
            for (CodeBlock *b in _subBlocksInOrder) {
                [b removeTokensAtIndexes:dels offset:pdelsOffset insertTokens:insTokens atIndexes:inss withOffset:pinssOffset];
                count+=b->_tokenCount;
            }
            _tokenCount=count;
        }
    }
}



-(void)validatePeers {if (_peersValidatedAt<s_peerValidationTime) [self.class validatePeers:_peerBlocks];}

+(void)validatePeers:(NSDictionary*)peerTypes {
    for (WeakSelf *w in _peerBlocks) ((CodeBlock*)w.strongSelf)->_peersValidatedAt=s_peerValidationTime;

    for (WeakSelf *w1 in _peerBlocks) {
        CodeBlock *peer1=w1.strongSelf;
        id __unsafe_unretained p;
        for (WeakSelf *w2 in _peerBlocks) {
            if (w1==w2) break;
            CodeBlock *peer2=w2.strongSelf;
            if (peer1->_tokenChangedAt!=peer2->_tokenChangedAt) {
                if (peer1->_tokenChangedAt<peer2->_tokenChangedAt) {p=peer1;peer1=peer2;peer2=p;p=w1;w1=w2;w2=p;}

                NSObject*(^transfer)(NSObject*tokensOrString)=[self.class getTransferFromType:peerType[w1] toType:peerType[w2]];
                NSObject *bval;
                if (transfer) {
                    bval=transfer(p1.tokensInOrder);
                    if (!bval) bval=transfer(p1.body);
                }
                else bval=self.tokensInOrder;

                if ([bval isKindOfClass:NSString.class]) peer2.body=(NSString*)bval;
                else if ([bval isKindOfClass:NSArray.class]) peer2.tokensInOrder=(NSArray*)bval;
                else peer2.body=bval.description;
            }
        }
    }
}




-(instancetype)init {
    if (!(self=[super init])) return(nil);
    _subBlocksInOrder=[NSMutableArray new];
    _subBlocksByKey=[NSMutableDictionary new];
    _superBlocks=[NSMutableSet new];
    _peerBlocks=[NSMutableDictionary new];
    return(self);
}

-(NSString*)body {

@property (strong,nonatomic) NSString *path,*body;

@end






-(void)setPath:(NSString *)path {
    path=pathForPath(path);
    WReader *r=[WReader new];
    r.fileName=path;
    if (!r.tokenizer.tokens) _path=nil;
    else {
        _path=path;
        self.tokens=r.tokenizer.tokens;
    }
}

-(void)setBody:(NSString *)body {
    WReader *r=[WReader new];
    r.fileString=body;
    if (!r.tokenizer.tokens) _body=nil;
    else {
        if (_body&&![_body isEqualToString:body]) _path=nil;
        _body=body;
        self.tokens=r.tokenizer.tokens;
    }
}

-(NSArray*)tokens {
    if (!_tokens) {
        if (_token) _tokens=@[_token];
        else if (!_subBlocks.count) _tokens=@[];
        else if (_subBlocks.count==1) _tokens=((CodeBlock*)_subBlocks.anyObject).tokens;
        else {
            NSMutableArray *ret=@[].mutableCopy;
            for (CodeBlock *sub in _subBlocks) [ret addObjectsFromArray:((CodeBlock*)_subBlocks.anyObject).tokens];
            _tokens=ret;
        }
    }
    return(_tokens);
}


-(void)prepSetTokens:(NSArray *)tokens {
    NSIndexSet *inss=nil,*dels=nil;
    NSArray *tokensWere=self.tokens;
    if ([Collections getInsertsAndDeletesAsIndexSetWhenChanging:tokensWere to:tokens inss:&ins dels:&dels]) {
        if (_token) {
            Int index=0;
            NSArray *indSets=@[].mutableCopy;
            for (CodeBlock *sub in _subBlocks) {
                [indSets addObject:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, index+sub.tokens.count)]
            if (tokens.)_tokens=@[_token];
        else if (!_subBlocks.count) _tokens=@[];
        else if (_subBlocks.count==1) _tokens=((CodeBlock*)_subBlocks.anyObject).tokens;
        else {
            NSMutableArray *ret=@[].mutableCopy;
            for (CodeBlock *sub in _subBlocks) [ret addObjectsFromArray:((CodeBlock*)_subBlocks.anyObject).tokens];
            _tokens=ret;
        }
-(void)setTokens:(NSArray *)tokens {
    NSIndexSet *inss=nil,*dels=nil;
    NSArray *tokensWere=self.tokens;
    if ([Collections getInsertsAndDeletesAsIndexSetWhenChanging:tokensWere to:tokens inss:&ins dels:&dels]) {
        if (_token) {
            Int index=0;
            NSArray *indSets=@[].mutableCopy;
            for (CodeBlock *sub in _subBlocks) {
                [indSets addObject:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, index+sub.tokens.count)]
            if (tokens.)_tokens=@[_token];
        else if (!_subBlocks.count) _tokens=@[];
        else if (_subBlocks.count==1) _tokens=((CodeBlock*)_subBlocks.anyObject).tokens;
        else {
            NSMutableArray *ret=@[].mutableCopy;
            for (CodeBlock *sub in _subBlocks) [ret addObjectsFromArray:((CodeBlock*)_subBlocks.anyObject).tokens];
            _tokens=ret;
        }
        
    [self removeTokensAtIndexes:dels insert:(inss.count?[tokens objectsAtIndexes:inss]:nil) atIndexes:inss];

-(void)setToken:(WReaderToken *)token {
    





        if (dels.count) [_wreader.tokenizer.tokens removeObjectsAtIndexes:dels];
        if (inss.count) [_wreader.tokenizer.tokens insertObjects:insTokens atIndexes:inss];
    }
    [super ]


@end
