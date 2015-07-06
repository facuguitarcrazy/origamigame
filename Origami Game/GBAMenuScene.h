//
//  GBAMenuScene.h
//  Origami
//
//  Created by Facundo on 2/2/15.
//  Copyright (c) 2015 Greenbear Apps. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GBAViewController.h"
#import <GameKit/GameKit.h>
#import "GameState.h"




@interface GBAMenuScene : SKScene <GKGameCenterControllerDelegate, AVAudioPlayerDelegate>

@property (nonatomic) AVAudioPlayer *sound;





@end
