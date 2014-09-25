//
//  CodeBlock.h
//  WInterface
//
//  Created by Will Smart on 7/07/14.
//
//

@class SourceFile;
@class WReaderToken;

enum TokenType {
    Token_number='n',
    Token_word='w',
    Token_whitespace='z',
    Token_string='s',
    Token_linebreak='r',
    Token_op='o'
};
typedef NSUInteger CodeTokenType;

@interface CodeToken : NSObject {
    CodeTokenType _baseType;
}
@property (readonly,nonatomic) NSString *text;
@property (readonly,nonatomic) CodeTokenType baseType;
+(NSArray*)codeTokensForText:(NSString*)text;
@end

@interface CodeBlock : NSObject {
    NSUInteger _tokenChangedAt,_peersValidatedAt;
    NSMutableArray *_tokensInOrder;
    NSMutableDictionary *_subBlocksMembershipCounts;
    NSString *_body;
    Int _utili,_utilmark;
}

@property (readonly,nonatomic) NSUInteger tokenCount;

@property (strong,nonatomic) NSMutableArray *subBlocksInOrder;
@property (strong,nonatomic) NSMutableArray *subBlocksByKey;
@property (strong,nonatomic) NSDictionary *subBlocksMembershipCounts;
@property (readonly,strong,nonatomic) NSMutableDictionary *peerBlocks;
@property (strong,nonatomic) NSMutableSet *superBlocks;

@property (strong,nonatomic) NSArray *tokensInOrder;
@property (strong,nonatomic) NSString *path,*body;

-(void)blockDied:(CodeBlock*)block;

@end
