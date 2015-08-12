//
//  GameScene.m
//  Origami Game
//
//  Created by Facundo on 13/2/15.
//  Copyright (c) 2015 Facundo Schiavoni. All rights reserved.
//

#import "GBAGameScene.h"
#import "GBAInfoScene.h"

#import "GBAMenuScene.h"
#import <AVFoundation/AVFoundation.h>
//int score = 0;
//int highscore;
// int randomness;
BOOL direction;
BOOL gameover;
BOOL blackOrigami;
BOOL share = NO;
BOOL facebookIsSharing;
BOOL twitterIsSharing;
BOOL stopDifficult;

float difficult = 1.0f;
float timesDifficult;
CGFloat bounceFactor = 0.2f;
CGFloat halfScreen;
NSTimer *difficultTimer;
static NSString *origamiCategoryName = @"origami";
static NSString *binCategoryName = @"bin";
static NSString *origamiFallKey = @"origamiFall";
static NSString *rotateScoreKey = @"rotateScore";
static NSString *fallScoreKey = @"fallScoreKey";
static NSString *highScoreKey = @"HighScoreSaved";

NSURL *gameUrl;


static const uint32_t origamiCategory = 0x1 << 0;   //00000000000000000000000000000001
static const uint32_t bottomCategory = 0x1 << 1;    //00000000000000000000000000000010
static const uint32_t binCategory = 0x1 << 2;       //00000000000000000000000000001000

static inline CGFloat randomInRange(CGFloat low, CGFloat high) {
    CGFloat value = arc4random_uniform(UINT32_MAX) / (CGFloat)UINT32_MAX;
    return value * (high - low) + low;
}

SKNode *menuItems;

@interface GBAGameScene () <AVAudioPlayerDelegate>
@property (nonatomic) NSTimeInterval lastAddPlayerTime;
@property (nonatomic) BOOL fingerIsOnBin;
@property(nonatomic, retain) SKLabelNode *scoreLabel;
@property(nonatomic, retain) SKLabelNode *scoreLabel_2;
@property(nonatomic, retain) SKLabelNode *gameOverLabel;
@property(nonatomic, retain) SKLabelNode *scoreLabel_3;
@property(nonatomic, retain) SKLabelNode *amountOfCoins;

// @property(nonatomic, strong) SKLabelNode *highScoreLabel;
@property(nonatomic, retain) SKSpriteNode *origami;
@property(nonatomic, retain) SKSpriteNode *bin;
@property(nonatomic, retain) SKSpriteNode *gameOverFrame;
@property(nonatomic, retain) SKSpriteNode *backButton;
@property(nonatomic, retain) SKSpriteNode *playButton;
@property (nonatomic, retain)SKSpriteNode *leaderboardButton;
@property(nonatomic, retain) SKSpriteNode *shareButton;
@property(nonatomic) AVAudioPlayer *gameSound;


@property(nonatomic, retain) SKAction *actionOrigami;
@property(nonatomic, retain) SKAction *loseOrigami;

@property (nonatomic) BOOL gameCenterEnabled;

@property (nonatomic, retain) SKSpriteNode *twitterBackground;
@property (nonatomic, retain) SKSpriteNode *twitter;
@property (nonatomic, retain) SKSpriteNode *facebookBackground;
@property (nonatomic, retain) SKSpriteNode *facebook;


-(void)authenticateLocalPlayer;
-(void)reportScore;
-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard;
-(void)shareTwitter;

@end


@implementation GBAGameScene


- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]){
    
        
        self.backgroundColor = [SKColor whiteColor];
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        gameover = NO;
        
        _scoreLabel = [[SKLabelNode alloc] init];
        _scoreLabel.text = @"0";
        _scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + CGRectGetMidY(self.frame)/3);
        _scoreLabel.fontName = @"Boulder";
        _scoreLabel.fontSize = 64;
        _scoreLabel.fontColor = [SKColor blackColor];
        [self addChild:_scoreLabel];
        
        _twitterBackground = [[SKSpriteNode alloc] initWithImageNamed:@"twitter_background.png"];
        _twitterBackground.size = CGSizeMake(self.scene.size.width + 4, self.scene.size.height);
        _twitterBackground.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) + CGRectGetMidY(self.frame));
  //      _twitterBackground.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*2);                                                    /////////////
        _twitterBackground.zPosition = 5;
        [self addChild:_twitterBackground];
        
        _twitter = [[SKSpriteNode alloc] initWithImageNamed:@"twitter.png"];
        _twitter.size = CGSizeMake(_twitter.size.width/3, _twitter.size.height/3);
        _twitter.position = CGPointMake(_twitterBackground.position.x, _twitterBackground.position.y/1.225);
        _twitter.zPosition = 6;
        [self addChild:_twitter];
                                    
        
        _facebookBackground = [[SKSpriteNode alloc] initWithImageNamed:@"facebook_background.png"];
        _facebookBackground.size = self.scene.size;
        _facebookBackground.position = CGPointMake(CGRectGetMidX(self.frame), 0 - CGRectGetMidY(self.frame));
  //     _facebookBackground.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - CGRectGetMidY(self.frame));                          /////////////
        _facebookBackground.zPosition = 5;
        _facebookBackground.name = @"facebookBG";
        [self addChild:_facebookBackground];
        
        _facebook = [[SKSpriteNode alloc] initWithImageNamed:@"facebook.png"];
        _facebook.size = CGSizeMake(_facebook.size.width/3, _facebook.size.height/3);
        _facebook.position = CGPointMake(_facebookBackground.position.x, _facebookBackground.position.y/2);
        _facebook.zPosition = 6;
        [self addChild:_facebook];
        
        
        
        
        _bin = [[SKSpriteNode alloc] initWithImageNamed:@"empty_trash-128 20-32-54-064 20-43-37-238 copia"];
        _bin.name = binCategoryName;
        _bin.size = CGSizeMake(70.4f, 70.4f);
        _bin.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame) + _bin.size.height/2);
        [self addChild:_bin];
        _bin.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(70.4f, 70.4f)];
        _bin.physicsBody.restitution = 0.1f;
        _bin.physicsBody.friction = 0.4f;
        _bin.physicsBody.dynamic = NO;
        
        CGRect bottomRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1);
        SKNode *bottom = [SKNode node];
        bottom.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:bottomRect];
        [self addChild:bottom];
        
        bottom.physicsBody.categoryBitMask = bottomCategory;
        _bin.physicsBody.categoryBitMask = binCategory;
        // FUTURE UPDATES. | bombCategory;
        
        
        
        self.physicsWorld.contactDelegate = self;
        
        
            
            
            _actionOrigami = [SKAction sequence:@[
                                                  [SKAction waitForDuration:0.4],
                                                  [SKAction runBlock:^{
                if (gameover == NO) {
                    if (!stopDifficult) {
                        difficult -= 0.01;
                    }
                    
                }else {
                    
                }
            }]]];
            [self runAction:[SKAction repeatActionForever:_actionOrigami] withKey:origamiFallKey];
        
        
        
        menuItems = [SKNode node];
        [self addChild:menuItems];
        
        
        _gameOverFrame = [[SKSpriteNode alloc] initWithImageNamed:@"gameOverRectangle"];
        _gameOverFrame.alpha = 0.0;
        _gameOverFrame.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + CGRectGetMidY(self.frame)/2);
        _gameOverFrame.size = CGSizeMake(_gameOverFrame.size.width/1.5, _gameOverFrame.size.height/1.5);
        [menuItems addChild:_gameOverFrame];
        
        _backButton = [[SKSpriteNode alloc] initWithImageNamed:@"back.png"];
        _backButton.position = CGPointMake(CGRectGetMinX(self.frame) - _backButton.frame.size.width, CGRectGetMinY(self.frame) - _backButton.frame.size.height);
        _backButton.size = CGSizeMake(_backButton.frame.size.width/3, _backButton.frame.size.height/3);
        _backButton.alpha = 0;
        [self addChild:_backButton];
        
        _playButton = [[SKSpriteNode alloc] initWithImageNamed:@"play-48 copia"];
        _playButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame) - _playButton.size.height);
        _playButton.alpha = 0;
        [menuItems addChild:_playButton];
        
        _leaderboardButton = [[SKSpriteNode alloc] initWithImageNamed:@"leaderboard-104.png"];
        _leaderboardButton.position = CGPointMake(CGRectGetMinX(self.frame) - _leaderboardButton.size.width, _playButton.position.y - _leaderboardButton.frame.size.height/2.5);
        _leaderboardButton.size = _playButton.size;
        _leaderboardButton.alpha = 0;
        [self addChild:_leaderboardButton];
        
        _shareButton = [[SKSpriteNode alloc] initWithImageNamed:@"share.png"];
        _shareButton.position = CGPointMake(CGRectGetMaxX(self.frame) + _shareButton.size.width, _playButton.position.y - _shareButton.frame.size.height/2.85);
        _shareButton.size = _playButton.size;
        _shareButton.alpha = 0;
        _shareButton.name = @"shareButton";
        [self addChild:_shareButton];
        
        
        _scoreLabel_2 = [[SKLabelNode alloc] init];
        _scoreLabel_2.text = @"0";
        _scoreLabel_2.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _scoreLabel_2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + CGRectGetMidY(self.frame)/3);
        _scoreLabel_2.fontName = @"Boulder";
        _scoreLabel_2.fontSize = 32;
        _scoreLabel_2.fontColor = [SKColor blackColor];
        _scoreLabel_2.alpha = 0.0;
        [self addChild:_scoreLabel_2];
        
        _gameOverLabel = [[SKLabelNode alloc] init];
        _gameOverLabel.text = @"GAME OVER";
        _gameOverLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _gameOverLabel.position = CGPointMake(_scoreLabel_2.position.x, _scoreLabel_2.position.y + CGRectGetMidY(self.frame)/3.5);
        _gameOverLabel.fontColor = [SKColor blackColor];
        _gameOverLabel.fontName = @"Boulder";
        _gameOverLabel.fontSize = 48;
        _gameOverLabel.alpha = 0.0;
        [self addChild:_gameOverLabel];
        
        _scoreLabel_3 = [[SKLabelNode alloc] init];
        _scoreLabel_3.text = @"SCORE";
        _scoreLabel_3.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _scoreLabel_3.position = CGPointMake(_gameOverLabel.position.x, _scoreLabel_2.position.y + CGRectGetMidY(self.frame)/6);
        _scoreLabel_3.fontName = @"Boulder";
        _scoreLabel_3.fontSize = 32;
        _scoreLabel_3.fontColor = [SKColor blackColor];
        _scoreLabel_3.alpha = 0.0;
        [self addChild:_scoreLabel_3];
        
        
        
        
     //   difficultTimer = [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(increaseDifficult) userInfo:nil repeats:YES];
        
        if (gameover) {
            [self hideButtons];
        }
        
        
    }
    return self;
}
/*
-(void)increaseDifficult {
    difficult -= 0.01f;
}
 */
