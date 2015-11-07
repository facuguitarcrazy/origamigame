//
//  GameScene.h
//  Origami Game
//

//  Copyright (c) 2015 Facundo Schiavoni. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameState.h"
#import <GameKit/GameKit.h>
#import <Social/Social.h>
#import <AVFoundation/AVFoundation.h>



@interface GBAGameScene : SKScene <SKPhysicsContactDelegate, GKGameCenterControllerDelegate, AVAudioPlayerDelegate>
@property (nonatomic) AVAudioPlayer *bgSound;

@end

