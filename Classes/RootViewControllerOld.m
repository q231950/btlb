//
//  RootViewController.m
//  CampusKatalog
//
//  Created by Martin Kim Dung-Pham on 10/04/2009.
//  Copyright University of Hamburg 2009. All rights reserved.
//

#import "RootViewController.h"
#import "DataBaseConnection.h"

#import "CKAccountsViewController.h"
#import "CXMLDocument.h"
#import "CXMLElement.h"
#import "CKLibrarySettingsController.h"

@implementation RootViewControllerOld

@synthesize searchBar, searchDisplayController, mostRecentResults;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Campus Katalog";
	
	searchBar.scopeButtonTitles = [NSArray arrayWithObjects:@"Gesamtkatalog", @"Meine Bib", nil];
	//[searchBar setShowsScopeBar:NO];
	[searchBar setShowsCancelButton:NO animated:NO];
	
	searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.delegate = self;
	
	//searchDisplayController.searchResultsTableView.tableFooterView.
	searchResults = [[NSMutableArray alloc] init];
	currentPage = 1;
	
	[self.tableView reloadData];
}

#pragma mark Search
- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {
	if (![[aSearchBar text] isEqualToString:@""] ) {
		NSLog(@"ende editing");
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
	NSLog(@"searchBarSearchButtonClicked: %@", [aSearchBar text]);
	if ([aSearchBar.text length] >= 1) {
		[self filterContentForSearchText:[aSearchBar text] scope:[[searchBar scopeButtonTitles] objectAtIndex:[searchBar selectedScopeButtonIndex]]];
	} else {
		NSLog(@"query string in searchbar is too short.");
	}

}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	[searchResults removeAllObjects];	// clear the filtered array first
	
	dataBaseConnection = nil;
	dataBaseConnection = [[DataBaseConnection alloc] init];
	
	// fetching settings for the library
	CKLibrarySettingsController *allSettings = [[CKLibrarySettingsController alloc] init];
	NSDictionary *settings = [allSettings.libraries objectAtIndex:0];
	
	NSMutableString *searchString = [[NSString alloc] initWithString:[[searchBar text] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
	
	//creating the search string. a controller class for this task might be helpful for complex search terms
	NSString *searchRequestString = [NSString stringWithFormat:@"%@%@%@%@%d%@&TRM=%@", 
									 [settings valueForKey:@"catalogueBaseString"], 
									 [settings valueForKey:@"searchBaseString"],
									 [settings valueForKey:@"searchALLstring"],
									 [settings valueForKey:@"searchPageString"],
									 currentPage,
									 [settings valueForKey:@"searchSortString"],
									 searchString];
	NSLog(@"searchRequestString: %@",searchRequestString);
	
	if(searchRequestString) {
		NSData *data = [dataBaseConnection dataForRequest:searchRequestString];
		NSError *error = nil;
		
		CXMLDocument *xmlDocument = [[CXMLDocument alloc] initWithData:data options: 1 << 9 error: &error];
		CXMLElement *rootElement = [xmlDocument rootElement];
		NSArray *shortTitles = [[NSArray alloc] initWithArray:[rootElement nodesForXPath:@".//SET/SHORTTITLE" error: &error]];
		
		@try {
			//description of the SET
			CXMLElement *setDescription = [[rootElement nodesForXPath:@".//SET" error:NULL] objectAtIndex:0];
			hits = [[setDescription attributeForName:@"hits"] stringValue];
		}
		@catch (NSException * e) {
			NSLog(@"Keine Treffer! NO SET!");
			hits = 0;
		}
		@finally {
		}
		
		[searchResults addObjectsFromArray:shortTitles];
		[shortTitles release];
	}
	[searchDisplayController.searchResultsTableView reloadData];
	mostRecentResults = nil;
	mostRecentResults = [[NSArray alloc] initWithArray:searchResults];
}

// user selects searchbar
- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
	NSLog(@"searchDisplayControllerDidBeginSearch");
}

// user selects cancel button
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
	NSLog(@"searchDisplayControllerDidEndSearch");
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	
	// return YES to cause the search result table view to be reloaded
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
   
    [self filterContentForSearchText:[searchBar text] scope:[[searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // return YES to cause the search result table view to be reloaded
    return YES;
}

#pragma mark -

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == searchDisplayController.searchResultsTableView) {
        // return filtered content for the search results table view
		if([hits intValue] > [searchResults count]) {
			return [searchResults count]+1;
		} else {
			return [searchResults count];
		}        
    }
	else if (tableView == self.tableView) {
        // user navigation
        return 4;
    } else {
        //return [mostRecentResults count];
		return 0;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"NormalCell";
	
	static NSString *MoreCellIdentifier = @"MoreCell";
	
    UITableViewCell *cell;
	if (tableView == searchDisplayController.searchResultsTableView && [searchResults count] == indexPath.row) {
		NSLog(@"a more-cell was dequeued");
		cell = [tableView dequeueReusableCellWithIdentifier:MoreCellIdentifier];
	} else {
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	}

	if (cell == nil) {
		if (tableView == searchDisplayController.searchResultsTableView && [searchResults count] == indexPath.row) {
			cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:MoreCellIdentifier] autorelease];
		} else {
			cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		}
    }
    
	// Configure the cell.
	
	
	if (tableView == searchDisplayController.searchResultsTableView && indexPath.row < [searchResults count]) {
		CXMLElement *currentElement = [searchResults objectAtIndex:indexPath.row];
        // return filtered content for the search results table view
        cell.detailTextLabel.text = [currentElement stringValue];
    } else if (tableView == self.tableView) {
		// return content for the main table view
        cell.detailTextLabel.text = @"Konten";
    } else {
		// display the more hits button cell
        cell.textLabel.text = @"weitere...";
		cell.textLabel.font = [UIFont boldSystemFontOfSize:22.0];
		cell.textLabel.textColor = [UIColor darkGrayColor];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
    }
		
    return cell;
}


// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == 0) {
		NSLog(@"Row No. %d for Accounts", indexPath.row);
		CKAccountsViewController *accountsViewController = [[CKAccountsViewController alloc] initWithNibName:@"AccountsView" bundle:nil];
		[self.navigationController pushViewController:accountsViewController animated:YES];
		[accountsViewController release];
	}
    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [super dealloc];
}


@end

