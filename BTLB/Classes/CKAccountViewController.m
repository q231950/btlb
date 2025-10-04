//
//  AccountViewController.m
//  SUBa
//
//  Created by Martin Kim Dung-Pham on 20/03/2009.
//  Copyright 2009 University of Hamburg. All rights reserved.
//

#import "CKAccountViewController.h"
#import "Account.h"
#import "AccountTypeChooserView.h"
#import "CKCellEditViewController.h"
#import "CKLibrarySettingsController.h"
#import "DataBaseConnection.h"
#import "EDSyncAppDelegate.h"
#import "XmlParser.h"

#define DEBUG 1

@implementation CKAccountViewController

@synthesize accountManagedObject, tableView;

#pragma mark View methods
- (void)viewDidLoad {
    [super viewDidLoad];

	mainBundle = [NSBundle mainBundle];
	
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
	self.navigationItem.title = accountManagedObject.accountName;
	[tableView reloadData];
	if (self.editing) {
		[self setEditing:YES animated:NO];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 6;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	atableView.allowsSelectionDuringEditing = YES;
	atableView.allowsSelection = NO;
	
	static NSString *CellIdentifier = @"NormalCell";
	UITableViewCell *cell = [atableView dequeueReusableCellWithIdentifier: CellIdentifier];
	
	static NSString *FirstCellIdentifier = @"FirstCell";
	static NSString *UpdateAccountCellIdentifier = @"UpdateAccountCell";
	
	if(indexPath.row == 0) {
		cell = [atableView dequeueReusableCellWithIdentifier: FirstCellIdentifier];
	}
	if(indexPath.row == 4) {
		cell = [atableView dequeueReusableCellWithIdentifier: UpdateAccountCellIdentifier];
	}
     

    if (cell == nil) {
		switch (indexPath.row) {
			case 0:
				cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:FirstCellIdentifier];
				break;
			case 4:
				cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue2 reuseIdentifier:UpdateAccountCellIdentifier];
				break;
			default:
				cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
				break;
		}
    }
	
	activatedSwitch = [[[UISwitch alloc] init] autorelease];
	
	activatedSwitch.on = [[accountManagedObject valueForKey:@"activated"] boolValue];
	activatedSwitch.tag = 2;
	[activatedSwitch addTarget:self action:@selector(switchAction:) forControlEvents: UIControlEventValueChanged];
    
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"dd.MM.YYYY - HH:mm"];
	
	// Set up the cell...
	cell.textLabel.font = [UIFont fontWithName:@"AppleGothic" size: 13.0];
	
	cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	
	if (self.editing && indexPath.row < 4) {
		cell.detailTextLabel.enabled = YES;
	} else {
		cell.detailTextLabel.enabled = NO;
	}

	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	atableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

	switch (indexPath.row) {
		case 0:
			cell.accessoryView = activatedSwitch;
			cell.textLabel.text = accountManagedObject.accountName;
			cell.textLabel.font = [UIFont boldSystemFontOfSize:19.0];
			
			cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			
			if (self.editing) {
				cell.textLabel.enabled = YES;
			} else {
				cell.textLabel.enabled = NO;
			}
			break;
		case 1:
			cell.textLabel.text = [mainBundle localizedStringForKey:@"ACCOUNT_TYPE" value:@"Access to" table:@"Account"];
			cell.detailTextLabel.text = accountManagedObject.accountTypeName;
			cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			break;
		case 2:
			cell.textLabel.text = [mainBundle localizedStringForKey:@"ACCOUNT_USER_ID" value:@"User ID" table:@"Account"];
			cell.detailTextLabel.text = accountManagedObject.accountUserID;
			cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			break;
		case 3:
			cell.textLabel.text = [mainBundle localizedStringForKey:@"ACCOUNT_USER_PASSWORD" value:@"Password" table:@"Account"];
			if ([accountManagedObject.accountUserPassword length] > 0) {
				cell.detailTextLabel.text = [mainBundle localizedStringForKey:@"PASSWORD_IS_SET" value:@"is set" table:@"Account"];
			} else {
				cell.detailTextLabel.text = [mainBundle localizedStringForKey:@"PASSWORD_IS_NOT_SET" value:@"is not set" table:@"Account"];
			}

			cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			break;
		case 4:
			cell.textLabel.text = [mainBundle localizedStringForKey:@"ACCOUNT_LAST_UPDATE" value:@"Last update" table:@"Account"];
			if (accountManagedObject.accountLastUpdate) {
				cell.detailTextLabel.text = [dateFormatter stringFromDate:accountManagedObject.accountLastUpdate];
			} else {
				cell.detailTextLabel.text = [mainBundle localizedStringForKey:@"ACCOUNT_NEVER_UPDATED" value:@"never updated" table:@"Account"];
			}
			//cell.editingAccessoryView = updateAccountButton;
			break;
		case 5:
			cell.textLabel.text = [mainBundle localizedStringForKey:@"ACCOUNT_CREATION_DATE" value:@"Created on" table:@"Account"];
			cell.detailTextLabel.text = [dateFormatter stringFromDate: accountManagedObject.accountCreationDate];
			break;
		default:
			break;
	}
	
	[dateFormatter release];
    return cell;
}

