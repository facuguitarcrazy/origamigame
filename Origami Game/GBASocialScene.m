//
//  GBASocialScene.m
//  Origami Game
//
//  Created by Facundo on 20/6/15.
//  Copyright (c) 2015 Facundo Schiavoni. All rights reserved.
//

#import "GBASocialScene.h"

@interface GBASocialScene ()
@property (nonatomic, retain) SKSpriteNode *twitterBackground;
@property (nonatomic, retain) SKSpriteNode *twitter;
@property (nonatomic, retain) SKSpriteNode *facebookBackground;
@property (nonatomic, retain) SKSpriteNode *facebook;

@end

@implementation GBASocialScene
- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]){
        _twitterBackground = [[SKSpriteNode alloc] initWithImageNamed:@"twitter_background.png"];
        _twitterBackground.size = self.view.bounds.size;
        _twitterBackground.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)/2);
        [self addChild:_twitterBackground];
        
        _facebookBackground = [[SKSpriteNode alloc] initWithImageNamed:@"facebook_background.png"];
        _facebookBackground.size = self.view.bounds.size;
        _facebookBackground.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*2);
        [self addChild:_facebookBackground];
    }
    return self;
}


@end
