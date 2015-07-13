//
//  GBAMenuScene.m
//  Origami
//
//  Created by Facundo on 2/2/15.
//  Copyright (c) 2015 Greenbear Apps. All rights reserved.
//

#import "GBAMenuScene.h"
#import "GBAGameScene.h"
#import "GBAInfoScene.h"

NSURL *url;

@interface GBAMenuScene () 


@property (nonatomic, retain)SKSpriteNode *origamiTitle;
@property (nonatomic, retain)SKSpriteNode *playButton;
@property (nonatomic, retain)SKSpriteNode *leaderboardButton;
@property (nonatomic, retain)SKSpriteNode *infoButton;
@property (nonatomic, retain)SKSpriteNode *shakeMessage;
@property (nonatomic, retain)SKSpriteNode *coinStore;
@property (nonatomic, retain)SKSpriteNode *store;
@property (nonatomic) BOOL gameCenterEnabled;


-(void)authenticateLocalPlayer;
-(void)reportScore;
-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard;


@end


@implementation GBAMenuScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        [self authenticateLocalPlayer];

        
        self.backgroundColor = [SKColor whiteColor];
        // Añadir particulas.
        NSString *particlePath = [[NSBundle mainBundle] pathForResource:@"MenuParticleRain" ofType:@"sks"];
        SKEmitterNode *particle = [NSKeyedUnarchiver unarchiveObjectWithFile:particlePath];
        
        particle.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) + 20);
        particle.alpha = 0.3;
        [self addChild:particle];
        
        _origamiTitle = [[SKSpriteNode alloc] initWithImageNamed:@"OrigamiTitleMenuFrame.png"];
        _origamiTitle.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+ CGRectGetMidY(self.frame)/2);
        [self addChild:_origamiTitle];
        
       /* _shakeMessage = [[SKSpriteNode alloc] initWithImageNamed:@"shakeMessage.png"];
        _shakeMessage.position = CGPointMake(CGRectGetMidX(self.frame), _playButton.position.y/2 + _shakeMessage.size.height/2);
        [self addChild:_shakeMessage];
        
        */
        _playButton = [[SKSpriteNode alloc] initWithImageNamed:@"play-48 copia.png"];
        _playButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)/2);
        [self addChild:_playButton];
        
        _leaderboardButton = [[SKSpriteNode alloc] initWithImageNamed:@"leaderboard-104.png"];
        _leaderboardButton.position = CGPointMake(_playButton.position.x - _playButton.frame.size.width*2, _playButton.position.y - _leaderboardButton.frame.size.height/2.5);
        _leaderboardButton.size = _playButton.size;
        [self addChild:_leaderboardButton];
        
        _infoButton = [[SKSpriteNode alloc] initWithImageNamed:@"help-100.png"];
        _infoButton.position = CGPointMake(_playButton.position.x + _playButton.frame.size.width*2, _playButton.position.y - _infoButton.frame.size.height/2.58);
        _infoButton.size = _playButton.size;
        [self addChild:_infoButton];
        
        _coinStore = [[SKSpriteNode alloc] initWithImageNamed:@"origami-credit.png"];
        _coinStore.position = CGPointMake(CGRectGetMinX(self.frame) + _coinStore.size.width/3.25, CGRectGetMaxY(self.frame) - _coinStore.size.height/3
                                          );
        _coinStore.size = CGSizeMake(_playButton.size.width/1.5, _playButton.size.height/1.5);
        [self addChild:_coinStore];
        
        _store = [[SKSpriteNode alloc] initWithImageNamed:@"shopping-cart.png"];
        _store.position = CGPointMake(CGRectGetMaxX(self.frame) - _store.size.width/4.25, _coinStore.position.y);
        _store.size = _coinStore.size;
        [self addChild:_store];
        
         url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"deep-blue-sea" ofType:@"wav"]];
        _sound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        _sound.delegate = self;
        _sound.numberOfLoops = -1;
        [_sound play];
        
        SKLabelNode *highScoreLabel = [[SKLabelNode alloc] init];
        highScoreLabel.text = [NSString stringWithFormat:@"High Score: %i", [GameState sharedInstance].highScore];
        highScoreLabel.fontName = @"Boulder";
        highScoreLabel.fontSize = 26;
        highScoreLabel.fontColor = [SKColor blackColor];
        highScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:highScoreLabel];
        
        /*
        SKAction *blinkingShakeMessage = [SKAction sequence:@[
                                                              [SKAction fadeAlphaTo:0.0 duration:0.5],
                                                              [SKAction fadeAlphaTo:1.0 duration:0.5],
                                                              [SKAction waitForDuration:0.25]]];
        [_shakeMessage runAction:[SKAction repeatActionForever:blinkingShakeMessage]];
        */
        
        
         
        }
    return self;
}

-(void)authenticateLocalPlayer{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
           // [self presentViewController:viewController animated:YES completion:nil];
            [self.scene.view.window.rootViewController presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                _gameCenterEnabled = YES;
                
                // Get the default leaderboard identifier.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    else{
                        leaderboardIdentifier = @"origamigameleaderboard123";
                    }
                }];
            }
            
            else{
                _gameCenterEnabled = NO;
            }
        }
    };
}

-(void)reportScore {
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:@"origamigameleaderboard123"];
    score.value = [GameState sharedInstance].highScore;
    
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    
    gcViewController.gameCenterDelegate = self;
    
    if (shouldShowLeaderboard) {
        gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gcViewController.leaderboardIdentifier = @"origamigameleaderboard123";
    }
    else{
        gcViewController.viewState = GKGameCenterViewControllerStateAchievements;
    }
    
    //[self presentViewController:gcViewController animated:YES completion:nil];
    [self.scene.view.window.rootViewController presentViewController:gcViewController animated:YES completion:nil];
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    if (CGRectContainsPoint(_playButton.frame, positionInScene)) {
        SKTransition *transicion = [SKTransition fadeWithDuration:.5f];
        GBAGameScene *gameScene = [[GBAGameScene alloc] initWithSize:self.size];
        [self.scene.view presentScene:gameScene transition:transicion];
        
        [_sound stop];
    }
    if (CGRectContainsPoint(_leaderboardButton.frame, positionInScene)) {
        [self reportScore];
        [self showLeaderboardAndAchievements:YES];
    }
    if (CGRectContainsPoint(_infoButton.frame, positionInScene)) {
        SKTransition *transicion = [SKTransition doorsCloseHorizontalWithDuration:1];
        GBAInfoScene *infoScene = [[GBAInfoScene alloc] initWithSize:self.size];
        [self.scene.view presentScene:infoScene transition:transicion];
    }
    
}




@end
