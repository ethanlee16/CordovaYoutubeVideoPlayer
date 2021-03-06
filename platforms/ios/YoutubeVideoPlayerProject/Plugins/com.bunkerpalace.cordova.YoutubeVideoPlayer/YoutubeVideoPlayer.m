//
//  YoutubeVideoPlayer.m
//
//  Created by Adrien Girbone on 15/04/2014.
//
//

#import "YoutubeVideoPlayer.h"
#import "XCDYouTubeKit.h"

@implementation YoutubeVideoPlayer

- (void)getVideo:(CDVInvokedUrlCommand*) command
{
    NSString* videoIdentifier = [command.arguments objectAtIndex:0];
    [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:videoIdentifier completionHandler:^(XCDYouTubeVideo *video, NSError *error)
     {
         if (video)
         {
             NSURL *streamURL = nil;
             NSArray *preferredVideoQualities = @[ XCDYouTubeVideoQualityHTTPLiveStreaming, @(XCDYouTubeVideoQualityHD720), @(XCDYouTubeVideoQualityMedium360), @(XCDYouTubeVideoQualitySmall240) ];
             for (NSNumber *videoQuality in preferredVideoQualities)
             {
                 streamURL = video.streamURLs[videoQuality];
                 if (streamURL)
                 {
                     pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[streamURL absoluteString]];
                     break;
                 }
             }
             
             if (!streamURL)
             {
                 NSError *noStreamError = [NSError errorWithDomain:XCDYouTubeVideoErrorDomain code:XCDYouTubeErrorNoStreamAvailable userInfo:nil];
                 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[noStreamError localizedDescription]];
             }
         }
         else
         {
             pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
         }
         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
     }];
}


- (void)openVideo:(CDVInvokedUrlCommand*)command
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlEventNotification:) name:@"RemoteControlEventReceived" object:videoPlayerViewController.moviePlayer];
    
    pluginResult = nil;
    
    NSString* videoID = [command.arguments objectAtIndex:0];
    
    if (videoID != nil) {
        view = [[UIView alloc]initWithFrame:[UIScreen mainScreen].applicationFrame];
        videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:videoID];
        [videoPlayerViewController presentInView:view];
//        [self.viewController presentMoviePlayerViewControllerAnimated:videoPlayerViewController];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:MPMoviePlayerPlaybackDidFinishNotification object:videoPlayerViewController.moviePlayer];
        [videoPlayerViewController.moviePlayer play];
        
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Missing videoID Argument"];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setMetadata:(CDVInvokedUrlCommand*) command
{
    NSString* name = [command.arguments objectAtIndex:0];
    NSString* album = [command.arguments objectAtIndex:1];
    NSString* artist = [command.arguments objectAtIndex:2];
    NSString* artwork = [command.arguments objectAtIndex:3];
    
    NSURL *imageUrl = [[NSURL alloc] initWithString:artwork];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        NSMutableDictionary *songInfo = [NSMutableDictionary dictionary];
        UIImage *artworkImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
        if(artworkImage)
        {
            MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage: artworkImage];
            [songInfo setValue:albumArt forKey:MPMediaItemPropertyArtwork];
            [songInfo setObject:name forKey:MPMediaItemPropertyTitle];
            [songInfo setObject:artist forKey:MPMediaItemPropertyArtist];
            [songInfo setObject:album forKey:MPMediaItemPropertyAlbumTitle];
        }
        MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
        infoCenter.nowPlayingInfo = songInfo;
        CDVPluginResult* result = nil;
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    });
}


- (void)receiveNotification: (NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:notification.object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RemoteControlEventReceived" object:videoPlayerViewController.moviePlayer];
    MPMovieFinishReason finishReason = [notification.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
    if (finishReason == MPMovieFinishReasonPlaybackError) {
        NSError *error = notification.userInfo[XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
    }
    [videoPlayerViewController removeFromParentViewController];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
}

-(void)remoteControlEventNotification:(NSNotification *)note{
    UIEvent *event = note.object;
    if (event.type == UIEventTypeRemoteControl){
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if (videoPlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStatePlaying){
                    [videoPlayerViewController.moviePlayer pause];
                } else {
                    [videoPlayerViewController.moviePlayer play];
                }
                break;
            default:
                break;
        }
    }
}

@end
