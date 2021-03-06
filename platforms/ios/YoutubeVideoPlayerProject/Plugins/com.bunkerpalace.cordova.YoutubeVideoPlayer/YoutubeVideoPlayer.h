//
//  YoutubeVideoPlayer.h
//
//  Created by Adrien Girbone on 15/04/2014.
//
//

#import <Cordova/CDV.h>
#import "XCDYouTubeVideoPlayerViewController.h"

@interface YoutubeVideoPlayer : CDVPlugin {
    CDVPluginResult* pluginResult;
    XCDYouTubeVideoPlayerViewController *videoPlayerViewController;
    UIView *view;
}

- (void)openVideo:(CDVInvokedUrlCommand*)command;

@end