-(void)resetScene {
    // [self runAction:[SKAction repeatActionForever:_actionOrigami]];
    
    gameover = NO;
    NSLog(@"GAME OVER");
    SKScene *scene = [[GBAGameScene alloc] initWithSize:self.size];
    SKTransition *transition = [SKTransition fadeWithDuration:0.5];
    [self.view presentScene:scene transition:transition];
    
}

-(void)hideButtons {
    [_shareButton runAction:[SKAction moveToX:CGRectGetMaxX(self.frame) + _shareButton.size.width/2 duration:0.1]];
    [_leaderboardButton runAction:[SKAction moveToX:CGRectGetMinX(self.frame) - _leaderboardButton.size.width/2 duration:0.1]];
    [_playButton runAction:[SKAction moveToY:CGRectGetMinY(self.frame) - _playButton.size.height/2 duration:0.2]];
    [_backButton runAction:[SKAction moveToY:CGRectGetMinY(self.frame) - _backButton.size.height/2 duration:0.2]];

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:touchLocation];
    
    SKPhysicsBody *body = [self.physicsWorld bodyAtPoint:touchLocation];
    if (body && [body.node.name isEqualToString: binCategoryName]) {
        // NSLog(@"BIN TOUCHED");
        self.fingerIsOnBin = YES;
    }
    
    if (CGRectContainsPoint(_backButton.frame, touchLocation)) {
        SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionDown duration:0.5];
        GBAMenuScene *menuScene = [[GBAMenuScene alloc] initWithSize:self.size];
        [self.scene.view presentScene:menuScene transition:transition];
    }
    
    if (CGRectContainsPoint(_playButton.frame, touchLocation)) {

            if (gameover) {
                [self resetScene];
                
                
            }
            [_playButton removeFromParent];
            
            [GameState sharedInstance].score = 0;
            _scoreLabel.text = [NSString stringWithFormat:@"%d", [GameState sharedInstance].score];
            _scoreLabel_2.text = [NSString stringWithFormat:@"%d", [GameState sharedInstance].score];
        
            
            
            
            [self removeActionForKey:origamiFallKey];
        
       
        
    }
    if (CGRectContainsPoint(_leaderboardButton.frame, touchLocation)) {

            [self reportScore];
            [self showLeaderboardAndAchievements:YES];

    
            }
    if ([node.name isEqualToString:@"shareButton"]) {
        
        
        
        
        [node runAction:[SKAction runBlock:^{
            // TWITTER ACTIONS
            
            halfScreen = self.scene.size.height;
            
            SKAction *twitter_1 = [SKAction moveByX:0 y:-halfScreen/2 duration:0.6f];
            twitter_1.timingMode = SKActionTimingEaseIn;
            SKAction *twitter_2 = [SKAction moveBy:CGVectorMake(0, halfScreen*bounceFactor/2) duration:0.2f];
            twitter_2.timingMode = SKActionTimingEaseOut;
            SKAction *twitter_3 = [SKAction moveBy:CGVectorMake(0, -halfScreen*bounceFactor/2) duration:0.2f];
            twitter_3.timingMode = SKActionTimingEaseIn;
            
            
            SKAction *moveTwitterBackground = [SKAction sequence:@[
                                                                   twitter_1,
                                                                   twitter_2,
                                                                   twitter_3
                                                                   ]];
            //FACEBOOK ACTIONS
            
            SKAction *facebook_1 = [SKAction moveByX:0 y:halfScreen/2 duration:0.6f];
            facebook_1.timingMode = SKActionTimingEaseIn;
            SKAction *facebook_2 = [SKAction moveBy:CGVectorMake(0, -halfScreen*bounceFactor/2) duration:0.2f];
            facebook_2.timingMode = SKActionTimingEaseOut;
            SKAction *facebook_3 = [SKAction moveBy:CGVectorMake(0, halfScreen*bounceFactor/2) duration:0.2f];
            facebook_3.timingMode = SKActionTimingEaseIn;
            
            
            SKAction *moveFacebookBackground = [SKAction sequence:@[
                                                                    facebook_1,
                                                                    facebook_2,
                                                                    facebook_3
                                                                    ]];
            
            
            [_twitterBackground runAction:moveTwitterBackground];
            [_twitter runAction:moveTwitterBackground];
            [_facebookBackground runAction:moveFacebookBackground];
            [_facebook runAction:moveFacebookBackground];
            
            [self hideButtons];
            
            
                    }] completion:^{
            share = YES;
        }];
        

    }
    if (CGRectContainsPoint(CGRectMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame), self.scene.size.width, self.scene.size.height), touchLocation)) {
        
        twitterIsSharing = YES;
        facebookIsSharing = NO;

        if (share) {
            if (twitterIsSharing) {
                
                NSLog(@"TWITTER TOUCHED");
                
                
                
                
                [_twitterBackground runAction:[SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)) duration:0.2f] completion:^{
                    [_twitterBackground runAction:[SKAction performSelector:@selector(shareTwitter) onTarget:self]];
                }];
                
                [_twitter runAction:[SKAction moveToY:CGRectGetMidY(self.frame) + CGRectGetMidY(self.frame)/6 duration:0.2f]];
                
                [_facebookBackground runAction:[SKAction moveToY:CGRectGetMinY(self.frame) - _facebookBackground.size.height/2 duration:0.2f]];
                [_facebook runAction:[SKAction moveToY:CGRectGetMinY(self.frame) - _facebook.size.height/2 duration:0.2f]];
                
            }
        }
        
    }
    
    if (CGRectContainsPoint(CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), self.scene.size.width, self.scene.size.height/2), touchLocation)) {
        
        facebookIsSharing = YES;
        twitterIsSharing = NO;
        
        if (share) {
            if (facebookIsSharing) {
                NSLog(@"FACEBOOK TOUCHED");
                
                [_facebookBackground runAction:[SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)) duration:0.2f] completion:^{
                    [_facebookBackground runAction:[SKAction performSelector:@selector(shareFacebook) onTarget:self]];
                }];
                [_facebook runAction:[SKAction moveToY:CGRectGetMidY(self.frame) + CGRectGetMidY(self.frame)/6 duration:0.2f]];
                
                [_twitterBackground runAction:[SKAction moveToY:CGRectGetMaxY(self.frame) +_twitterBackground.size.height/2 duration:0.2f]];
                [_twitter runAction:[SKAction moveToY:CGRectGetMaxY(self.frame) + _twitter.size.height/2 duration:0.2f]];
            }
        }
    }
}