// React to user's row selection
- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == 0) {
		// user wants to change the account identifier 
		CKCellEditViewController *textEditorView = (CKCellEditViewController *)[[CKCellEditViewController alloc] initWithNibName:@"CellEditView" bundle:mainBundle];
		textEditorView.title = [mainBundle localizedStringForKey:@"ACCOUNT_NAME" value:@"Identifier" table:@"Account"];
		textEditorView.fieldType = @"ACCOUNT_NAME";
		textEditorView.currentAccount = accountManagedObject;
		[self.navigationController pushViewController:textEditorView animated:YES];
		textEditorView.textField.text = [[[tableView cellForRowAtIndexPath:indexPath] textLabel]text];
		[textEditorView release];
	} else if (indexPath.row == 1) {
		// user wants to set the account type
		AccountTypeChooserView *typeChooserView = (AccountTypeChooserView *)[[AccountTypeChooserView alloc] initWithNibName:@"AccountTypeChooserView" bundle:mainBundle];
		typeChooserView.currentAccount = accountManagedObject;
		typeChooserView.title = [mainBundle localizedStringForKey:@"ACCOUNT_TYPE" value:@"Library" table:@"Account"];
		[self.navigationController pushViewController:typeChooserView animated:YES];
		[typeChooserView release];
	} else if (indexPath.row == 2) {
		// user wants to change his user id
		CKCellEditViewController *textEditorView = (CKCellEditViewController *)[[CKCellEditViewController alloc] initWithNibName:@"CellEditView" bundle:mainBundle];	
		textEditorView.title = [mainBundle localizedStringForKey:@"ACCOUNT_USER_ID" value:@"User ID" table:@"Account"];
		textEditorView.fieldType = @"ACCOUNT_USER_ID";
		textEditorView.currentAccount = accountManagedObject;
		[self.navigationController pushViewController:textEditorView animated:YES];
		textEditorView.textField.text = [[[tableView cellForRowAtIndexPath:indexPath] detailTextLabel] text];
		[textEditorView release];
	} else if (indexPath.row == 3) {
		// user wants to change his password
		CKCellEditViewController *textEditorView = (CKCellEditViewController *)[[CKCellEditViewController alloc] initWithNibName:@"CellEditView" bundle:mainBundle];
		[textEditorView setSecure:YES];
		textEditorView.title = [mainBundle localizedStringForKey:@"ACCOUNT_USER_PASSWORD" value:@"Password" table:@"Account"];
		textEditorView.fieldType = @"ACCOUNT_USER_PASSWORD";
		textEditorView.currentAccount = accountManagedObject;
		[self.navigationController pushViewController:textEditorView animated:YES];
		textEditorView.textField.text = [[[tableView cellForRowAtIndexPath:indexPath] detailTextLabel] text];
		[textEditorView release];
	} else {
		// do nothing
	}
}

- (BOOL)tableView:(UITableView *)aTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	//NSLog(@"%@", indexPath);
	switch (indexPath.row) {
		case 0:
			return YES;
			break;
		case 1:
			return YES;
			break;
		case 2:
			return YES;
			break;
		case 3:
			return YES;
			break;
		default:
			return NO;
			break;
	}
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

// The editing style for a row is the kind of button displayed to the left of the cell when in editing mode.
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)atableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleNone) {
		// do something. 
	}
}

#pragma mark Editing
// Set the editing state of the view controller. We pass this down to the table view and also modify the content
// of the table to insert a placeholder row for adding content when in editing mode.
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	
    [super setEditing:editing animated:animated];
	
	for (int i = 0; i < [tableView numberOfRowsInSection:0]-2; i++) {
		//NSLog(@"editing = %d, row is: %d", editing, i);
		NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
		UITableViewCell *acell = [tableView cellForRowAtIndexPath: path];
		//NSLog(@"path: %@", path);
		if (editing) {
			if (i == 0) {
				acell.textLabel.enabled = YES;
			}
			acell.detailTextLabel.enabled = YES;
			acell.selectionStyle = UITableViewCellSelectionStyleGray;
		} else {
			if (i == 0) {
				acell.textLabel.enabled = NO;
			}
			acell.detailTextLabel.enabled = NO;
			acell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		path = nil;
	}
	EDSyncAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate saveAction:self];
}


- (void)switchAction:(UISwitch *)sender {
	if(sender.tag == 2) {
		accountManagedObject.activated = [NSNumber numberWithInt:sender.on];
		NSLog(@"%@", accountManagedObject.activated);
		if ([accountManagedObject.activated intValue] == 1) {
			// Activated
			[self updateAccount];
			if (DEBUG) {
				NSLog(@"activated");
			}
		} else {
			if (DEBUG) {
				NSLog(@"not activated");
			}
		}
	}
}

-(void)updateAccount {
	//XmlParser *parser = [[XmlParser alloc] init];
	DataBaseConnection *dbCon = [[DataBaseConnection alloc] init];

	// TODO: update the account
	[dbCon loansForAccount:accountManagedObject];
	//NSArray *loans = [dbCon ];
	//NSLog(@"%@", loans);
	
	NSLog(@"almost Finished updating account");
	
}


#pragma mark -
#pragma mark Cancel Button pressed

- (void)cancelEdit {
	NSLog(@"cancel the shit");
}


#pragma mark -
#pragma mark End of Lifecycle


- (void)dealloc {
	[mainBundle release];
	//[tableView release];
    [super dealloc];
}


@end

