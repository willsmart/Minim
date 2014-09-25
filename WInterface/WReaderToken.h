@interface WReaderToken : NSObject
@property (assign,nonatomic) WReaderTokenizer *tokenizer;
@property (retain,nonatomic) NSString *_str,*str,*_notes,*notes;
@property Int bracketCount,linei;
@property char type;
- (id)initWithTokenizer:(WReaderTokenizer*)atokenizer string:(NSString*)astr bracketCount:(Int)bc linei:(Int)linei type:(char)type;
- (id)initWithTokenizer:(WReaderTokenizer*)atokenizer string:(NSString*)astr bracketCount:(Int)bc linei:(Int)linei type:(char)type note:(NSString*)anote;
-(void)addNote:(NSString*)format,...;
@end
