//
//  UIViewController+Orientations.m
//  ShutdownMyMac-iOS
//
//  Created by Jesús on 19/4/15.
//  Copyright (c) 2015 Jesús. All rights reserved.
//

#import "UIViewController+Orientations.h"

@implementation UIViewController (Orientations)

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end
