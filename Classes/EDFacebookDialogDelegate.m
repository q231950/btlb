//
//  EDFacebookDialogDelegate.m
//  EDsync
//
//  Created by Martin Kim Dung-Pham on 2/9/11.
//  Copyright 2011 Elbedev. All rights reserved.
//

#import "EDFacebookDialogDelegate.h"


@implementation EDFacebookDialogDelegate


#pragma mark FBDialog delegate methods
- (void)dialogDidSucceed:(FBDialog *)dialog {
    if ([dialog isMemberOfClass:[FBLoginDialog class]]) {
        NSLog(@"[FBLoginDialog::dialogDidSucceed] just did succeed");
    }
}

- (void)dialogDidCancel:(FBDialog *)dialog {
	NSLog(@"Cancelled this dialog:%@", dialog);
}

- (void)dialog:(FBDialog *)dialog didFailWithError:(NSError *)error {
    NSLog(@"dialog:%@ didFailWithError:%@", dialog, error); 
}

#pragma mark FBSession delegate methods

- (void)fbDidLogin {
		NSLog(@"fb did log in");
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"fb did not login");
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout {
	NSLog(@"fb did logout");
}


- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response {

    NSLog(@"did r response %@", response);

}

@end
