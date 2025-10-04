//
//  CellEditViewController.m
//  SUBa
//
//  Created by Martin Kim Dung-Pham on 29/03/2009.
//  Copyright 2009 University of Hamburg. All rights reserved.
//

#import "CKCellEditViewController.h"
#import "Account.h"

@implementation CKCellEditViewController

@synthesize newValueString, currentValueString, textField, fieldType, secure, currentAccount;

- (void)viewDidLoad {
    [super viewDidLoad];
	[textField setEnabled:YES];

	if(secure) {		
		[textField setSecureTextEntry:YES];
	}
	[textField becomeFirstResponder];
}

// TODO - release all cached data
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (BOOL)textField:(UITextField *)atextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	//NSLog(@"%d, %@", range.length, string);
	//self.navigationItem.title = textField.text;
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)atextField {
	//NSLog(@"textFieldDidEndEditing %@", atextField.text);
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	//NSLog(@"textFieldShouldReturn...");
	[theTextField resignFirstResponder];
	[self saveInput];
	return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)theTextField {
	//NSLog(@"text: %@", theTextField.text);
	[self saveInput];
	return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
    
	//NSLog(@"%@", textField.text);
    [textField resignFirstResponder];
	
}

- (void)saveInput {
	if ([fieldType isEqualToString:@"ACCOUNT_NAME"]) {
		[(Account *)currentAccount setAccountName:textField.text];
	}
	if ([fieldType isEqualToString:@"ACCOUNT_USER_ID"]) {
		[(Account *)currentAccount setAccountUserID:textField.text];
	}
	if ([fieldType isEqualToString:@"ACCOUNT_USER_PASSWORD"]) {
		[(Account *)currentAccount setAccountUserPassword:textField.text];
	}
	
}

- (void)dealloc {
    [super dealloc];
}


@end
