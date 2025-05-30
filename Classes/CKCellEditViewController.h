//
//  CellEditViewController.h
//  SUBa
//
//  Created by Martin Kim Dung-Pham on 29/03/2009.
//  Copyright 2009 University of Hamburg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface CKCellEditViewController : UIViewController <UITextFieldDelegate> {
	NSManagedObject *currentAccount;
	
	NSString *fieldType;
	NSMutableString *newValueString;
	NSString *currentValueString;
	UITextField *textField;
	BOOL secure;
}

- (void)saveInput;

@property(nonatomic, assign) NSMutableString *newValueString;
@property(nonatomic, assign) NSString *currentValueString;
@property(nonatomic, assign) NSString *fieldType;
@property(nonatomic, assign) IBOutlet UITextField *textField;
@property(nonatomic) BOOL secure;
@property(readwrite, assign) NSManagedObject *currentAccount;

@end
