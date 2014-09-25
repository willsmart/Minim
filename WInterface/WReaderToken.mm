@implementation WReaderToken : NSObject
@synthesize type,bracketCount,tokenizer,_str,_notes;
- (void)dealloc {
    self.str=nil;
    self.notes=nil;
    }

- (id)initWithTokenizer:(WReaderTokenizer*)atokenizer string:(NSString*)astr bracketCount:(Int)bc linei:(Int)linei type:(char)atype {
    return([self initWithTokenizer:atokenizer string:astr bracketCount:bc linei:linei type:atype note:nil]);
}

- (id)initWithTokenizer:(WReaderTokenizer*)atokenizer string:(NSString*)astr bracketCount:(Int)bc linei:(Int)linei type:(char)atype note:(NSString*)anote {
    if (!(self=[super init])) return(nil);
    tokenizer=atokenizer;
    self.str=astr.copy;
    self.notes=@"";//[NSString stringWithFormat:@"\a\a%c%p%@",atype,self,[astr stringByReplacingOccurrencesOfString:@"\a" withString:@"a"]];
    //if (anote.length) [self addNote:@"%@",anote];
    self.type=atype;
    self.bracketCount=bc;
    self.linei=linei;
    return(self);
}

- (NSString *)str {
    if (self.tokenizer.tokenDelegate) return([self.tokenizer.tokenDelegate processedStringForString:self._str inToken:self]);
    else return(self._str);
}
-(NSString*)notes {return(self._notes);}

- (void)setStr:(NSString *)v {self._str=v;}
- (void)setNotes:(NSString *)v {self._notes=v;}


-(void)addNote:(NSString*)format,... {
    va_list args;va_start(args,format);
    self.notes=[self.notes stringByAppendingFormat:@"\a%@",[[[NSString alloc] initWithFormat:format arguments:args] stringByReplacingOccurrencesOfString:@"\a" withString:@"a"]];
    va_end(args);
}

@end
