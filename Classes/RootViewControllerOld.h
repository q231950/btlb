//
//  RootViewController.h
//  CampusKatalog
//
//  Created by Martin Kim Dung-Pham on 10/04/2009.
//  Copyright University of Hamburg 2009. All rights reserved.
//

@class DataBaseConnection;

@interface RootViewControllerOld : UITableViewController <UISearchDisplayDelegate> {
	UISearchBar		*searchBar;
	
    UISearchDisplayController   *searchDisplayController;
	
	int currentPage;
	NSString *hits;
	DataBaseConnection *dataBaseConnection;
	
	NSArray	*mostRecentResults;			// the master content
	NSMutableArray *searchResults;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;

@property (nonatomic, retain) NSArray *mostRecentResults;

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;

@property (nonatomic, retain) UISearchDisplayController *searchDisplayController;

@end