-(void)shareFacebook {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *facebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebookSheet addURL:[NSURL URLWithString:@"https://appsto.re/es/xUhL5.i"]];
        [self.view.window.rootViewController presentViewController:facebookSheet animated:YES completion:nil];
        
        [facebookSheet setCompletionHandler:^(SLComposeViewControllerResult result){
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    [self resetScene];
                    share = NO;
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Succesful");
                    [self resetScene];
                    share = NO;
                    break;
                default:
                    break;

            }
        }];
    } else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Accounts" message:@"Please login to a Facebook account to share" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        
    
        
    }
    
    
    
}

-(void)shareTwitter {
    
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [tweetSheet setInitialText:[NSString stringWithFormat:@"I've just caught %i origamis in #OrigamiGame @theorigamigame! https://appsto.re/es/xUhL5.i", [GameState sharedInstance].score]];
      //  [tweetSheet addURL:[NSURL URLWithString:@"https://appsto.re/es/xUhL5.i"]];
      //  [tweetSheet addImage:[self screenshot]];
        
        UIViewController *controller = self.view.window.rootViewController;
        [controller presentViewController:tweetSheet animated:YES completion:nil];
        
        [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result){
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    [self resetScene];
                    share = NO;
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Succesful");
                    [self resetScene];
                    share = NO;
                    break;
                default:
                    break;
            }
        }];
        
    }
}
/*
- (UIImage *)screenshot {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 1);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  viewImage;
}
 */

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.fingerIsOnBin) {
        UITouch *touch = [touches anyObject];
        CGPoint touchLoc = [touch locationInNode:self];
        CGPoint prevTouchLoc = [touch previousLocationInNode:self];
        
        SKSpriteNode *bin = (SKSpriteNode *) [self childNodeWithName: binCategoryName];
        
        int binX = bin.position.x + (touchLoc.x - prevTouchLoc.x);
        binX = MIN(binX, self.size.width - bin.position.y/1.2);
        binX = MAX(binX, bin.size.width/2.35);
        
        bin.position = CGPointMake(binX, bin.position.y);
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.fingerIsOnBin = NO;
}

