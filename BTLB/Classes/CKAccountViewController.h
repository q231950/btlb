//
//  AccountViewController.h
//  SUBa
//
//  Created by Martin Kim Dung-Pham on 20/03/2009.
//  Copyright 2009 University of Hamburg. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Account;

@interface CKAccountViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	Account *accountManagedObject;

	UISwitch *activatedSwitch;
	IBOutlet UIActivityIndicatorView *updateAccountActivityIndicator;
	
	NSBundle *mainBundle;

	UITableView *tableView;
}

@property(nonatomic, retain) Account *accountManagedObject;
@property (readwrite, nonatomic, retain) IBOutlet UITableView *tableView;

-(void)updateAccount;

@end
