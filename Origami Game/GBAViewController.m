//
//  GameViewController.m
//  Origami Game
//
//  Created by Facundo on 13/2/15.
//  Copyright (c) 2015 Facundo Schiavoni. All rights reserved.
//

@import GoogleMobileAds;

#import "GBAViewController.h"
#import "GBAGameScene.h"
#import "GBAMenuScene.h"



@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end


@interface GBAViewController () {
    
        BOOL _bannerIsVisible;
        ADBannerView *_adBanner;
    
}



@end

@implementation GBAViewController 

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"Google Mobile Ad SDK version: %@", [GADRequest sdkVersion]);
    
    GBAViewController *viewController = [[GBAViewController alloc] init];
    
    SKView *skView = (SKView *) self.originalContentView;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    
  
    SKScene *scene = [GBAMenuScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    
    [skView presentScene:scene];
    

    
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, -50, self.view.frame.size.width, 50)];
    _adBanner.delegate = self;
    
    
    
}



-(void)viewWillLayoutSubviews {
    
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}





- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    if (!_bannerIsVisible) {
        // If banner isn't part of the view hierarchy, add it
        if (_adBanner.superview == nil) {
            [self.view addSubview:_adBanner];
        }
        
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        
        // Assumes the baner view is just off the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        
        [UIView commitAnimations];
        
        _bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"Failed to retrieve ad");
    
    if (_bannerIsVisible) {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        
        // Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        
        [UIView commitAnimations];
        
        _bannerIsVisible = NO;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