-(void) addOrigami {
    
    
    
        _origami = [[SKSpriteNode alloc] initWithImageNamed:@"origami-50 20-43-37-341 copia.png"];
        _origami.size = CGSizeMake(_origami.size.width/1.3, _origami.size.height/1.3);
        _origami.name = origamiCategoryName;
        _origami.position = CGPointMake(randomInRange(_origami.size.width, self.size.width - (_origami.size.width)), self.size.height + (_origami.size.height));
        // _origami.position = CGPointMake(randomInRange(_origami.position.x - (_origami.position.x/2), _origami.position.x + (_origami.position.x/2)), self.size.height + (_origami.size.height/2));
        _origami.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_origami.size];
        _origami.physicsBody.dynamic = YES;
        _origami.physicsBody.restitution = 0;
        _origami.physicsBody.linearDamping = 0.0;
        _origami.physicsBody.friction = 1.0;
        _origami.physicsBody.categoryBitMask = origamiCategory;
        _origami.physicsBody.contactTestBitMask = binCategory | bottomCategory;
    
    
    
       // Black origami
     if(arc4random_uniform(6) == 0) {
     _origami.texture = [SKTexture textureWithImageNamed:@"origami-48.png"];
      _origami.physicsBody.collisionBitMask = origamiCategory;
     _origami.userData = [[NSMutableDictionary alloc] init];
     [_origami.userData setValue:@(YES) forKey:@"Black"];
    
     }
    if (arc4random_uniform(10) == 0) {
        _origami.texture = [SKTexture textureWithImageNamed:@"origami-credit.png"];
        _origami.physicsBody.collisionBitMask = origamiCategory;
        _origami.userData = [[NSMutableDictionary alloc] init];
        [_origami.userData setValue:@(YES) forKey:@"Coin"];
    }
    
    
    
    [self addChild:_origami];
    
    SKAction *origamiFall = [SKAction sequence:@[
                                                 [SKAction waitForDuration:0.4],
                                                 [SKAction moveToY:-_origami.size.height duration:1]]];
    [_origami runAction:[SKAction repeatActionForever:origamiFall] withKey:@"origamiFallKeyy"];
    
    
    
}


