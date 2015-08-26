//
//  GBACoinScene.m
//  Origami Game
//
//  Created by Facundo Schiavoni on 26/8/15.
//  Copyright (c) 2015 Facundo Schiavoni. All rights reserved.
//

#import "GBACoinScene.h"
#import "GBAMenuScene.h"

@interface GBACoinScene ()

@property(nonatomic, retain) SKLabelNode *comingSoonLabel;

@end

@implementation GBACoinScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]){
        
        self.backgroundColor = [UIColor colorWithRed:0.102f green:0.102f blue:0.102f alpha:1.00f];
        
        
        _comingSoonLabel = [[SKLabelNode alloc] initWithFontNamed:@"Keep Calm"];
        _comingSoonLabel.text = @"Coming soon...";
        _comingSoonLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        _comingSoonLabel.fontSize = 30;
        _comingSoonLabel.fontColor = [UIColor colorWithRed:0.573f green:0.573f blue:0.545f alpha:1.00f];
        [self addChild:_comingSoonLabel];
        
        SKAction *blinkingButtons = [SKAction sequence:@[
                                                         [SKAction fadeAlphaTo:0.2 duration:0.5],
                                                         [SKAction fadeAlphaTo:0.7 duration:0.5],
                                                         [SKAction waitForDuration:0.25]]];
        [_comingSoonLabel runAction:[SKAction repeatActionForever:blinkingButtons]];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKTransition *transicion = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:.5f];
    GBAMenuScene *menuScene = [[GBAMenuScene alloc] initWithSize:self.size];
    [self.scene.view presentScene:menuScene transition:transicion];
}


@end

