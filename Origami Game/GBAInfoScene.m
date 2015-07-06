//
//  GBAInfoScene.m
//  Origami Game
//
//  Created by Facundo on 16/3/15.
//  Copyright (c) 2015 Facundo Schiavoni. All rights reserved.
//

#import "GBAInfoScene.h"
#import "GBAMenuScene.h"

@implementation GBAInfoScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        SKSpriteNode *info = [[SKSpriteNode alloc] initWithImageNamed:@"info.png"];
        info.size = CGSizeMake(self.scene.size.width, self.scene.size.height);
        info.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:info];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKTransition *transicion = [SKTransition doorsOpenHorizontalWithDuration:1];
    GBAMenuScene *menuScene = [[GBAMenuScene alloc] initWithSize:self.size];
    [self.scene.view presentScene:menuScene transition:transicion];
}

@end