-(void) gameOver {
    
    share = NO;
   
    gameover = YES;
    
    [_origami removeFromParent];
    
    [[GameState sharedInstance] saveState];
    
    gameUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Hit_Hurt34" ofType:@"wav"]];
    _gameSound = [[AVAudioPlayer alloc] initWithContentsOfURL:gameUrl error:nil];
    _gameSound.delegate = self;
    
    [_gameSound play];
    
    
    //////////////////////////////////////////////////////////////// CAMBIOS DE POSICIONES  ////////////////////////////////////////////
    //
    // _playButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)/2);
    //
    //  _leaderboardButton.position = CGPointMake(_playButton.position.x - _playButton.frame.size.width*2,
    //  _playButton.position.y - _leaderboardButton.frame.size.height/2.5);
    // _shareButton.position = CGPointMake(_playButton.position.x + _playButton.frame.size.width*2, _playButton.position.y -
    // _shareButton.frame.size.height/2.85);
    //
    //
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    SKAction *showBackButton = [SKAction fadeAlphaTo:1 duration:1];
    SKAction *moveBackButton = [SKAction moveTo:CGPointMake(CGRectGetMinX(self.frame) + _backButton.size.width/2, CGRectGetMinY(self.frame) + _backButton.size.height/2) duration:0.3];
    
    SKAction *showPlayButton = [SKAction fadeAlphaTo:1.0 duration:1.0];
    SKAction *movePlayButton = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)/1.5) duration:0.5];
    SKAction *showLeaderboardButton = [SKAction fadeAlphaTo:1.0 duration:1.0];
    SKAction *moveLeaderboardButton = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame) - _playButton.frame.size.width*2.4, CGRectGetMidY(self.frame)/2 - _leaderboardButton.frame.size.height/2.5) duration:0.6];
    SKAction *showShareButton = [SKAction fadeAlphaTo:1.0 duration:1.0];
    SKAction *moveShareButton = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame) + _playButton.frame.size.width*2.3, CGRectGetMidY(self.frame)/2 -_shareButton.frame.size.height/2.85) duration:0.6];
    
    SKAction *showGameOverFrame = [SKAction fadeAlphaTo:1.0 duration:1];
    SKAction *hideScoreLabel = [SKAction fadeAlphaTo:0.0 duration:.5];
    SKAction *showScoreLabel_2 = [SKAction fadeAlphaTo:1.0 duration:1];
    SKAction *moveScoreLabel_2 = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), _scoreLabel_3.position.y - _scoreLabel_3.frame.size.height - _scoreLabel_3.frame.size.height/2) duration:1];
    SKAction *showGameOverLabel = [SKAction fadeAlphaTo:1.0 duration:1];
    SKAction *showScoreLabel_3 = [SKAction fadeAlphaTo:1.0 duration:1];
    
    [_backButton runAction:showBackButton];
    [_backButton runAction:moveBackButton];
    [_playButton runAction:showPlayButton];
    [_playButton runAction:movePlayButton];
    [_leaderboardButton runAction:showLeaderboardButton];
    [_leaderboardButton runAction:moveLeaderboardButton];
    [_shareButton runAction:showShareButton];
    [_shareButton runAction:moveShareButton];
    [_scoreLabel runAction:hideScoreLabel];
    [_scoreLabel_2 runAction:showScoreLabel_2];
    [_scoreLabel_2 runAction:moveScoreLabel_2];
    [_gameOverLabel runAction:showGameOverLabel];
    [_scoreLabel_3 runAction:showScoreLabel_3];
    [_gameOverFrame runAction:showGameOverFrame];
    
    
    
    
    
    
    
}


