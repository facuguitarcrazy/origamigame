//
//  GameState.h
//  Origami(iPhone)
//
//  Created by Facundo on 6/2/15.
//  Copyright (c) 2015 Greenbear Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameState : NSObject

@property (nonatomic, assign) int score;
@property (nonatomic, assign) int highScore;

+(instancetype)sharedInstance;

-(void) saveState;

@end