-(void)didBeginContact:(SKPhysicsContact *)contact {
    
    SKPhysicsBody *firstBody;
    SKPhysicsBody *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
       uint32_t collision = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask);
    
        if (collision == (origamiCategory | binCategory)) {
        if ([[firstBody.node.userData valueForKey:@"Black"] boolValue]){
            [self removeActionForKey:origamiFallKey];
            // NSLog(@"YOU LOSE");
            [self gameOver];
            
            [self runAction:[SKAction sequence:@[
                                                 [SKAction waitForDuration:0.5],
                                                 [SKAction performSelector:@selector(removeOrigamiWhenLose) onTarget:self]]]];
        }
        else if ([[firstBody.node.userData valueForKey:@"Coin"] boolValue]){
            
            [firstBody.node removeFromParent];
            
            _amountOfCoins = [[SKLabelNode alloc] init];
            _amountOfCoins.text = @"+1";
            _amountOfCoins.fontColor = [UIColor colorWithRed:0.92 green:0.74 blue:0.10 alpha:1.0];
            _amountOfCoins.fontSize = 32;
            _amountOfCoins.fontName = @"Game Sans Serif 7";
            _amountOfCoins.position =  CGPointMake(_bin.position.x, _bin.frame.size.height);
            [self addChild:_amountOfCoins];
            
            [_amountOfCoins runAction:[SKAction moveByX:0 y:75 duration:1]];
            [_amountOfCoins runAction:[SKAction fadeAlphaTo:0.0 duration:1]];
            
            [GameState sharedInstance].coins++;
        }
        else {

            [firstBody.node removeFromParent];
            [GameState sharedInstance].score++;
            _scoreLabel.text = [NSString stringWithFormat:@"%d", [GameState sharedInstance].score];
            _scoreLabel_2.text = [NSString stringWithFormat:@"%d", [GameState sharedInstance].score];
            
            gameUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"origami " ofType:@"wav"]];
            _gameSound = [[AVAudioPlayer alloc] initWithContentsOfURL:gameUrl error:nil];
            _gameSound.delegate = self;
            [_gameSound play];

        }
    }
    if (collision == (bottomCategory | origamiCategory)) {
        if ([[firstBody.node.userData valueForKey:@"Black"] boolValue]){
            return;
        }
        else if ([[firstBody.node.userData valueForKey:@"Coin"] boolValue]){
            return;
        }else {

        [self removeActionForKey:origamiFallKey];
        
        
        
        [self gameOver];
        
        }
        if (gameover) {
            [self runAction:[SKAction sequence:@[
                                                 [SKAction waitForDuration:0],
                                                 [SKAction performSelector:@selector(removeOrigamiWhenLose) onTarget:self]]]];
        }
    }
    
    
}

- (void)removeOrigamiWhenLose {
    [self enumerateChildNodesWithName:origamiCategoryName usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeActionForKey:@"origamiFallKeyy"];
        [node runAction:[SKAction moveByX:0 y:500 duration:1]];
        [node runAction:[SKAction rotateByAngle:M_PI + M_PI_2 duration:1]];
    }];
    
}

-(void)didSimulatePhysics {
    [self enumerateChildNodesWithName:origamiCategoryName usingBlock:^(SKNode *node, BOOL *stop) {
        if (!CGRectContainsPoint(CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width , self.frame.size.height + _origami.size.height*2), node.position)) {
            [node removeFromParent];
        }
        if (node.alpha < 0.5) {
            [node removeFromParent];
        }
    }];
    
    
}
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (gameover == NO) {
        if (currentTime - self.lastAddPlayerTime >= difficult) {
            self.lastAddPlayerTime = currentTime;
            [self addOrigami];
        }
    }
    if (gameover == YES) {
        currentTime = 0;
        difficult = 1.0f;
    }
    
    if(difficult < 0.41) {
        stopDifficult = YES;
    }else {
        stopDifficult = NO;
    }
    
    NSLog(@"%.2f", difficult);
}

//GAME CENTER

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


@end
